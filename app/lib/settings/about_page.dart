import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../theme/tokens.dart';
import '../theme/app_icons.dart';

/// S13 About and privacy. Every claim here is backed by a control and a test;
/// `.assist/product-design/docs/screen-specs.md` (S13) and the QA case TC-081
/// list them. A claim with nothing behind it is removed.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final points = [S.aboutPoint1, S.aboutPoint2, S.aboutPoint3, S.aboutPoint4];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.screenMargin),
          child: ListView(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: S.back,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(AppIcons.back),
                  constraints: const BoxConstraints(minWidth: AppSpace.touchMin, minHeight: AppSpace.touchMin),
                ),
              ),
              Semantics(header: true, child: Text(S.aboutTitle, style: AppType.title)),
              const SizedBox(height: AppSpace.s16),
              Semantics(
                container: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final p in points)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.s12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 9, right: AppSpace.s12),
                              child: Container(width: 6, height: 6, decoration: BoxDecoration(color: c.actionBg, shape: BoxShape.circle)),
                            ),
                            Expanded(child: Text(p, style: AppType.body)),
                          ],
                        ),
                      ),
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
