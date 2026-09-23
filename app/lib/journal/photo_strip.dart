import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../data/entry_repository.dart';
import '../l10n/strings.dart';
import '../theme/app_icons.dart';
import '../theme/tokens.dart';
import 'photo_viewer_page.dart';

/// A photo already picked, compressed by the picker itself, and ready for
/// [EntryRepository.addPhoto] (FEAT-011 AC-1). Compression happens here, at
/// pick time, via `image_picker`'s own resize/re-encode - not as a separate
/// step, since the platform picker already does this natively and `dart:ui`
/// cannot encode JPEG itself.
Future<(Uint8List, String)?> pickCompressedPhoto(ImageSource source) async {
  final picked = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 82);
  if (picked == null) return null;
  final bytes = await picked.readAsBytes();
  return (bytes, _mimeTypeFor(picked.path));
}

String _mimeTypeFor(String path) {
  switch (p.extension(path).toLowerCase()) {
    case '.png':
      return 'image/png';
    case '.heic':
      return 'image/heic';
    case '.webp':
      return 'image/webp';
    default:
      return 'image/jpeg';
  }
}

/// Lets the writer choose the camera or the photo library (FEAT-011 AC-1,
/// both sources accepted per the owner's decision 2026-09-23).
Future<ImageSource?> pickPhotoSource(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: AppColors.of(context).surfaceRaised,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(AppIcons.camera),
            title: Text(S.takePhoto),
            onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(AppIcons.image),
            title: Text(S.chooseFromLibrary),
            onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
}

/// S7 "With photos": a thumbnail row plus an "Add photo" button (FEAT-011).
/// Thumbnails are decrypted and decoded on demand; there are never more than
/// a handful in view on this screen at once, unlike the timeline (FEAT-002
/// AC-4's 20,000-entry target is a timeline concern, not an editor one).
class PhotoStrip extends StatelessWidget {
  const PhotoStrip({
    super.key,
    required this.photos,
    required this.repository,
    required this.onAdd,
    required this.onChanged,
  });

  final List<StoredPhoto> photos;
  final EntryRepository repository;
  final Future<void> Function(ImageSource source) onAdd;
  final VoidCallback onChanged;

  Future<void> _open(BuildContext context, StoredPhoto photo) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PhotoViewerPage(photo: photo, repository: repository)),
    );
    onChanged();
  }

  Future<void> _addFrom(BuildContext context) async {
    final source = await pickPhotoSource(context);
    if (source == null) return;
    await onAdd(source);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final photo in photos)
            Padding(
              padding: const EdgeInsets.only(right: AppSpace.s8),
              child: _Thumbnail(photo: photo, repository: repository, onTap: () => _open(context, photo)),
            ),
          _AddPhotoButton(onTap: () => _addFrom(context)),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.photo, required this.repository, required this.onTap});
  final StoredPhoto photo;
  final EntryRepository repository;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Semantics(
      button: true,
      label: photo.caption?.isNotEmpty == true ? photo.caption! : S.photoGenericLabel,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            width: 72,
            height: 72,
            color: c.surfaceRaised,
            child: FutureBuilder<Uint8List>(
              future: repository.readPhotoBytes(photo.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Icon(AppIcons.image, color: c.textSecondary);
                if (!snapshot.hasData) return const SizedBox.shrink();
                return Image.memory(snapshot.data!, fit: BoxFit.cover, width: 72, height: 72);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  const _AddPhotoButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Semantics(
      button: true,
      label: S.addPhoto,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: c.borderStrong),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.add, color: c.textSecondary),
              const SizedBox(height: AppSpace.s4),
              Text(S.addPhoto, style: AppType.caption.copyWith(color: c.textSecondary), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
