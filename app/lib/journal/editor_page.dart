import 'dart:async';

import 'package:flutter/material.dart';

import '../data/entry_repository.dart';
import '../l10n/strings.dart';
import '../theme/tokens.dart';
import '../theme/app_icons.dart';

/// S7 Editor: write a new entry or change an existing one (FEAT-001).
class EditorPage extends StatefulWidget {
  const EditorPage({super.key, required this.repository, this.entry, this.draft});

  final EntryRepository repository;

  /// The entry being changed, or null for a new one.
  final JournalEntry? entry;

  /// Unsaved text to start from, when the user chose to continue it.
  final EntryDraft? draft;

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> with WidgetsBindingObserver {
  late final TextEditingController _text;
  late String _day;
  Timer? _draftTimer;
  bool _saveFailed = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.draft?.body ?? widget.entry?.body ?? '');
    _day = widget.draft?.day ?? widget.entry?.day ?? dayKey(DateTime.now());
    _text.addListener(_onChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  /// The app is leaving the screen (lock, app switch, call): keep the text now,
  /// before the journal is closed (FEAT-001 AC-4, FEAT-003).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _draftTimer?.cancel();
      _writeDraft();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _draftTimer?.cancel();
    _text.dispose();
    super.dispose();
  }

  bool get _canSave => !EntryRepository.isBlank(_text.text);

  bool get _changed =>
      _text.text != (widget.entry?.body ?? '') || _day != (widget.entry?.day ?? dayKey(DateTime.now()));

  void _onChanged() {
    setState(() {});
    _draftTimer?.cancel();
    // The draft is written a moment after typing stops, so a kill loses at
    // most the last half second (NFR-7).
    _draftTimer = Timer(const Duration(milliseconds: 500), _writeDraft);
  }

  Future<void> _writeDraft() async {
    if (_done) return;
    if (!_changed) {
      try {
        await widget.repository.discardDraft();
      } catch (_) {}
      return;
    }
    try {
      await widget.repository.saveDraft(entryId: widget.entry?.id, day: _day, body: _text.text);
    } catch (_) {
      // The journal may already be closed because the app locked; the draft
      // was written when the app went inactive, before the lock.
    }
  }

  Future<void> _save() async {
    if (!_canSave) return;
    _draftTimer?.cancel();
    try {
      final entry = widget.entry;
      if (entry == null) {
        await widget.repository.create(day: _day, body: _text.text);
      } else {
        await widget.repository.update(id: entry.id, day: _day, body: _text.text);
      }
    } catch (_) {
      if (mounted) setState(() => _saveFailed = true);
      return;
    }
    _done = true;
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _leave() async {
    _draftTimer?.cancel();
    await _writeDraft();
    _done = true;
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_day),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null) {
      setState(() => _day = dayKey(picked));
      _draftTimer?.cancel();
      _draftTimer = Timer(const Duration(milliseconds: 500), _writeDraft);
    }
  }

  Future<void> _confirmDelete() async {
    final entry = widget.entry;
    if (entry == null) return;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.of(context).surfaceRaised,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => const _DeleteSheet(),
    );
    if (confirmed == true) {
      _draftTimer?.cancel();
      _done = true;
      await widget.repository.delete(entry.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.screenMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: S.back,
                      onPressed: _leave,
                      icon: const Icon(AppIcons.back),
                      constraints: const BoxConstraints(minWidth: AppSpace.touchMin, minHeight: AppSpace.touchMin),
                    ),
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: S.entryDateLabel(formatDay(_day)),
                        excludeSemantics: true,
                        child: InkWell(
                          onTap: _pickDate,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: AppSpace.touchMin),
                            child: Center(
                              child: Text(formatDay(_day), style: AppType.body, textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(onPressed: _canSave ? _save : null, child: Text(S.save)),
                  ],
                ),
                Center(
                  child: Text(
                    _canSave ? S.draftKept : S.saveNeedsText,
                    style: AppType.caption.copyWith(color: c.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpace.s12),
                if (_saveFailed) _SaveError(onRetry: _save),
                Expanded(
                  child: Semantics(
                    label: S.entryTextLabel,
                    textField: true,
                    child: TextField(
                      controller: _text,
                      autofocus: widget.entry == null,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      // The journal never leaves the phone, so no suggestions or
                      // personalised learning of what the user writes.
                      enableSuggestions: false,
                      autocorrect: false,
                      enableIMEPersonalizedLearning: false,
                      style: AppType.journal.copyWith(color: c.textPrimary),
                      cursorColor: c.actionBg,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: S.entryHint,
                        hintStyle: AppType.journal.copyWith(color: c.textSecondary),
                      ),
                    ),
                  ),
                ),
                if (widget.entry != null)
                  TextButton(
                    onPressed: _confirmDelete,
                    style: TextButton.styleFrom(foregroundColor: c.dangerFg),
                    child: Text(S.deleteEntry),
                  ),
                const SizedBox(height: AppSpace.s8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveError extends StatelessWidget {
  const _SaveError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppSpace.s12),
        padding: const EdgeInsets.all(AppSpace.s16),
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          border: Border.all(color: c.warningFg),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.important, style: AppType.caption.copyWith(color: c.warningFg)),
            const SizedBox(height: AppSpace.s4),
            Text(S.saveErrorTitle, style: AppType.label),
            const SizedBox(height: AppSpace.s4),
            Text(S.saveErrorBody, style: AppType.caption.copyWith(color: c.textSecondary)),
            const SizedBox(height: AppSpace.s8),
            TextButton(onPressed: onRetry, child: Text(S.tryAgain)),
          ],
        ),
      ),
    );
  }
}

class _DeleteSheet extends StatelessWidget {
  const _DeleteSheet();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.screenMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.deleteTitle, style: AppType.title),
            const SizedBox(height: AppSpace.s8),
            Text(S.deleteBody, style: AppType.body.copyWith(color: c.textSecondary)),
            const SizedBox(height: AppSpace.s24),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: c.dangerSolid, foregroundColor: c.dangerOnSolid),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(S.deleteEntry),
            ),
            const SizedBox(height: AppSpace.s8),
            Center(
              child: TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(S.cancel)),
            ),
          ],
        ),
      ),
    );
  }
}
