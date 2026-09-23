// FEAT-006 (export) and FEAT-007 (import) at the file-format level.
// Synthetic entries and made-up passwords only; small key-derivation settings for speed.
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:exoditeanima/backup/backup_service.dart';
import 'package:exoditeanima/backup/envelope.dart';
import 'package:exoditeanima/backup/zip_lite.dart';
import 'package:exoditeanima/data/entry_repository.dart';
import 'package:exoditeanima/data/journal_database.dart';
import 'package:flutter_test/flutter_test.dart';

const fast = EnvelopeParams(memoryKiB: 1024, iterations: 1, lanes: 1);
const pw = 'export password 1';

StoredEntry entry(int i, {String? text, Mood? mood, List<String> tags = const []}) => StoredEntry(
      uid: i.toRadixString(16).padLeft(32, '0'),
      day: '2026-09-${(i % 28 + 1).toString().padLeft(2, '0')}',
      text: text ?? 'Synthetic entry $i. Zebra-$i.',
      createdAtMs: DateTime.utc(2026, 9, 1).millisecondsSinceEpoch + i * 1000,
      updatedAtMs: DateTime.utc(2026, 9, 1).millisecondsSinceEpoch + i * 2000,
      mood: mood,
      tags: tags,
    );

bool has(Uint8List data, String needle) {
  final n = utf8.encode(needle);
  outer:
  for (var i = 0; i <= data.length - n.length; i++) {
    for (var j = 0; j < n.length; j++) {
      if (data[i + j] != n[j]) continue outer;
    }
    return true;
  }
  return false;
}

Future<BackupProblem?> problemOf(Future<Object?> Function() run) async {
  try {
    await run();
    return null;
  } on BackupException catch (e) {
    return e.problem;
  }
}

