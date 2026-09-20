import 'dart:async';

import 'package:flutter/material.dart';

import '../backup/backup_widgets.dart';
import '../l10n/strings.dart';
import '../security/key_vault.dart';
import '../security/passcode_rules.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'settings_controller.dart';

/// S10 Change passcode (FEAT-009). The current passcode is checked with the same
/// wait after wrong tries as the lock screen; the journal key does not change,
/// so every entry stays readable.
class ChangePasscodePage extends StatefulWidget {
  const ChangePasscodePage({super.key, required this.settings, this.now});
  final SettingsController settings;
  final DateTime Function()? now;

  @override
  State<ChangePasscodePage> createState() => _ChangePasscodePageState();
}

enum _Step { form, working, done }

class _ChangePasscodePageState extends State<ChangePasscodePage> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _repeat = TextEditingController();
  bool _shown = false;
  _Step _step = _Step.form;
  String? _currentError;
  String? _failure;
  DateTime? _waitUntil;
  Timer? _tick;
  Duration _left = Duration.zero;

  DateTime get _now => (widget.now ?? DateTime.now)();

  @override
  void dispose() {
    _tick?.cancel();
    _current.dispose();
    _new.dispose();
    _repeat.dispose();
    super.dispose();
  }

  PasscodeProblem? get _problem => _new.text.isEmpty ? null : checkPasscode(_new.text);
  /// Shown as soon as what was typed cannot be the start of the new passcode.
  bool get _mismatch => _repeat.text.isNotEmpty && (!_new.text.startsWith(_repeat.text) || _repeat.text.length > _new.text.length);
  bool get _valid => _current.text.isNotEmpty && _new.text.isNotEmpty && checkPasscode(_new.text) == null && _new.text == _repeat.text;

  void _startWait(DateTime until) {
    _waitUntil = until;
    _tick?.cancel();
    _update();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  void _update() {
    final until = _waitUntil;
    if (until == null) return;
    final left = until.difference(_now);
    if (!mounted) return;
    if (left <= Duration.zero) {
      _tick?.cancel();
      setState(() {
        _waitUntil = null;
        _left = Duration.zero;
      });
    } else {
      setState(() => _left = left);
    }
  }

  String _format(Duration d) {
    final s = d.inSeconds + (d.inMilliseconds % 1000 == 0 ? 0 : 1);
    final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
    return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}' : '$m:${sec.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (!_valid || _waitUntil != null) return;
    setState(() {
      _step = _Step.working;
      _currentError = null;
      _failure = null;
    });
    final r = await widget.settings.changePasscode(_current.text, _new.text);
    if (!mounted) return;
    switch (r) {
      case ChangeDone():
        setState(() => _step = _Step.done);
      case ChangeWrongCurrent(:final waitSeconds):
        setState(() {
          _step = _Step.form;
          _currentError = S.currentPasscodeWrong;
          _current.clear();
        });
        if (waitSeconds > 0) _startWait(_now.add(Duration(seconds: waitSeconds)));
      case ChangeWaiting(:final until):
        setState(() => _step = _Step.form);
        _startWait(until);
      case ChangeFailed():
        setState(() {
          _step = _Step.form;
          _failure = S.passcodeChangeFailed;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    if (_step == _Step.done) {
      return BackupFrame(
        items: [StatusBody(title: S.passcodeChangedTitle, body: S.passcodeChangedBody)],
        actions: [FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(S.done))],
      );
    }
    final waiting = _waitUntil != null;
    final busy = _step == _Step.working;
    return BackupFrame(
      onBack: busy ? null : () => Navigator.of(context).pop(),
      items: [
        Semantics(header: true, child: Text(S.changePasscode, style: AppType.title)),
        const SizedBox(height: AppSpace.s24),
        SecretField(
          fieldKey: const Key('current-passcode'),
          label: S.currentPasscode,
          hint: S.currentPasscodeHint,
          controller: _current,
          shown: _shown,
          onToggle: () => setState(() => _shown = !_shown),
          error: waiting ? null : _currentError,
          enabled: !waiting,
          readOnly: busy,
          autofocus: true,
          onChanged: (_) => setState(() => _currentError = null),
        ),
        if (waiting)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.s8),
            child: Text(S.waitMessage(_format(_left)), style: AppType.caption.copyWith(color: c.textSecondary)),
          ),
        const SizedBox(height: AppSpace.s16),
        SecretField(
          fieldKey: const Key('new-passcode'),
          label: S.newPasscode,
          hint: S.newPasscodeHint,
          controller: _new,
          shown: _shown,
          onToggle: null,
          error: switch (_problem) {
            PasscodeProblem.tooShort => _new.text.length >= 3 ? S.passcodeTooShort : null,
            PasscodeProblem.tooCommon => S.passcodeTooCommon,
            null => null,
          },
          readOnly: busy,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpace.s4),
        Text(S.passcodeHelper, style: AppType.caption.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpace.s16),
        SecretField(
          fieldKey: const Key('repeat-new-passcode'),
          label: S.repeatNewPasscode,
          hint: S.repeatHint,
          controller: _repeat,
          shown: _shown,
          onToggle: null,
          error: _mismatch ? S.passcodeMismatch : null,
          readOnly: busy,
          onChanged: (_) => setState(() {}),
        ),
        if (_failure != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.s12),
            child: Semantics(liveRegion: true, child: Text(_failure!, style: AppType.caption.copyWith(color: c.dangerFg))),
          ),
      ],
      actions: [
        FilledButton(onPressed: _valid && !waiting && !busy ? _submit : null, child: Text(S.changePasscodeButton)),
      ],
    );
  }
}
