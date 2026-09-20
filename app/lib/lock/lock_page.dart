import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../security/biometrics.dart';
import '../security/key_vault.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

/// S5 Lock screen (FEAT-003). It never shows journal content in any state.
class LockPage extends StatefulWidget {
  const LockPage({
    super.key,
    required this.vault,
    required this.biometrics,
    required this.onUnlocked,
    this.now,
  });

  final KeyVault vault;
  final Biometrics biometrics;
  final void Function(UnlockedKey) onUnlocked;
  final DateTime Function()? now;

  @override
  State<LockPage> createState() => _LockPageState();
}

/// The data key handed to the app after a successful unlock.
class UnlockedKey {
  UnlockedKey(this.bytes);
  final List<int> bytes;
}

class _LockPageState extends State<LockPage> with WidgetsBindingObserver {
  final _text = TextEditingController();
  final _focus = FocusNode();
  bool _shown = false;
  bool _busy = false;
  bool _wrong = false;
  bool _damaged = false;
  bool _bioEnabled = false;
  DateTime? _until;
  Timer? _tick;
  Duration _left = Duration.zero;
  String _announce = '';

  DateTime get _now => (widget.now ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    final until = await widget.vault.waitingUntil();
    final bio =
        await widget.vault.biometricsEnabled &&
        await widget.biometrics.available;
    if (!mounted) return;
    setState(() => _bioEnabled = bio);
    if (until != null) _startWait(until);
    // Offer the shortcut straight away, like every phone lock screen does.
    if (bio && until == null) unawaited(_useBiometrics());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startWait(DateTime until) {
    _until = until;
    _announce = S.waitMessage(_format(until.difference(_now)));
    _tick?.cancel();
    _update();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  void _update() {
    final until = _until;
    if (until == null) return;
    final left = until.difference(_now);
    if (left <= Duration.zero) {
      _tick?.cancel();
      setState(() {
        _until = null;
        _left = Duration.zero;
      });
    } else {
      setState(() => _left = left);
    }
  }

  String _format(Duration d) {
    final s = d.inSeconds + (d.inMilliseconds % 1000 == 0 ? 0 : 1);
    final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
    return h > 0
        ? '$h:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}'
        : '$m:${sec.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (_busy || _until != null || _text.text.isEmpty) return;
    setState(() {
      _busy = true;
      _wrong = false;
    });
    final result = await widget.vault.unlockWithPasscode(_text.text);
    if (!mounted) return;
    switch (result) {
      case Unlocked(:final dataKey):
        _text.clear();
        widget.onUnlocked(UnlockedKey(dataKey));
        return;
      case WrongPasscode(:final waitSeconds):
        _text.clear();
        setState(() {
          _busy = false;
          _wrong = true;
        });
        if (waitSeconds > 0) {
          _startWait(_now.add(Duration(seconds: waitSeconds)));
        } else {
          _focus.requestFocus(); // keep the keyboard for the next try
        }
      case Waiting(:final until):
        setState(() => _busy = false);
        _startWait(until);
      case VaultDamaged():
        setState(() {
          _busy = false;
          _damaged = true;
        });
    }
  }

  Future<void> _useBiometrics() async {
    if (_busy || _until != null) return;
    final ok = await widget.biometrics.authenticate(S.bioReason);
    if (!ok || !mounted) return;
    final key = await widget.vault.releaseBiometricKey();
    if (key != null && mounted) widget.onUnlocked(UnlockedKey(key));
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final waiting = _until != null;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.screenMargin),
          // With the keyboard open the area is small: drop the logo so the
          // Unlock button stays in view, and let the rest scroll.
          child: LayoutBuilder(
            builder: (context, box) {
              final compact = box.maxHeight < 560;
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!compact) ...[
                        const Center(child: LogoMark()),
                        const SizedBox(height: AppSpace.s24),
                      ],
                      Center(
                        child: Semantics(
                          header: true,
                          child: Text(S.lockTitle, style: AppType.title),
                        ),
                      ),
                      const SizedBox(height: AppSpace.s24),
                      if (_damaged) ...[
                        Text(S.vaultDamagedTitle, style: AppType.label),
                        const SizedBox(height: AppSpace.s4),
                        Text(
                          S.vaultDamagedBody,
                          style: AppType.body.copyWith(color: c.textSecondary),
                        ),
                        const SizedBox(height: AppSpace.s16),
                      ],
                      SecretField(
                        fieldKey: const Key('lock-passcode'),
                        label: S.passcodeLabel,
                        hint: S.lockHint,
                        controller: _text,
                        shown: _shown,
                        onToggle: () => setState(() => _shown = !_shown),
                        enabled: !waiting,
                      readOnly: _busy,
                      focusNode: _focus,
                        error: _wrong && !waiting ? S.wrongPasscode : null,
                        onSubmitted: (_) => _submit(),
                        autofocus: !_bioEnabled,
                      ),
                      if (waiting)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpace.s8),
                          // Announced when it starts and when it ends, not every second.
                          child: Semantics(
                            liveRegion: true,
                            label: _announce,
                            child: ExcludeSemantics(
                              child: Text(
                                S.waitMessage(_format(_left)),
                                style: AppType.caption.copyWith(
                                  color: c.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpace.s16),
                      FilledButton(
                        onPressed: waiting || _busy ? null : _submit,
                        child: Text(_busy ? S.unlocking : S.unlock),
                      ),
                      if (_bioEnabled) ...[
                        const SizedBox(height: AppSpace.s8),
                        TextButton(
                          onPressed: waiting ? null : _useBiometrics,
                          child: Text(S.useBiometrics),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