void main() {
  final entries = [for (var i = 1; i <= 25; i++) entry(i)];

  group('round trip', () {
    test('an encrypted export imports back with the same text, dates and ids (FEAT-007 AC-1)', () async {
      final file = await createBackup(entries, password: pw, params: fast);
      final back = await readBackup(file, password: pw);
      expect(back.entries.length, entries.length);
      for (var i = 0; i < entries.length; i++) {
        expect(back.entries[i].uid, entries[i].uid);
        expect(back.entries[i].day, entries[i].day);
        expect(back.entries[i].text, entries[i].text);
        expect(back.entries[i].createdAtMs, entries[i].createdAtMs);
        expect(back.entries[i].updatedAtMs, entries[i].updatedAtMs);
      }
    });

    test('FEAT-010 AC-7, AC-8: mood and tags survive an export/import round trip exactly', () async {
      final withMeta = [
        entry(1, text: 'has mood and tags', mood: Mood.good, tags: const ['Family', 'photography']),
        entry(2, text: 'has neither'),
        entry(3, text: 'a tag with a comma', tags: const ['coffee, tea, and books']),
      ];
      final file = await createBackup(withMeta, password: pw, params: fast);
      final back = await readBackup(file, password: pw);
      expect(back.entries[0].mood, Mood.good);
      expect(back.entries[0].tags, ['Family', 'photography']);
      expect(back.entries[1].mood, isNull);
      expect(back.entries[1].tags, isEmpty);
      expect(back.entries[2].tags, ['coffee, tea, and books']);
    });

    test('FEAT-010: an export made before this feature (no mood or tags field) still imports, with neither set', () async {
      final noMeta = jsonEncode({
        'formatVersion': currentFormatVersion,
        'schemaVersion': 1,
        'entries': [
          {
            'id': entries[0].uid,
            'entryDate': entries[0].day,
            'createdAt': DateTime.fromMillisecondsSinceEpoch(entries[0].createdAtMs, isUtc: true).toIso8601String(),
            'updatedAt': DateTime.fromMillisecondsSinceEpoch(entries[0].updatedAtMs, isUtc: true).toIso8601String(),
            'text': entries[0].text,
          },
        ],
      });
      final entriesBytes = Uint8List.fromList(utf8.encode(noMeta));
      final manifest = jsonEncode({
        'format': backupFormatName,
        'formatVersion': currentFormatVersion,
        'schemaVersion': 1,
        'appVersion': appVersionText,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'entryCount': 1,
        'entriesSha256': sha256Hex(entriesBytes),
      });
      final zip = writeZip([
        ZipEntry('manifest.json', Uint8List.fromList(utf8.encode(manifest))),
        ZipEntry('entries.json', entriesBytes),
      ]);
      final back = await readBackup(zip);
      expect(back.entries.single.mood, isNull);
      expect(back.entries.single.tags, isEmpty);
    });

    test('a plaintext export imports back the same way, and holds readable Markdown (FEAT-006 AC-3 content)', () async {
      final file = await createBackup(entries);
      final back = await readBackup(file);
      expect(back.entries.map((e) => e.text).toList(), entries.map((e) => e.text).toList());
      final md = readZipFiles(file, {'entries/2026/${entries[1].day}-${entries[1].uid}.md'});
      expect(utf8.decode(md.values.single), contains('Zebra-2'));
    });

    test('text with quotes, line breaks, emoji and other scripts survives', () async {
      const odd = 'Line one\n"quoted" \\ backslash\n日本語 — Bahasa: “kutipan” 😀\u0000end';
      final file = await createBackup([entry(1, text: odd)], password: pw, params: fast);
      final back = await readBackup(file, password: pw);
      expect(back.entries.single.text, odd);
    });

    test('an empty journal exports and imports', () async {
      final file = await createBackup(const [], password: pw, params: fast);
      expect((await readBackup(file, password: pw)).entries, isEmpty);
    });

    test('the manifest count equals the number of entries (FEAT-006 AC-4)', () async {
      final file = await createBackup(entries);
      final manifest = jsonDecode(utf8.decode(readZipFiles(file, {'manifest.json'})['manifest.json']!)) as Map<String, dynamic>;
      expect(manifest['entryCount'], 25);
      expect(manifest['formatVersion'], 1);
      expect(manifest['schemaVersion'], journalSchemaVersion);
    });
  });

  group('encryption', () {
    test('an encrypted export holds no entry text and no file names (FEAT-006 AC-1)', () async {
      final file = await createBackup(entries, password: pw, params: fast);
      expect(isEncryptedBackup(file), isTrue);
      expect(has(file, 'Zebra-'), isFalse);
      expect(has(file, 'Synthetic'), isFalse);
      expect(has(file, 'entries.json'), isFalse);
      expect(has(file, 'manifest'), isFalse);
    });

    test('without a password nothing is read; a wrong password reveals nothing (FEAT-006 AC-2, FEAT-007 AC-2)', () async {
      final file = await createBackup(entries, password: pw, params: fast);
      expect(await problemOf(() => readBackup(file)), BackupProblem.needsPassword);
      expect(await problemOf(() => readBackup(file, password: 'a different password')), BackupProblem.wrongPasswordOrChanged);
    });

    test('two exports of the same journal differ (fresh salt and nonce)', () async {
      final a = await createBackup(entries, password: pw, params: fast);
      final b = await createBackup(entries, password: pw, params: fast);
      expect(a, isNot(b));
    });

    test('a changed byte anywhere, including the header, is refused (FEAT-007 AC-3)', () async {
      final file = await createBackup(entries, password: pw, params: fast);
      for (final at in [3, 9, 20, 40, 47, file.length ~/ 2, file.length - 1]) {
        final copy = Uint8List.fromList(file);
        copy[at] ^= 0x01;
        final problem = await problemOf(() => readBackup(copy, password: pw));
        expect(problem, isNotNull, reason: 'byte $at');
      }
    });

    test('a cut-off file is refused at every length', () async {
      final file = await createBackup(entries, password: pw, params: fast);
      for (final cut in [0, 5, 46, 47, 60, file.length ~/ 2, file.length - 1]) {
        final problem = await problemOf(() => readBackup(file.sublist(0, cut), password: pw));
        expect(problem, isNotNull, reason: 'cut at $cut');
      }
    });

    test('a file that asks for an unreasonable key derivation is refused, not run', () async {
      final file = await createBackup(entries, password: pw, params: fast);
      final copy = Uint8List.fromList(file);
      ByteData.sublistView(copy).setUint32(9, 4 * 1024 * 1024, Endian.big); // 4 GiB of memory
      expect(await problemOf(() => readBackup(copy, password: pw)), BackupProblem.tooNew);
    });
  });

  group('untrusted files (spike S7, FEAT-007 AC-3)', () {
    test('a file that is not a backup is refused', () async {
      expect(await problemOf(() => readBackup(Uint8List.fromList(utf8.encode('hello, not a zip at all, sorry')))), BackupProblem.damaged);
      expect(await problemOf(() => readBackup(Uint8List(0))), BackupProblem.damaged);
    });

    test('a plaintext export cut off or with changed bytes is refused', () async {
      final file = await createBackup(entries);
      expect(await problemOf(() => readBackup(file.sublist(0, file.length - 10))), isNotNull);
      final copy = Uint8List.fromList(file);
      copy[copy.length ~/ 3] ^= 0xFF;
      // The change may land in an ignored Markdown file; keep changing until a read file is hit.
      var refused = false;
      for (var at = 40; at < 400 && !refused; at += 7) {
        final c = Uint8List.fromList(file)..[at] ^= 0xFF;
        refused = await problemOf(() => readBackup(c)) != null;
      }
      expect(refused, isTrue);
    });

    test('random damage never crashes and never returns entries that differ', () async {
      final file = await createBackup(entries);
      final rng = Random(7);
      for (var n = 0; n < 60; n++) {
        final c = Uint8List.fromList(file);
        for (var k = 0; k < 1 + rng.nextInt(4); k++) {
          c[rng.nextInt(c.length)] = rng.nextInt(256);
        }
        try {
          final back = await readBackup(c);
          // Accepted only when the damage hit a file that is ignored.
          expect(back.entries.map((e) => e.text).toList(), entries.map((e) => e.text).toList());
        } on BackupException {
          // refused: fine
        }
      }
    });

    test('a file from a newer format version is refused with "too new" (FEAT-007 AC-5)', () async {
      final zip = _customZip(manifestOverrides: {'formatVersion': 99});
      expect(await problemOf(() => readBackup(zip)), BackupProblem.tooNew);
    });

    test('a manifest that does not match its entries is refused', () async {
      final zip = _customZip(manifestOverrides: {'entriesSha256': '00' * 32});
      expect(await problemOf(() => readBackup(zip)), BackupProblem.damaged);
    });

    test('names with path tricks are ignored and never opened', () async {
      final good = _customParts();
      final zip = writeZip([
        ZipEntry('../../evil.txt', Uint8List.fromList(utf8.encode('x'))),
        ZipEntry('/etc/passwd', Uint8List.fromList(utf8.encode('x'))),
        ZipEntry('manifest.json', good.$1),
        ZipEntry('sub/entries.json', good.$2), // wrong path: not the file we ask for
        ZipEntry('entries.json', good.$2),
      ]);
      final back = await readBackup(zip);
      expect(back.entries.length, 1);
    });

    test('a missing entries file is refused', () async {
      final good = _customParts();
      final zip = writeZip([ZipEntry('manifest.json', good.$1)]);
      expect(await problemOf(() => readBackup(zip)), BackupProblem.damaged);
    });

    test('a file over the size limit is refused before it is opened', () async {
      final file = await createBackup(entries);
      final tiny = ImportLimits(zip: ZipLimits(maxFileBytes: file.length - 1));
      expect(await problemOf(() => readBackup(file, limits: tiny)), BackupProblem.tooLarge);
    });

    test('too many entries and an oversized entry are refused', () async {
      final file = await createBackup(entries);
      expect(await problemOf(() => readBackup(file, limits: const ImportLimits(maxEntries: 10))), BackupProblem.tooLarge);
      final big = await createBackup([entry(1, text: 'x' * 5000)]);
      expect(await problemOf(() => readBackup(big, limits: const ImportLimits(maxEntryBytes: 1000))), BackupProblem.tooLarge);
    });

    test('a decompression bomb is stopped by the unpacked-size cap, whatever the header claims', () async {
      // 8 MiB of zeros deflates to a few KiB. The header claims only 100 bytes.
      final bomb = Uint8List(8 * 1024 * 1024);
      final deflated = Uint8List.fromList(ZLibCodec(raw: true).encode(bomb));
      final zip = _rawZip('entries.json', deflated, claimedSize: 100, method: 8);
      final problem = await problemOf(() => readBackup(zip, limits: const ImportLimits(zip: ZipLimits(maxUnpackedBytes: 1024 * 1024))));
      expect(problem, isNotNull);
      expect(problem, anyOf(BackupProblem.tooLarge, BackupProblem.damaged));
    });

    test('a header that claims a huge size is refused before unpacking', () async {
      final deflated = Uint8List.fromList(ZLibCodec(raw: true).encode(Uint8List(100)));
      final zip = _rawZip('entries.json', deflated, claimedSize: 500 * 1024 * 1024, method: 8);
      expect(await problemOf(() => readBackup(zip)), BackupProblem.tooLarge);
    });
  });

  group('into the journal', () {
    late Directory dir;
    late JournalDatabase db;
    late EntryRepository repo;
    final key = Uint8List.fromList(List.generate(32, (i) => i + 5));

    setUp(() async {
      dir = Directory.systemTemp.createTempSync('exodite_import_');
      db = await JournalDatabase.openEncrypted(File('${dir.path}/journal.db'), key);
      repo = EntryRepository(db);
    });
    tearDown(() async {
      await db.close();
      dir.deleteSync(recursive: true);
    });

    test('a full round trip through two journals: same entries, dates and ids (FEAT-007 AC-1)', () async {
      for (var i = 0; i < 12; i++) {
        await repo.create(day: '2026-09-${(i + 1).toString().padLeft(2, '0')}', body: 'entry $i UNIQUE-$i');
      }
      final exported = await repo.readAllForExport();
      final file = await createBackup(exported, password: pw, params: fast);

      final dir2 = Directory.systemTemp.createTempSync('exodite_import2_');
      final db2 = await JournalDatabase.openEncrypted(File('${dir2.path}/journal.db'), key);
      final repo2 = EntryRepository(db2);
      final outcome = await repo2.importEntries((await readBackup(file, password: pw)).entries);
      expect(outcome.added, 12);
      expect(outcome.skipped, 0);
      final again = await repo2.readAllForExport();
      expect(again.map((e) => (e.uid, e.day, e.text)).toList(), exported.map((e) => (e.uid, e.day, e.text)).toList());
      await db2.close();
      dir2.deleteSync(recursive: true);
    });

    test('FEAT-010 AC-7, AC-8: mood and tags round-trip through two real journals, not just the format', () async {
      await repo.create(day: '2026-09-20', body: 'first', mood: Mood.great, tags: ['Work', 'Travel']);
      await repo.create(day: '2026-09-21', body: 'second');
      final exported = await repo.readAllForExport();
      final file = await createBackup(exported, password: pw, params: fast);

      final dir2 = Directory.systemTemp.createTempSync('exodite_import_meta_');
      final db2 = await JournalDatabase.openEncrypted(File('${dir2.path}/journal.db'), key);
      final repo2 = EntryRepository(db2);
      await repo2.importEntries((await readBackup(file, password: pw)).entries);
      final again = await repo2.readAllForExport();
      for (var i = 0; i < exported.length; i++) {
        expect(again[i].mood, exported[i].mood);
        expect(again[i].tags, exported[i].tags);
      }
      await db2.close();
      dir2.deleteSync(recursive: true);
    });

    test('importing the same file twice creates no duplicates (FEAT-007 AC-6)', () async {
      final file = await createBackup(entries);
      final list = (await readBackup(file)).entries;
      await repo.importEntries(list);
      final second = await repo.importEntries(list);
      expect(second.added, 0);
      expect(second.skipped, 25);
      expect(await repo.count(), 25);
    });

    test('an entry already on the phone with the same id and other text is kept, and counted skipped (FEAT-007 AC-8)', () async {
      final mine = StoredEntry(uid: entries[0].uid, day: '2026-09-01', text: 'MY TEXT', createdAtMs: 1, updatedAtMs: 1);
      await repo.importEntries([mine]);
      final outcome = await repo.importEntries(entries.take(3).toList());
      expect(outcome.added, 2);
      expect(outcome.skipped, 1);
      final all = await repo.readAllForExport();
      expect(all.firstWhere((e) => e.uid == mine.uid).text, 'MY TEXT');
    });

    test('an import that fails midway leaves the journal unchanged (FEAT-007 AC-7)', () async {
      await repo.create(day: '2026-09-01', body: 'already here');
      // A list that fails while the import is running, after two entries were added.
      expect(() => repo.importEntries(_FailsAfterTwo([entry(1), entry(2), entry(3), entry(4)])), throwsA(isA<StateError>()));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(await repo.count(), 1, reason: 'the two entries that were added are rolled back');
      // The journal still works afterwards.
      final ok = await repo.importEntries([entry(1)]);
      expect(ok.added, 1);
    });

    test('a deleted entry is not in the export (FEAT-006 AC-5)', () async {
      final a = (await repo.create(day: '2026-09-01', body: 'keep GONE-NOT'))!;
      final b = (await repo.create(day: '2026-09-02', body: 'remove GONE-1234'))!;
      await repo.delete(b.id);
      final file = await createBackup(await repo.readAllForExport());
      expect(has(file, 'GONE-1234'), isFalse);
      // Compressed content is not searchable as plain text, so check the parsed entries as well.
      final back = await readBackup(file);
      expect(back.entries.map((e) => e.uid), [a.uid]);
    });

    test('the time of the last export is kept, and is empty before the first export (FEAT-006 AC-6)', () async {
      expect(await repo.lastExportAt(), isNull);
      final t = DateTime(2026, 9, 20, 10, 30);
      await repo.recordExport(t);
      expect(await repo.lastExportAt(), t);
    });

    test('FEAT-011: a photo travels through a full round trip between two real journals', () async {
      final mediaDir1 = Directory('${dir.path}/media');
      final repoWithPhotos = EntryRepository(db, mediaDirectory: mediaDir1, dataKey: key);
      final entry1 = (await repoWithPhotos.create(day: '2026-09-01', body: 'a walk'))!;
      final entry2 = (await repoWithPhotos.create(day: '2026-09-02', body: 'no photo here'))!;
      final photo = await repoWithPhotos.addPhoto(entryId: entry1.id, bytes: Uint8List.fromList([9, 8, 7, 6, 5]), mimeType: 'image/jpeg', caption: 'the old oak');

      final exported = await repoWithPhotos.readAllForExport();
      final photoBytes = {photo.uid: await repoWithPhotos.readPhotoBytes(photo.uid)};
      final file = await createBackup(exported, password: pw, params: fast, photoBytes: photoBytes);

      final dir2 = Directory.systemTemp.createTempSync('exodite_import_photo_');
      final db2 = await JournalDatabase.openEncrypted(File('${dir2.path}/journal.db'), key);
      final mediaDir2 = Directory('${dir2.path}/media');
      final repo2 = EntryRepository(db2, mediaDirectory: mediaDir2, dataKey: key);
      final back = await readBackup(file, password: pw);
      final outcome = await repo2.importEntries(back.entries, mediaBytes: back.mediaBytes);
      expect(outcome.added, 2);

      final reExported = await repo2.readAllForExport();
      final imported1 = reExported.firstWhere((e) => e.uid == entry1.uid);
      final imported2 = reExported.firstWhere((e) => e.uid == entry2.uid);
      expect(imported1.media.single.uid, photo.uid);
      expect(imported1.media.single.caption, 'the old oak');
      expect(imported2.media, isEmpty);

      // The imported entry has a new row id in repo2's own database.
      final rebuilt = await (db2.select(db2.entries)..where((e) => e.uid.equals(entry1.uid))).getSingle();
      expect((await repo2.photosFor(rebuilt.id)).single.uid, photo.uid);
      expect(await repo2.readPhotoBytes(photo.uid), Uint8List.fromList([9, 8, 7, 6, 5]));
      await db2.close();
      dir2.deleteSync(recursive: true);
    });

    test('FEAT-011 AC-8: a photo whose bytes cannot be decrypted is left out of the export, not a failed export', () async {
      final mediaDir = Directory('${dir.path}/media_ac8');
      final repoWithPhotos = EntryRepository(db, mediaDirectory: mediaDir, dataKey: key);
      final e = (await repoWithPhotos.create(day: '2026-09-01', body: 'a walk'))!;
      await repoWithPhotos.addPhoto(entryId: e.id, bytes: Uint8List.fromList([1, 2, 3]), mimeType: 'image/jpeg');

      final exported = await repoWithPhotos.readAllForExport();
      // No photoBytes supplied at all: as if every photo failed to decrypt.
      final file = await createBackup(exported);
      final back = await readBackup(file);
      expect(back.entries.single.media, isEmpty);
    });
  });

  group('photos at the format level (FEAT-011)', () {
    final photoUid = 'aa'.padRight(32, '0');

    StoredEntry withPhoto({String? caption}) => StoredEntry(
          uid: entries[0].uid,
          day: entries[0].day,
          text: entries[0].text,
          createdAtMs: entries[0].createdAtMs,
          updatedAtMs: entries[0].updatedAtMs,
          media: [StoredMediaRef(uid: photoUid, mimeType: 'image/jpeg', caption: caption)],
        );

    test('a photo with a caption round-trips, and its bytes are recovered by uid', () async {
      final photoBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final file = await createBackup([withPhoto(caption: 'sunset')], password: pw, params: fast, photoBytes: {photoUid: photoBytes});
      final back = await readBackup(file, password: pw);
      final ref = back.entries.single.media.single;
      expect(ref.uid, photoUid);
      expect(ref.mimeType, 'image/jpeg');
      expect(ref.caption, 'sunset');
      expect(back.mediaBytes[photoUid], photoBytes);
    });

    test('a photo without a caption has no caption field, and none after reading it back', () async {
      final file = await createBackup([withPhoto()], password: pw, params: fast, photoBytes: {photoUid: Uint8List.fromList([1])});
      final back = await readBackup(file, password: pw);
      expect(back.entries.single.media.single.caption, isNull);
    });

    test('a photo missing from photoBytes at export time is left out of entries.json and the archive entirely', () async {
      final file = await createBackup([withPhoto()]); // no photoBytes: as if it could not be read
      final back = await readBackup(file);
      expect(back.entries.single.media, isEmpty);
      expect(has(file, 'media/'), isFalse);
    });

    test('an entry with a photo, from an app version that does not know FEAT-011, still imports its text', () async {
      final e = entries[0];
      final entriesJson = Uint8List.fromList(utf8.encode(jsonEncode({
        'formatVersion': 1,
        'schemaVersion': 1,
        'entries': [
          {
            'id': e.uid,
            'entryDate': e.day,
            'createdAt': DateTime.fromMillisecondsSinceEpoch(e.createdAtMs, isUtc: true).toIso8601String(),
            'updatedAt': DateTime.fromMillisecondsSinceEpoch(e.updatedAtMs, isUtc: true).toIso8601String(),
            'text': e.text,
          },
        ],
      })));
      final manifest = Uint8List.fromList(utf8.encode(jsonEncode({
        'format': backupFormatName,
        'formatVersion': 1,
        'schemaVersion': 1,
        'appVersion': '1.0.0',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'entryCount': 1,
        'entriesSha256': sha256Hex(entriesJson),
      })));
      final zip = writeZip([ZipEntry('manifest.json', manifest), ZipEntry('entries.json', entriesJson)]);
      final back = await readBackup(zip);
      expect(back.entries.single.media, isEmpty);
      expect(back.entries.single.text, e.text);
    });

    test('a malformed media reference is dropped, never treated as a valid photo, and never fails the import', () async {
      final e = entries[0];
      final goodUid = 'bb'.padRight(32, '0');
      final mismatchUid = 'cc'.padRight(32, '0');
      final entriesJson = Uint8List.fromList(utf8.encode(jsonEncode({
        'formatVersion': 1,
        'schemaVersion': 3,
        'entries': [
          {
            'id': e.uid,
            'entryDate': e.day,
            'createdAt': DateTime.fromMillisecondsSinceEpoch(e.createdAtMs, isUtc: true).toIso8601String(),
            'updatedAt': DateTime.fromMillisecondsSinceEpoch(e.updatedAtMs, isUtc: true).toIso8601String(),
            'text': e.text,
            'media': [
              {'id': 'not-a-valid-hex-id', 'path': 'media/not-a-valid-hex-id.jpg'},
              {'id': mismatchUid, 'path': 'media/$goodUid.jpg'}, // id does not match its own path
              {'id': goodUid, 'path': '../../evil.jpg'}, // outside media/, wrong shape entirely
              {'id': goodUid, 'path': 'media/$goodUid.jpg', 'caption': 12345}, // caption of the wrong type
            ],
          },
        ],
      })));
      final manifest = Uint8List.fromList(utf8.encode(jsonEncode({
        'format': backupFormatName,
        'formatVersion': 1,
        'schemaVersion': 3,
        'appVersion': '1.0.0',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'entryCount': 1,
        'entriesSha256': sha256Hex(entriesJson),
      })));
      final zip = writeZip([
        ZipEntry('manifest.json', manifest),
        ZipEntry('entries.json', entriesJson),
        ZipEntry('media/$goodUid.jpg', Uint8List.fromList([1, 2, 3])), // never opened: no valid reference names it
        ZipEntry('../../evil.jpg', Uint8List.fromList([9, 9, 9])),
      ]);
      final back = await readBackup(zip);
      expect(back.entries.single.media, isEmpty, reason: 'every reference above is malformed in some way');
      expect(back.mediaBytes, isEmpty);
    });
  });
}

