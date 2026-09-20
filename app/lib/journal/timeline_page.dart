import 'dart:async';

import 'package:flutter/material.dart';

import '../data/entry_repository.dart';
import '../l10n/strings.dart';
import '../theme/tokens.dart';
import '../backup/backup_files.dart';
import '../backup/export_page.dart';
import '../backup/import_page.dart';
import '../backup/reminder.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_page.dart';
import 'editor_page.dart';
import 'search_page.dart';
import '../theme/app_icons.dart';

/// A minimal host for FEAT-001: the list of entries and a way to write one.
/// Search, the export reminder, and Settings belong to FEAT-005, FEAT-008 and
/// FEAT-009 and are not here. Screen S6 is completed by FEAT-002.
class TimelinePage extends StatefulWidget {
  const TimelinePage({
    super.key,
    required this.repository,
    required this.files,
    this.startWithImport = false,
    this.now,
    required this.settings,
  });
  final EntryRepository repository;
  final BackupFiles files;
  final DateTime Function()? now;
  final SettingsController settings;

  /// After a first-run "Import your journal": open the import screen at once (FEAT-007 AC-9).
  final bool startWithImport;

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  bool _draftChecked = false;
  late final Stream<List<_Row>> _rows = widget.repository.watchTimeline().map(
    _flatten,
  );
  ReminderKind _reminder = ReminderKind.none;
  StreamSubscription<List<_Row>>? _rowsSub;

  DateTime get _now => (widget.now ?? DateTime.now)();

  /// Decides again whether to remind (FEAT-008). Reads counts and times, never text.
  Future<void> _refreshReminder() async {
    final ReminderInputs inputs;
    try {
      inputs = await widget.repository.reminderInputs();
    } catch (_) {
      return; // the journal was closed because the app locked; nothing to show
    }
    if (!mounted) return;
    final kind = reminderFor(inputs, _now);
    if (kind != _reminder) setState(() => _reminder = kind);
  }

  @override
  void dispose() {
    _rowsSub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _rowsSub = _rows.listen((_) => _refreshReminder());
    WidgetsBinding.instance.addPostFrameCallback((_) => _offerDraft());
  }

  /// An unsaved draft from an interrupted session is offered back (AC-4).
  Future<void> _offerDraft() async {
    final draft = await widget.repository.loadDraft();
    if (!mounted) return;
    setState(() => _draftChecked = true);
    if (widget.startWithImport) {
      await Navigator.of(context).push(
        MaterialPageRoute<bool>(
          builder: (_) =>
              ImportPage(repository: widget.repository, files: widget.files),
        ),
      );
      if (!mounted) return;
    }
    if (draft == null) return;
    final choice = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ResumeDialog(),
    );
    if (!mounted) return;
    if (choice == true) {
      final entry = draft.entryId == null
          ? null
          : await widget.repository.get(draft.entryId!);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => EditorPage(
            repository: widget.repository,
            entry: entry,
            draft: draft,
          ),
        ),
      );
    } else {
      await widget.repository.discardDraft();
    }
  }

  Future<void> _open({JournalEntry? entry}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EditorPage(repository: widget.repository, entry: entry),
      ),
    );
    unawaited(_refreshReminder());
  }

  Future<void> _exportNow() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExportPage(
          repository: widget.repository,
          files: widget.files,
          now: widget.now,
        ),
      ),
    );
    unawaited(_refreshReminder());
  }

  Future<void> _search() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SearchPage(repository: widget.repository),
      ),
    );
    unawaited(_refreshReminder());
  }

  Future<void> _later() async {
    await widget.repository.dismissReminder(_now);
    unawaited(_refreshReminder());
  }

  /// Opens a tapped row: the full text is read only now (FEAT-002 AC-3).
  Future<void> _openItem(TimelineItem item) async {
    final entry = await widget.repository.get(item.id);
    if (entry == null || !mounted) return;
    await _open(entry: entry);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.screenMargin,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpace.s16),
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(S.appTitle, style: AppType.title),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => SettingsPage(
                            repository: widget.repository,
                            files: widget.files,
                            settings: widget.settings,
                            now: widget.now,
                          ),
                        ),
                      );
                      unawaited(_refreshReminder());
                    },
                    child: Text(S.settings),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.s16),
              Expanded(
                child: StreamBuilder<List<_Row>>(
                  stream: _rows,
                  builder: (context, snap) {
                    final rows = snap.data;
                    final ready = _draftChecked && rows != null;
                    // Search, the reminder and the list scroll together, so nothing is
                    // pushed off the screen when the text is large (200 percent).
                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                button: true,
                                label: S.searchLabel,
                                excludeSemantics: true,
                                child: InkWell(
                                  key: const Key('search-entry'),
                                  onTap: _search,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    constraints: const BoxConstraints(
                                      minHeight: AppSpace.fieldHeight,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpace.s16,
                                      vertical: AppSpace.s8,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                      color: AppColors.of(
                                        context,
                                      ).surfaceRaised,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.md,
                                      ),
                                      border: Border.all(
                                        color: AppColors.of(
                                          context,
                                        ).borderStrong,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          AppIcons.search,
                                          color: AppColors.of(
                                            context,
                                          ).textSecondary,
                                        ),
                                        const SizedBox(width: AppSpace.s8),
                                        Expanded(
                                          child: Text(
                                            S.searchHint,
                                            style: AppType.body.copyWith(
                                              color: AppColors.of(
                                                context,
                                              ).textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpace.s12),
                              if (_reminder != ReminderKind.none) ...[
                                _ReminderCard(
                                  kind: _reminder,
                                  onExport: _exportNow,
                                  onLater: _later,
                                ),
                                const SizedBox(height: AppSpace.s12),
                              ],
                            ],
                          ),
                        ),
                        if (!ready)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                S.loading,
                                style: AppType.caption.copyWith(
                                  color: c.textSecondary,
                                ),
                              ),
                            ),
                          )
                        else if (rows.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _Empty(onWrite: _open),
                          )
                        else
                          _EntryList(rows: rows, onOpen: _openItem),
                      ],
                    );
                  },
                ),
              ),
              StreamBuilder<List<_Row>>(
                stream: _rows,
                builder: (context, snap) {
                  if (snap.data == null || snap.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpace.s16),
                    child: Center(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, AppSpace.buttonHeight),
                        ),
                        onPressed: _open,
                        icon: const Icon(AppIcons.add),
                        label: Text(S.newEntry),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onWrite});
  final Future<void> Function({JournalEntry? entry}) onWrite;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(S.emptyTitle, style: AppType.title),
        const SizedBox(height: AppSpace.s8),
        Text(
          S.emptyBody,
          style: AppType.body.copyWith(color: c.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpace.s24),
        FilledButton(onPressed: () => onWrite(), child: Text(S.writeFirst)),
        const SizedBox(height: AppSpace.s48),
      ],
    );
  }
}

