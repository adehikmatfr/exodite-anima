import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../theme/tokens.dart';
import '../theme/app_icons.dart';

/// The logo mark (option A2): a ring with a core. Ring stroke 0.127 and core
/// 0.244 of the diameter. Decorative, so it is hidden from screen readers.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 64});
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c.actionBg, width: size * 0.127),
              ),
            ),
            Container(
              width: size * 0.244,
              height: size * 0.244,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.actionBg),
            ),
          ],
        ),
      ),
    );
  }
}

/// A labelled secret field with Show and Hide. Paste is allowed so a password
/// manager works; the text is never suggested, autocorrected, or learned.
class SecretField extends StatelessWidget {
  const SecretField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.shown,
    required this.onToggle,
    this.error,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    this.autofocus = false,
    this.onChanged,
    this.fieldKey,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool shown;
  final VoidCallback? onToggle;
  final String? error;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;
  final bool autofocus;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final hasError = error != null;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: hasError ? c.dangerFg : c.borderStrong),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppType.caption.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpace.s4),
        TextField(
          key: fieldKey,
          controller: controller,
          enabled: enabled,
          readOnly: readOnly,
          focusNode: focusNode,
          autofocus: autofocus,
          obscureText: !shown,
          enableSuggestions: false,
          autocorrect: false,
          enableIMEPersonalizedLearning: false,
          keyboardType: TextInputType.visiblePassword,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          style: AppType.body.copyWith(color: c.textPrimary),
          cursorColor: c.actionBg,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppType.body.copyWith(color: c.textSecondary),
            filled: true,
            fillColor: c.surfaceRaised,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.s16, vertical: AppSpace.s16),
            border: border,
            enabledBorder: border,
            disabledBorder: border,
            focusedBorder: border.copyWith(borderSide: BorderSide(color: hasError ? c.dangerFg : c.focusRing, width: 2)),
            suffixIcon: onToggle == null
                ? null
                : Semantics(
                    button: true,
                    label: shown ? S.hidePasscode : S.showPasscode,
                    excludeSemantics: true,
                    child: TextButton(
                      onPressed: onToggle,
                      child: Text(shown ? S.hide : S.show),
                    ),
                  ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.s4),
            child: Semantics(
              liveRegion: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(AppIcons.alert, size: 16, color: c.dangerFg),
                  const SizedBox(width: AppSpace.s4),
                  Expanded(child: Text(error!, style: AppType.caption.copyWith(color: c.dangerFg))),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
