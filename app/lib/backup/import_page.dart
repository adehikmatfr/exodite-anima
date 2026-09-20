import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data/entry_repository.dart';
import '../l10n/strings.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'backup_files.dart';
import 'backup_service.dart';
import 'backup_widgets.dart';

/// S12 Import (FEAT-007). The file is read and checked completely first; the
/// journal changes only in one transaction at the end, so it either gets every
/// new entry or none.
class ImportPage extends StatefulWidget {
  const ImportPage({super.key, required this.repository, required this.files, this.limits = const ImportLimits()});
  final EntryRepository repository;
  final BackupFiles files;
  final ImportLimits limits;

  @override
  State<ImportPage> createState() => _ImportPageState();
}

enum _Step { pick, password, working, result, damaged, newer, wrongFile, tooLarge, failed }

class _ImportPageState extends State<ImportPage> {
  _Step _step = _Step.pick;
  Uint8List? _file;
  final _pw = TextEditingController();
  bool _shown = false;
  bool _wrongPassword = false;
  int _count = 0;
  ImportOutcome? _outcome;

  @override
  void dispose() {
    _pw.dispose();
    super.dispose();
  }

  Future<void> _choose() async {
    Uint8List? bytes;
    try {
      bytes = await widget.files.pick();
    } catch (_) {
      if (mounted) setState(() => _step = _Step.failed);
      return;
    }
    if (bytes == null || !mounted) return; // cancelled: stay where we are
    _file = bytes;
    _wrongPassword = false;
    _pw.clear();
    await _read(password: null);
  }

  Future<void> _read({required String? password}) async {
    setState(() => _step = _Step.working);
    try {
      final backup = await readBackup(_file!, password: password, limits: widget.limits);
      if (mounted) setState(() => _count = backup.entries.length);
      final outcome = await widget.repository.importEntries(backup.entries);
      if (mounted) {
        setState(() {
          _outcome = outcome;
          _step = _Step.result;
        });
      }
    } on BackupException catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.problem) {
          case BackupProblem.needsPassword:
            _step = _Step.password;
          case BackupProblem.wrongPasswordOrChanged:
            _wrongPassword = true;
            _step = _Step.password;
          case BackupProblem.tooNew:
            _step = _Step.newer;
          case BackupProblem.tooLarge:
            _step = _Step.tooLarge;
          case BackupProblem.damaged:
            // A file that does not even start like a ZIP is "not an export from this
            // app"; one that starts like a ZIP but cannot be read is "damaged".
            final f = _file!;
            final startsLikeZip = f.length >= 4 && f[0] == 0x50 && f[1] == 0x4B && f[2] == 0x03 && f[3] == 0x04;
            _step = e.detail == 'not a journal export' || !startsLikeZip ? _Step.wrongFile : _Step.damaged;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _step = _Step.failed);
    }
  }

  Widget _again(String title, String body) => BackupFrame(
        items: [StatusBody(title: title, body: body)],
        actions: [
          FilledButton(onPressed: _choose, child: Text(S.chooseAnotherFile)),
          const SizedBox(height: AppSpace.s8),
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(S.cancel)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    switch (_step) {
      case _Step.pick:
        return BackupFrame(
          onBack: () => Navigator.of(context).pop(false),
          items: [
            Semantics(header: true, child: Text(S.importTitle, style: AppType.title)),
            const SizedBox(height: AppSpace.s8),
            Text(S.importBody, style: AppType.body.copyWith(color: c.textSecondary)),
          ],
          actions: [FilledButton(onPressed: _choose, child: Text(S.chooseFile))],
        );
      case _Step.password:
        return BackupFrame(
          onBack: () => setState(() => _step = _Step.pick),
          items: [
            Semantics(header: true, child: Text(S.importPasswordTitle, style: AppType.title)),
            const SizedBox(height: AppSpace.s8),
            Text(S.importPasswordBody, style: AppType.body.copyWith(color: c.textSecondary)),
            const SizedBox(height: AppSpace.s24),
            SecretField(
              fieldKey: const Key('import-password'),
              label: S.exportPasswordLabel,
              hint: S.exportPasswordLabel,
              controller: _pw,
              shown: _shown,
              onToggle: () => setState(() => _shown = !_shown),
              error: _wrongPassword ? S.importWrongPassword : null,
              autofocus: true,
              onChanged: (_) => setState(() => _wrongPassword = false),
              onSubmitted: (_) => _pw.text.isEmpty ? null : _read(password: _pw.text),
            ),
          ],
          actions: [
            FilledButton(onPressed: _pw.text.isEmpty ? null : () => _read(password: _pw.text), child: Text(S.importButton)),
          ],
        );
      case _Step.working:
        return BackupFrame(
          items: [
            StatusBody(
              title: S.importWorkingTitle,
              body: S.importWorkingBody,
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
      case _Step.result:
        final o = _outcome!;
        return BackupFrame(
          items: [StatusBody(title: S.importDoneTitle, body: S.importDoneBody(o.added, o.skipped))],
          actions: [FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(S.openMyJournal))],
        );
      case _Step.damaged:
        return _again(S.importDamagedTitle, S.importDamagedBody);
      case _Step.newer:
        return _again(S.importNewerTitle, S.importNewerBody);
      case _Step.wrongFile:
        return _again(S.importWrongFileTitle, S.importWrongFileBody);
      case _Step.tooLarge:
        return _again(S.importTooLargeTitle, S.importTooLargeBody);
      case _Step.failed:
        return _again(S.importFailedTitle, S.importFailedBody);
    }
  }
}
