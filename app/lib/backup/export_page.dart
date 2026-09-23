import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data/entry_repository.dart';
import '../l10n/strings.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'backup_files.dart';
import 'backup_service.dart';
import 'backup_widgets.dart';
import 'envelope.dart';

/// S11 Export (FEAT-006): choose protected or readable, choose the password,
/// build the file, hand it to the phone's share dialog.
class ExportPage extends StatefulWidget {
  const ExportPage({super.key, required this.repository, required this.files, this.params, this.now});
  final EntryRepository repository;
  final BackupFiles files;

  /// Key-derivation cost of the export; tests pass a small one.
  final EnvelopeParams? params;
  final DateTime Function()? now;

  @override
  State<ExportPage> createState() => _ExportPageState();
}

enum _Step { choose, password, working, done, error }

class _ExportPageState extends State<ExportPage> {
  _Step _step = _Step.choose;
  bool _protected = true;
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  bool _shown = false;
  int _count = 0;
  bool _cancelledShare = false;
  late final Future<DateTime?> _last = widget.repository.lastExportAt();

  @override
  void dispose() {
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }

  bool get _pwLongEnough => _pw.text.runes.length >= 8;
  bool get _pwValid => _pwLongEnough && _pw.text == _pw2.text;

  String _fileName(bool encrypted) {
    final d = (widget.now ?? DateTime.now)();
    final day = dayKey(d);
    return 'exodite-journal-$day.${encrypted ? 'anima' : 'zip'}';
  }