/// A heading (a day) or an entry row; the list is built lazily from these.
sealed class _Row {}

class _Heading extends _Row {
  _Heading(this.day);
  final String day;
}

class _Item extends _Row {
  _Item(this.item);
  final TimelineItem item;
}

List<_Row> _flatten(List<TimelineItem> items) {
  final rows = <_Row>[];
  String? last;
  for (final i in items) {
    if (i.day != last) {
      last = i.day;
      rows.add(_Heading(i.day));
    }
    rows.add(_Item(i));
  }
  return rows;
}

String _dayHeading(String day) {
  final now = DateTime.now();
  if (day == dayKey(now)) return S.today;
  if (day == dayKey(now.subtract(const Duration(days: 1)))) return S.yesterday;
  return formatDay(day);
}

String _time(int ms) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  return '${d.hour}:${d.minute.toString().padLeft(2, '0')}';
}

class _EntryList extends StatelessWidget {
  const _EntryList({required this.rows, required this.onOpen});
  final List<_Row> rows;
  final void Function(TimelineItem) onOpen;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    // Only the rows on screen are built, so 20,000 entries stay smooth (AC-4).
    return SliverList.builder(
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        if (row is _Heading) {
          return Padding(
            padding: const EdgeInsets.only(
              top: AppSpace.s16,
              bottom: AppSpace.s4,
            ),
            child: Semantics(
              header: true,
              child: Text(
                _dayHeading(row.day),
                style: AppType.caption.copyWith(color: c.textSecondary),
              ),
            ),
          );
        }
        final item = (row as _Item).item;
        return Column(
          children: [
            Semantics(
              button: true,
              label: '${_time(item.createdAtMs)}. ${item.preview}',
              excludeSemantics: true,
              child: InkWell(
                onTap: () => onOpen(item),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppSpace.touchMin,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpace.s12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _time(item.createdAtMs),
                          style: AppType.caption.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpace.s4),
                        Text(
                          item.preview,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.journal.copyWith(color: c.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Divider(height: 1, color: c.borderDefault),
          ],
        );
      },
    );
  }
}

class _ResumeDialog extends StatelessWidget {
  const _ResumeDialog();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Dialog(
      backgroundColor: c.surfaceRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.resumeTitle, style: AppType.title),
            const SizedBox(height: AppSpace.s8),
            Text(
              S.resumeBody,
              style: AppType.body.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: AppSpace.s24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(S.resumeContinue),
            ),
            const SizedBox(height: AppSpace.s8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(S.resumeDiscard),
            ),
          ],
        ),
      ),
    );
  }
}

/// The export reminder (FEAT-008). It states facts about the backup and never shows entry text.
class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.kind,
    required this.onExport,
    required this.onLater,
  });
  final ReminderKind kind;
  final VoidCallback onExport;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        key: const Key('export-reminder'),
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpace.s16),
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          border: Border.all(color: c.borderStrong),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kind == ReminderKind.neverExported
                  ? S.reminderNeverTitle
                  : S.reminderOverdueTitle,
              style: AppType.label,
            ),
            const SizedBox(height: AppSpace.s4),
            Text(
              S.reminderBody,
              style: AppType.caption.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: AppSpace.s8),
            Row(
              children: [
                TextButton(
                  onPressed: onExport,
                  child: Text(S.reminderExportNow),
                ),
                TextButton(onPressed: onLater, child: Text(S.reminderLater)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
