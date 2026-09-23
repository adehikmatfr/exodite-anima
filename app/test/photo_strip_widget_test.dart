// FEAT-011 at the widget level: the photo strip (S7 "With photos") and the
// photo viewer (S15), matching the design in
// `product-design/tools/gen_screens.py`. `image_picker`'s platform channel is
// never exercised here - only `pickPhotoSource` (a plain bottom sheet) and
// the repository-facing parts are, the same split `_addPhoto` in
// `editor_page.dart` uses.
import 'dart:io';
import 'dart:typed_data';

import 'package:exoditeanima/data/entry_repository.dart';
import 'package:exoditeanima/data/journal_database.dart';
import 'package:exoditeanima/journal/photo_strip.dart';
import 'package:exoditeanima/journal/photo_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

Uint8List key(int seed) => Uint8List.fromList(List.generate(32, (i) => (i * 7 + seed) & 0xff));

/// A real, valid 1x1 transparent PNG - `Image.memory` (unlike a bare byte
/// list) needs genuine image data to decode, since these tests render the
/// actual widget tree, not just the repository.
final Uint8List onePixelPng = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  /// Encrypting, decrypting, and deleting a photo file are real file and CPU
  /// work (`MediaFiles`, AES-GCM) - `testWidgets` runs the test body under a
  /// fake clock, where real I/O futures never get to complete no matter how
  /// much fake time is pumped, so a plain `await` or `pumpAndSettle` on
  /// their result would wait forever. `tester.runAsync` steps outside the
  /// fake clock for a moment; used here both to run such a call directly,
  /// and (polling) to let a `FutureBuilder`'s real future resolve and the
  /// widget rebuild to pick it up.
  Future<T> real<T>(WidgetTester tester, Future<T> Function() body) async {
    final result = await tester.runAsync(body);
    if (result == null) throw StateError('runAsync returned null');
    return result;
  }

  Future<void> pumpRealUntil(WidgetTester tester, bool Function() done) async {
    await tester.runAsync(() async {
      for (var i = 0; i < 50 && !done(); i++) {
        await Future.delayed(const Duration(milliseconds: 20));
        await tester.pump();
      }
    });
  }

  late Directory dir;
  late JournalDatabase db;
  late EntryRepository repo;
  late JournalEntry entry;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('exodite_photo_widget_');
    db = await JournalDatabase.openEncrypted(File('${dir.path}/journal.db'), key(1));
    repo = EntryRepository(db, mediaDirectory: Directory('${dir.path}/media'), dataKey: key(1));
    entry = (await repo.create(day: '2026-09-20', body: 'a walk'))!;
  });
  tearDown(() async {
    // `tearDown` runs under the same fake clock as the test body; closing
    // the database is real file I/O (like the photo reads/writes above) and
    // needs the real zone too, or Windows can still be holding the file
    // when the directory delete below runs right after.
    await TestWidgetsFlutterBinding.instance.runAsync(() async {
      await db.close();
      for (var i = 0; i < 20; i++) {
        try {
          dir.deleteSync(recursive: true);
          break;
        } on PathAccessException {
          if (i == 19) rethrow;
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    });
  });

  testWidgets('the "Add photo" button offers the camera and the library', (tester) async {
    ImageSource? chosen;
    await tester.pumpWidget(
      wrap(PhotoStrip(
        photos: const [],
        repository: repo,
        onAdd: (source) async => chosen = source,
        onChanged: () {},
      )),
    );

    await tester.tap(find.text('Add photo'));
    await tester.pumpAndSettle();
    expect(find.text('Take a photo'), findsOneWidget);
    expect(find.text('Choose from library'), findsOneWidget);

    await tester.tap(find.text('Choose from library'));
    await tester.pumpAndSettle();
    expect(chosen, ImageSource.gallery);
  });

  testWidgets('a photo thumbnail shows the decrypted image and opens the viewer on tap', (tester) async {
    final photo = await real(tester, () => repo.addPhoto(entryId: entry.id, bytes: onePixelPng, mimeType: 'image/jpeg', caption: 'The old oak'));
    await tester.pumpWidget(
      wrap(PhotoStrip(photos: [photo], repository: repo, onAdd: (_) async {}, onChanged: () {})),
    );
    await pumpRealUntil(tester, () => find.byType(Image).evaluate().isNotEmpty);
    expect(find.byType(Image), findsOneWidget);

    await tester.tap(find.byType(Image));
    await tester.pump();
    await pumpRealUntil(tester, () => find.byType(PhotoViewerPage).evaluate().isNotEmpty && find.text('The old oak').evaluate().isNotEmpty);
    expect(find.byType(PhotoViewerPage), findsOneWidget);
    expect(find.text('The old oak'), findsOneWidget);
  });

  testWidgets('FEAT-011 AC-3: removing a photo from the viewer deletes it and returns to the editor', (tester) async {
    final photo = await real(tester, () => repo.addPhoto(entryId: entry.id, bytes: onePixelPng, mimeType: 'image/jpeg'));
    await tester.pumpWidget(wrap(PhotoViewerPage(photo: photo, repository: repo)));
    await pumpRealUntil(tester, () => find.byType(Image).evaluate().isNotEmpty);

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Remove this photo?'), findsOneWidget);

    await tester.tap(find.text('Remove').last);
    await pumpRealUntil(tester, () => find.byType(PhotoViewerPage).evaluate().isEmpty);

    expect(await real(tester, () => repo.photosFor(entry.id)), isEmpty);
  });

  testWidgets('cancelling the remove sheet keeps the photo', (tester) async {
    final photo = await real(tester, () => repo.addPhoto(entryId: entry.id, bytes: onePixelPng, mimeType: 'image/jpeg'));
    await tester.pumpWidget(wrap(PhotoViewerPage(photo: photo, repository: repo)));
    await pumpRealUntil(tester, () => find.byType(Image).evaluate().isNotEmpty);

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await real(tester, () => repo.photosFor(entry.id)), hasLength(1));
  });
}