  Future<void> _chooseContinue() async {
    if (_protected) {
      setState(() => _step = _Step.password);
      return;
    }
    // Nothing is created before the user has read the warning (FEAT-006 AC-3).
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.of(context).surfaceRaised,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
      builder: (_) => const _PlainWarning(),
    );
    if (ok == true) await _run(password: null);
  }

  Future<void> _run({required String? password}) async {
    setState(() => _step = _Step.working);
    try {
      final entries = await widget.repository.readAllForExport();
      if (mounted) setState(() => _count = entries.length);
      // Decrypted here, on the main isolate, since only the repository holds
      // the device data key; a photo that fails to decrypt (AC-8, damaged or
      // unreadable) is left out of the export rather than failing all of it.
      final photoBytes = <String, Uint8List>{};
      for (final entry in entries) {
        for (final ref in entry.media) {
          try {
            photoBytes[ref.uid] = await widget.repository.readPhotoBytes(ref.uid);
          } catch (_) {
            // left out of photoBytes; createBackup drops its media reference too
          }
        }
      }
      final Uint8List file = await createBackup(entries, password: password, params: widget.params, now: (widget.now ?? DateTime.now)(), photoBytes: photoBytes);
      final outcome = await widget.files.share(bytes: file, fileName: _fileName(password != null));
      if (outcome == ShareOutcome.cancelled) {
        // The user closed the share dialog: no file was kept, so this is not an export (AC-7).
        if (mounted) setState(() => _step = _protected ? _Step.password : _Step.choose);
        _cancelledShare = true;
        return;
      }
      await widget.repository.recordExport((widget.now ?? DateTime.now)());
      if (mounted) setState(() => _step = _Step.done);
    } catch (_) {
      // Nothing was recorded: the last export time is unchanged (AC-7).
      if (mounted) setState(() => _step = _Step.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    switch (_step) {
      case _Step.choose:
        return BackupFrame(
          onBack: () => Navigator.of(context).pop(),
          items: [
            Semantics(header: true, child: Text(S.exportRow, style: AppType.title)),
            const SizedBox(height: AppSpace.s8),
            Text(S.exportBody, style: AppType.body.copyWith(color: c.textSecondary)),
            const SizedBox(height: AppSpace.s8),
            FutureBuilder<DateTime?>(
              future: _last,
              builder: (context, snap) => snap.connectionState != ConnectionState.done
                  ? const SizedBox.shrink()
                  : Text(
                      snap.data == null ? S.neverExported : S.lastExport(formatDay(dayKey(snap.data!))),
                      style: AppType.caption.copyWith(color: c.textSecondary),
                    ),
            ),
            const SizedBox(height: AppSpace.s24),
            ChoiceCard(title: S.exportProtected, note: S.exportProtectedNote, selected: _protected, onTap: () => setState(() => _protected = true)),
            const SizedBox(height: AppSpace.s12),
            ChoiceCard(title: S.exportPlain, note: S.exportPlainNote, selected: !_protected, onTap: () => setState(() => _protected = false)),
            if (_cancelledShare)
              Padding(
                padding: const EdgeInsets.only(top: AppSpace.s16),
                child: Text(S.exportNotSaved, style: AppType.caption.copyWith(color: c.textSecondary)),
              ),
          ],
          actions: [FilledButton(onPressed: _chooseContinue, child: Text(S.continueLabel))],
        );
      case _Step.password:
        final mismatch = _pw2.text.isNotEmpty && !_pw.text.startsWith(_pw2.text) || (_pw2.text.length >= _pw.text.length && _pw2.text != _pw.text);
        return BackupFrame(
          onBack: () => setState(() => _step = _Step.choose),
          items: [
            Semantics(header: true, child: Text(S.exportPasswordTitle, style: AppType.title)),
            const SizedBox(height: AppSpace.s8),
            Text(S.exportPasswordBody, style: AppType.body.copyWith(color: c.textSecondary)),
            const SizedBox(height: AppSpace.s24),
            SecretField(
              fieldKey: const Key('export-password'),
              label: S.exportPasswordLabel,
              hint: S.exportPasswordHint,
              controller: _pw,
              shown: _shown,
              onToggle: () => setState(() => _shown = !_shown),
              error: _pw.text.isNotEmpty && !_pwLongEnough && _pw.text.length >= 3 && _pw2.text.isNotEmpty ? S.exportPasswordTooShort : null,
              autofocus: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpace.s16),
            SecretField(
              fieldKey: const Key('export-password-repeat'),
              label: S.repeatLabel,
              hint: S.repeatHint,
              controller: _pw2,
              shown: _shown,
              onToggle: null,
              error: mismatch ? S.passcodeMismatch : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpace.s12),
            Text(S.exportPasswordHelper, style: AppType.caption.copyWith(color: c.textSecondary)),
          ],
          actions: [
            if (!_pwValid)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.s8),
                child: Text(S.passcodeNeeded, style: AppType.caption.copyWith(color: c.textSecondary)),
              ),
            FilledButton(onPressed: _pwValid ? () => _run(password: _pw.text) : null, child: Text(S.exportButton)),
          ],
        );
      case _Step.working:
        return BackupFrame(
          items: [
            StatusBody(
              title: S.exportWorkingTitle,
              body: S.exportWorkingBody,
              extra: Column(children: [
                const LinearProgressIndicator(),
                if (_count > 0) ...[
                  const SizedBox(height: AppSpace.s8),
                  Text(S.entryCount(_count), style: AppType.caption.copyWith(color: c.textSecondary)),
                ],
              ]),
            ),
          ],
        );
      case _Step.done:
        return BackupFrame(
          items: [
            StatusBody(
              title: S.exportDoneTitle,
              body: S.exportDoneBody,
              extra: _protected
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpace.s16),
                      decoration: BoxDecoration(
                        color: c.surfaceRaised,
                        border: Border.all(color: c.warningFg),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(S.important, style: AppType.caption.copyWith(color: c.warningFg)),
                        const SizedBox(height: AppSpace.s4),
                        Text(S.keepPasswordTitle, style: AppType.label),
                        const SizedBox(height: AppSpace.s4),
                        Text(S.keepPasswordBody, style: AppType.caption.copyWith(color: c.textSecondary)),
                      ]),
                    )
                  : null,
            ),
          ],
          actions: [FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(S.done))],
        );
      case _Step.error:
        return BackupFrame(
          items: [StatusBody(title: S.exportErrorTitle, body: S.exportErrorBody)],
          actions: [
            FilledButton(
              onPressed: () => setState(() => _step = _protected ? _Step.password : _Step.choose),
              child: Text(S.tryAgain),
            ),
            const SizedBox(height: AppSpace.s8),
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(S.cancel)),
          ],
        );
    }
  }
}

class _PlainWarning extends StatelessWidget {
  const _PlainWarning();

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
            Text(S.important, style: AppType.caption.copyWith(color: c.warningFg)),
            const SizedBox(height: AppSpace.s4),
            Text(S.warnPlainTitle, style: AppType.title),
            const SizedBox(height: AppSpace.s8),
            Text(S.warnPlainBody, style: AppType.body.copyWith(color: c.textSecondary)),
            const SizedBox(height: AppSpace.s24),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: c.dangerSolid, foregroundColor: c.dangerOnSolid),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(S.exportWithoutProtection),
            ),
            const SizedBox(height: AppSpace.s8),
            OutlinedButton(onPressed: () => Navigator.of(context).pop(false), child: Text(S.goBack)),
          ],
        ),
      ),
    );
  }
}
