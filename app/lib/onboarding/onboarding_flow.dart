import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../security/biometrics.dart';
import '../security/passcode_rules.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../theme/app_icons.dart';

/// First run: S1 Welcome, S2 Create passcode, S3 Biometrics, S4 No-recovery
/// warning (FEAT-004). Nothing is created until the user acknowledges S4, so
/// leaving early leaves no journal behind (AC-1, AC-4).
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, required this.biometrics, required this.onComplete, required this.onImport});

  final Biometrics biometrics;

  /// Called once, after S4 is acknowledged, with the chosen passcode and whether
  /// the user turned biometrics on.
  final Future<void> Function(String passcode, bool biometricsOn) onComplete;

  /// The restore path (FEAT-007); passcode setup comes first, so this only explains for now.
  final VoidCallback onImport;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

enum _Step { welcome, passcode, biometrics, warning }

class _OnboardingFlowState extends State<OnboardingFlow> {
  _Step _step = _Step.welcome;
  String _passcode = '';
  bool _bioOn = false;
  bool _bioAvailable = false;
  bool _busy = false;

  void _go(_Step s) => setState(() => _step = s);

  void _back() {
    switch (_step) {
      case _Step.welcome:
        break;
      case _Step.passcode:
        _go(_Step.welcome);
      case _Step.biometrics:
        _go(_Step.passcode);
      case _Step.warning:
        _go(_Step.biometrics);
    }
  }

  Future<void> _afterPasscode(String value) async {
    _passcode = value;
    _bioAvailable = await widget.biometrics.available;
    if (mounted) _go(_Step.biometrics);
  }

  Future<void> _turnOnBiometrics() async {
    final ok = await widget.biometrics.authenticate(S.bioReason);
    _bioOn = ok;
    if (mounted) _go(_Step.warning);
  }

  Future<void> _finish() async {
    setState(() => _busy = true);
    await widget.onComplete(_passcode, _bioOn);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == _Step.welcome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: switch (_step) {
        _Step.welcome => _Welcome(
            onStart: () => _go(_Step.passcode),
            // Restore: the passcode is set first, then the import starts (FEAT-007 AC-9).
            onImport: () {
              widget.onImport();
              _go(_Step.passcode);
            },
          ),
        _Step.passcode => _CreatePasscode(onBack: _back, onContinue: _afterPasscode, initial: _passcode),
        _Step.biometrics => _Biometrics(
            available: _bioAvailable,
            onBack: _back,
            onTurnOn: _turnOnBiometrics,
            onSkip: () {
              _bioOn = false;
              _go(_Step.warning);
            },
          ),
        _Step.warning => _Warning(onBack: _back, onStart: _finish, busy: _busy),
      },
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.items, this.onBack, this.bottom});
  final List<Widget> items;
  final VoidCallback? onBack;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (onBack != null)
                IconButton(
                  tooltip: S.back,
                  onPressed: onBack,
                  icon: const Icon(AppIcons.back),
                  constraints: const BoxConstraints(minWidth: AppSpace.touchMin, minHeight: AppSpace.touchMin),
                )
              else
                const SizedBox(height: AppSpace.s16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
                ),
              ),
              if (bottom != null) Padding(padding: const EdgeInsets.only(top: AppSpace.s12, bottom: AppSpace.s16), child: bottom),
            ],
          ),
        ),
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onStart, required this.onImport});
  final VoidCallback onStart;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    Widget point(String s) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpace.s8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, right: AppSpace.s12),
                child: Container(width: 6, height: 6, decoration: BoxDecoration(color: c.actionBg, shape: BoxShape.circle)),
              ),
              Expanded(child: Text(s, style: AppType.body)),
            ],
          ),
        );
    return _Frame(
      items: [
        const SizedBox(height: AppSpace.s48),
        const LogoMark(),
        const SizedBox(height: AppSpace.s24),
        Semantics(header: true, child: Text(S.welcomeTitle, style: AppType.display)),
        const SizedBox(height: AppSpace.s12),
        Text(S.welcomeBody, style: AppType.body.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpace.s24),
        point(S.welcomePoint1),
        point(S.welcomePoint2),
        point(S.welcomePoint3),
      ],
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(onPressed: onStart, child: Text(S.getStarted)),
          const SizedBox(height: AppSpace.s8),
          TextButton(onPressed: onImport, child: Text(S.importJournal)),
        ],
      ),
    );
  }
}

class _CreatePasscode extends StatefulWidget {
  const _CreatePasscode({required this.onBack, required this.onContinue, required this.initial});
  final VoidCallback onBack;
  final Future<void> Function(String) onContinue;
  final String initial;

  @override
  State<_CreatePasscode> createState() => _CreatePasscodeState();
}

class _CreatePasscodeState extends State<_CreatePasscode> {
  late final _first = TextEditingController(text: widget.initial);
  late final _second = TextEditingController(text: widget.initial);
  bool _shown = false;
  bool _touchedFirst = false;
  bool _touchedSecond = false;

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  String? get _firstError {
    if (!_touchedFirst || _first.text.isEmpty) return null;
    return switch (checkPasscode(_first.text)) {
      PasscodeProblem.tooShort => S.passcodeTooShort,
      PasscodeProblem.tooCommon => S.passcodeTooCommon,
      null => null,
    };
  }

