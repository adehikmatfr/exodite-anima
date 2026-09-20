import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../theme/tokens.dart';

/// S14: the journal cannot be opened (FEAT-001 AC-9, AC-10). It says nothing
/// was deleted. Restoring from an export is FEAT-007, so that action only
/// explains for now.
class CannotOpenPage extends StatelessWidget {
  const CannotOpenPage({super.key, required this.onTryAgain, this.needsUpdate = false});

  final VoidCallback onTryAgain;

  /// True when a newer app version wrote the journal (AC-10): no Try again.
  final bool needsUpdate;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Semantics(
                liveRegion: true,
                header: true,
                child: Text(needsUpdate ? S.tooNewTitle : S.cannotOpenTitle, style: AppType.title),
              ),
              const SizedBox(height: AppSpace.s12),
              Text(
                needsUpdate ? S.tooNewBody : S.cannotOpenBody,
                style: AppType.body.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: AppSpace.s32),
              if (!needsUpdate) ...[
                FilledButton(onPressed: onTryAgain, child: Text(S.tryAgain)),
                const SizedBox(height: AppSpace.s12),
                OutlinedButton(
                  onPressed: () => ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(S.importSoon))),
                  child: Text(S.importJournal),
                ),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