/// A `.zip` with the two required files, assembled by hand for a test.
(Uint8List, Uint8List) _customParts({Map<String, Object?> manifestOverrides = const {}}) {
  final e = entry(1);
  final entriesJson = Uint8List.fromList(utf8.encode(jsonEncode({
    'formatVersion': 1,
    'schemaVersion': 1,
    'entries': [
      {
        'id': e.uid,
        'entryDate': e.day,
        'createdAt': DateTime.utc(2026, 9, 1).toIso8601String(),
        'updatedAt': DateTime.utc(2026, 9, 1).toIso8601String(),
        'text': e.text,
      }
    ],
  })));
  final manifest = <String, Object?>{
    'format': backupFormatName,
    'formatVersion': 1,
    'schemaVersion': 1,
    'appVersion': '1.0.0',
    'createdAt': DateTime.utc(2026, 9, 1).toIso8601String(),
    'entryCount': 1,
    'entriesSha256': _sha(entriesJson),
    ...manifestOverrides,
  };
  return (Uint8List.fromList(utf8.encode(jsonEncode(manifest))), entriesJson);
}

Uint8List _customZip({Map<String, Object?> manifestOverrides = const {}}) {
  final parts = _customParts(manifestOverrides: manifestOverrides);
  return writeZip([ZipEntry('manifest.json', parts.$1), ZipEntry('entries.json', parts.$2)]);
}