  /// Shown as soon as what was typed cannot be the start of the first passcode.
  String? get _secondError => _second.text.isNotEmpty && !_first.text.startsWith(_second.text)
      ? S.passcodeMismatch
      : (_touchedSecond && _second.text != _first.text ? S.passcodeMismatch : null);

  bool get _valid => _first.text.isNotEmpty && checkPasscode(_first.text) == null && _first.text == _second.text;

  void _continue() {
    setState(() {
      _touchedFirst = true;
      _touchedSecond = true;
    });
    if (_valid) widget.onContinue(_first.text);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return _Frame(
      onBack: widget.onBack,
      items: [
        Semantics(header: true, child: Text(S.passcodeTitle, style: AppType.title)),
        const SizedBox(height: AppSpace.s8),
        Text(S.passcodeBody, style: AppType.body.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpace.s24),
        SecretField(
          fieldKey: const Key('passcode'),
          label: S.passcodeLabel,
          hint: S.passcodeHint,
          controller: _first,
          shown: _shown,
          onToggle: () => setState(() => _shown = !_shown),
          error: _firstError,
          autofocus: true,
          onChanged: (_) => setState(() => _touchedFirst = _touchedFirst || _first.text.length >= 8),
        ),
        const SizedBox(height: AppSpace.s16),
        SecretField(
          fieldKey: const Key('repeat'),
          label: S.repeatLabel,
          hint: S.repeatHint,
          controller: _second,
          shown: _shown,
          onToggle: null,
          error: _secondError,
          onChanged: (_) => setState(() => _touchedSecond = _second.text.length >= _first.text.length),
          onSubmitted: (_) => _continue(),
        ),
        const SizedBox(height: AppSpace.s12),
        Text(S.passcodeHelper, style: AppType.caption.copyWith(color: c.textSecondary)),
      ],
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_valid)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.s8),
              child: Text(S.passcodeNeeded, style: AppType.caption.copyWith(color: c.textSecondary)),
            ),
          FilledButton(onPressed: _valid ? _continue : null, child: Text(S.continueLabel)),
        ],
      ),
    );
  }
}

class _Biometrics extends StatelessWidget {
  const _Biometrics({required this.available, required this.onBack, required this.onTurnOn, required this.onSkip});
  final bool available;
  final VoidCallback onBack;
  final VoidCallback onTurnOn;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return _Frame(
      onBack: onBack,
      items: [
        const SizedBox(height: AppSpace.s48),
        const LogoMark(),
        const SizedBox(height: AppSpace.s24),
        Semantics(
          header: true,
          child: Text(available ? S.bioTitle : S.bioMissingTitle, style: AppType.title),
        ),
        const SizedBox(height: AppSpace.s12),
        Text(available ? S.bioBody : S.bioMissingBody, style: AppType.body.copyWith(color: c.textSecondary)),
      ],
      bottom: available
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton(onPressed: onTurnOn, child: Text(S.bioTurnOn)),
                const SizedBox(height: AppSpace.s8),
                TextButton(onPressed: onSkip, child: Text(S.bioNotNow)),
              ],
            )
          : FilledButton(onPressed: onSkip, child: Text(S.continueLabel)),
    );
  }
}

class _Warning extends StatefulWidget {
  const _Warning({required this.onBack, required this.onStart, required this.busy});
  final VoidCallback onBack;
  final VoidCallback onStart;
  final bool busy;

  @override
  State<_Warning> createState() => _WarningState();
}

class _WarningState extends State<_Warning> {
  bool _ack = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return _Frame(
      onBack: widget.busy ? null : widget.onBack,
      items: [
        Semantics(header: true, child: Text(S.warnTitle, style: AppType.title)),
        const SizedBox(height: AppSpace.s16),
        Semantics(
          container: true,
          label: S.important,
          child: Container(
            width: double.infinity,
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
                const SizedBox(height: AppSpace.s8),
                Text(S.warnBody1, style: AppType.body),
                const SizedBox(height: AppSpace.s12),
                Text(S.warnBody2, style: AppType.body),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.s16),
        // The whole row is the control (56 high).
        InkWell(
          onTap: widget.busy ? null : () => setState(() => _ack = !_ack),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Row(
              children: [
                Checkbox(value: _ack, onChanged: widget.busy ? null : (v) => setState(() => _ack = v ?? false)),
                Expanded(child: Text(S.warnCheck, style: AppType.body)),
              ],
            ),
          ),
        ),
      ],
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_ack)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.s8),
              child: Text(S.warnNeeded, style: AppType.caption.copyWith(color: c.textSecondary)),
            ),
          FilledButton(
            onPressed: _ack && !widget.busy ? widget.onStart : null,
            child: Text(widget.busy ? S.settingUp : S.startJournaling),
          ),
        ],
      ),
    );
  }
}
