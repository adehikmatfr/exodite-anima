// FEAT-011 (Photos) at the repository and file level. Synthetic bytes only,
// standing in for a real decoded/compressed photo.
import 'dart:io';
import 'dart:typed_data';

import 'package:exoditeanima/data/entry_repository.dart';
import 'package:exoditeanima/data/journal_database.dart';
import 'package:exoditeanima/data/media_files.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List key(int seed) => Uint8List.fromList(List.generate(32, (i) => (i * 7 + seed) & 0xff));
Uint8List photoBytes(String marker) => Uint8List.fromList('PHOTO-BYTES-$marker'.codeUnits);

void main() {
  late Directory dir;
  late File dbFile;
  late Directory mediaDir;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('exodite_media_');
    dbFile = File('${dir.path}/journal.db');
    mediaDir = Directory('${dir.path}/media');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Future<(JournalDatabase, EntryRepository)> open() async {
    final db = await JournalDatabase.openEncrypted(dbFile, key(1));
    return (db, EntryRepository(db, mediaDirectory: mediaDir, dataKey: key(1)));
  }

  group('MediaFiles', () {
    test('a written file decrypts back to exactly what was written', () async {
      final files = MediaFiles(mediaDir, key(1));
      await files.write('photo-1', photoBytes('A'));
      expect(await files.read('photo-1'), photoBytes('A'));
    });

    test('the file on disk holds no readable trace of the photo', () async {
      final files = MediaFiles(mediaDir, key(1));
      await files.write('photo-1', photoBytes('SECRET-MARKER'));
      final raw = await files.pathFor('photo-1').readAsBytes();
      expect(String.fromCharCodes(raw), isNot(contains('SECRET-MARKER')));
    });

    test('the wrong key cannot decrypt it', () async {
      final files = MediaFiles(mediaDir, key(1));
      await files.write('photo-1', photoBytes('A'));
      final wrongKeyFiles = MediaFiles(mediaDir, key(2));
      await expectLater(wrongKeyFiles.read('photo-1'), throwsA(anything));
    });

    test('two writes of the same bytes produce different files (fresh nonce each time)', () async {
      final files = MediaFiles(mediaDir, key(1));
      await files.write('photo-1', photoBytes('A'));
      final first = await files.pathFor('photo-1').readAsBytes();
      await files.write('photo-1', photoBytes('A'));
      final second = await files.pathFor('photo-1').readAsBytes();
      expect(first, isNot(second));
    });

    test('delete removes the file, and is not an error when there is nothing to delete', () async {
      final files = MediaFiles(mediaDir, key(1));
      await files.write('photo-1', photoBytes('A'));
      await files.delete('photo-1');
      expect(files.pathFor('photo-1').existsSync(), isFalse);
      await files.delete('photo-1'); // no-op, must not throw
    });
  });

  group('EntryRepository photos', () {
    test('FEAT-011 AC-1: a photo is saved with the entry and read back', () async {
      final (db, repo) = await open();
      final entry = (await repo.create(day: '2026-09-20', body: 'a walk'))!;
      final photo = await repo.addPhoto(entryId: entry.id, bytes: photoBytes('A'), mimeType: 'image/jpeg');
      final photos = await repo.photosFor(entry.id);
      expect(photos.single.uid, photo.uid);
      expect(await repo.readPhotoBytes(photo.uid), photoBytes('A'));
      await db.close();
    });

    test('FEAT-011 AC-9: a caption is saved with the photo, and can be cleared', () async {
      final (db, repo) = await open();
      final entry = (await repo.create(day: '2026-09-20', body: 'a walk'))!;
      final photo = await repo.addPhoto(entryId: entry.id, bytes: photoBytes('A'), mimeType: 'image/jpeg', caption: 'The old oak');
      expect((await repo.photosFor(entry.id)).single.caption, 'The old oak');
      expect(await repo.setPhotoCaption(photo.uid, null), isTrue);
      expect((await repo.photosFor(entry.id)).single.caption, isNull);
      await db.close();
    });

    test('FEAT-011 AC-3: removing a photo deletes its row and its file', () async {
      final (db, repo) = await open();
      final entry = (await repo.create(day: '2026-09-20', body: 'a walk'))!;
      final photo = await repo.addPhoto(entryId: entry.id, bytes: photoBytes('A'), mimeType: 'image/jpeg');
      final path = MediaFiles(mediaDir, key(1)).pathFor(photo.uid);
      expect(path.existsSync(), isTrue);
      await repo.removePhoto(photo.uid);
      expect(await repo.photosFor(entry.id), isEmpty);
      expect(path.existsSync(), isFalse);
      await db.close();
    });

    test('FEAT-011 AC-4: deleting an entry deletes its photos and their files too', () async {
      final (db, repo) = await open();
      final entry = (await repo.create(day: '2026-09-20', body: 'a walk'))!;
      final a = await repo.addPhoto(entryId: entry.id, bytes: photoBytes('A'), mimeType: 'image/jpeg');
      final b = await repo.addPhoto(entryId: entry.id, bytes: photoBytes('B'), mimeType: 'image/jpeg');
      final files = MediaFiles(mediaDir, key(1));
      await repo.delete(entry.id);
      expect(files.pathFor(a.uid).existsSync(), isFalse);
      expect(files.pathFor(b.uid).existsSync(), isFalse);
      await db.close();
    });

    test('two photos on the same entry stay in the order they were added', () async {
      final (db, repo) = await open();
      final entry = (await repo.create(day: '2026-09-20', body: 'a walk'))!;
      final a = await repo.addPhoto(entryId: entry.id, bytes: photoBytes('A'), mimeType: 'image/jpeg');
      final b = await repo.addPhoto(entryId: entry.id, bytes: photoBytes('B'), mimeType: 'image/jpeg');
      final photos = await repo.photosFor(entry.id);
      expect(photos.map((p) => p.uid).toList(), [a.uid, b.uid]);
      await db.close();
    });
  });
}