String _sha(List<int> bytes) => sha256Hex(bytes);

/// Yields two entries and then fails, like an interruption in the middle of an import.
class _FailsAfterTwo extends ListBase<StoredEntry> {
  _FailsAfterTwo(this._items);
  final List<StoredEntry> _items;

  @override
  int get length => _items.length;
  @override
  set length(int v) => throw UnsupportedError('read only');
  @override
  StoredEntry operator [](int i) {
    if (i >= 2) throw StateError('interrupted');
    return _items[i];
  }

  @override
  void operator []=(int i, StoredEntry v) => throw UnsupportedError('read only');
}

/// A ZIP with one file whose header can claim any size.
Uint8List _rawZip(String name, Uint8List data, {required int claimedSize, required int method}) {
  final n = utf8.encode(name);
  final local = ByteData(30)
    ..setUint32(0, 0x04034b50, Endian.little)
    ..setUint16(4, 20, Endian.little)
    ..setUint16(8, method, Endian.little)
    ..setUint32(18, data.length, Endian.little)
    ..setUint32(22, claimedSize, Endian.little)
    ..setUint16(26, n.length, Endian.little);
  final cd = ByteData(46)
    ..setUint32(0, 0x02014b50, Endian.little)
    ..setUint16(4, 20, Endian.little)
    ..setUint16(6, 20, Endian.little)
    ..setUint16(10, method, Endian.little)
    ..setUint32(20, data.length, Endian.little)
    ..setUint32(24, claimedSize, Endian.little)
    ..setUint16(28, n.length, Endian.little)
    ..setUint32(42, 0, Endian.little);
  final body = BytesBuilder()
    ..add(local.buffer.asUint8List())
    ..add(n)
    ..add(data);
  final cdOffset = body.length;
  final cdBytes = BytesBuilder()
    ..add(cd.buffer.asUint8List())
    ..add(n);
  final end = ByteData(22)
    ..setUint32(0, 0x06054b50, Endian.little)
    ..setUint16(8, 1, Endian.little)
    ..setUint16(10, 1, Endian.little)
    ..setUint32(12, cdBytes.length, Endian.little)
    ..setUint32(16, cdOffset, Endian.little);
  return (BytesBuilder()
        ..add(body.toBytes())
        ..add(cdBytes.toBytes())
        ..add(end.buffer.asUint8List()))
      .toBytes();
}
