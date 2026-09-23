import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data/entry_repository.dart';
import '../l10n/strings.dart';
import '../theme/app_icons.dart';
import '../theme/tokens.dart';

/// S15 Photo viewer: look at one photo full-size, and remove it if the
/// writer wants to (FEAT-011 AC-2, AC-3). Popping true means it was removed,
/// so [PhotoStrip] knows to reload.
class PhotoViewerPage extends StatefulWidget {
  const PhotoViewerPage({super.key, required this.photo, required this.repository});
  final StoredPhoto photo;
  final EntryRepository repository;

  @override
  State<PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  late Future<Uint8List> _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = widget.repository.readPhotoBytes(widget.photo.uid);
  }

  Future<void> _confirmRemove() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.of(context).surfaceRaised,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
      builder: (_) => const _RemoveSheet(),
    );
    if (confirmed == true) {
      await widget.repository.removePhoto(widget.photo.uid);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final caption = widget.photo.caption;
    final accessibleName = caption?.isNotEmpty == true ? caption! : S.photoGenericLabel;
    return Scaffold(
      backgroundColor: c.surfaceBase,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.screenMargin),
              child: Row(
                children: [
                  IconButton(
                    tooltip: S.back,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(AppIcons.back),
                    constraints: const BoxConstraints(minWidth: AppSpace.touchMin, minHeight: AppSpace.touchMin),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _confirmRemove,
                    style: TextButton.styleFrom(foregroundColor: c.dangerFg),
                    child: Text(S.removePhotoAction),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<Uint8List>(
                future: _bytes,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _OpenFailed(name: accessibleName);
                  }
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  return Semantics(
                    label: accessibleName,
                    image: true,
                    excludeSemantics: true,
                    child: Center(
                      child: InteractiveViewer(child: Image.memory(snapshot.data!)),
                    ),
                  );
                },
              ),
            ),
            if (caption != null && caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpace.screenMargin),
                child: Text(caption, style: AppType.body.copyWith(color: c.textPrimary)),
              ),
            const SizedBox(height: AppSpace.s8),
          ],
        ),
      ),
    );
  }
}

/// FEAT-011 AC-8: a photo that fails to open names itself and leaves
/// everything else untouched. No dedicated screen state is drawn for this
/// yet (`.assist/product-design/docs/screen-specs.md`, S15 edge cases); this
/// reuses the app's existing inline-error pattern (`_SaveError` in
/// `editor_page.dart`) rather than introducing a new visual.
class _OpenFailed extends StatelessWidget {
  const _OpenFailed({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpace.screenMargin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.alert, color: c.warningFg, size: 32),
          const SizedBox(height: AppSpace.s8),
          Text(S.photoOpenFailedTitle, style: AppType.label, textAlign: TextAlign.center),
          const SizedBox(height: AppSpace.s4),
          Text(S.photoOpenFailedBody, style: AppType.caption.copyWith(color: c.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _RemoveSheet extends StatelessWidget {
  const _RemoveSheet();

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
            Text(S.removePhotoTitle, style: AppType.title),
            const SizedBox(height: AppSpace.s8),
            Text(S.removePhotoBody, style: AppType.body.copyWith(color: c.textSecondary)),
            const SizedBox(height: AppSpace.s24),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: c.dangerSolid, foregroundColor: c.dangerOnSolid),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(S.removePhotoAction),
            ),
            const SizedBox(height: AppSpace.s8),
            Center(
              child: TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(S.cancel)),
            ),
          ],
        ),
      ),
    );
  }
}
