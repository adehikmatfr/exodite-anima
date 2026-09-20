import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../theme/app_icons.dart';

/// A full-screen page: back button, scrolling content, actions pinned at the bottom.
class BackupFrame extends StatelessWidget {
  const BackupFrame({super.key, this.onBack, required this.items, this.actions = const []});
  final VoidCallback? onBack;
  final List<Widget> items;
  final List<Widget> actions;

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
                child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items)),
              ),
              if (actions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.s12, bottom: AppSpace.s16),
                  child: Column(mainAxisSize: MainAxisSize.min, children: actions),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A centred message with the logo mark: results, errors, progress.
class StatusBody extends StatelessWidget {
  const StatusBody({super.key, required this.title, this.body, this.extra});
  final String title;
  final String? body;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppSpace.s48),
        const LogoMark(),
        const SizedBox(height: AppSpace.s24),
        Semantics(liveRegion: true, header: true, child: Text(title, style: AppType.title, textAlign: TextAlign.center)),
        if (body != null) ...[
          const SizedBox(height: AppSpace.s8),
          Text(body!, style: AppType.body.copyWith(color: c.textSecondary), textAlign: TextAlign.center),
        ],
        if (extra != null) ...[const SizedBox(height: AppSpace.s24), extra!],
      ],
    );
  }
}

/// One of two or more choices; the whole card is the control.
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({super.key, required this.title, required this.note, required this.selected, required this.onTap});
  final String title;
  final String note;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      button: true,
      label: '$title. $note',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: AppSpace.touchMin),
          padding: const EdgeInsets.all(AppSpace.s16),
          decoration: BoxDecoration(
            color: c.surfaceRaised,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: selected ? c.focusRing : c.borderStrong, width: selected ? 2 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(selected ? AppIcons.radioOn : AppIcons.radioOff,
                  color: selected ? c.actionBg : c.borderStrong, size: 22),
              const SizedBox(width: AppSpace.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppType.label),
                    const SizedBox(height: AppSpace.s4),
                    Text(note, style: AppType.caption.copyWith(color: c.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
