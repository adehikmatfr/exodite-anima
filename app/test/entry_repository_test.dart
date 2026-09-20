// FEAT-001 acceptance criteria at the storage level. Synthetic data and made-up keys only.
import 'dart:io';
import 'dart:typed_data';

import 'package:exoditeanima/data/entry_repository.dart';
import 'package:exoditeanima/data/journal_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

Uint8List key(int seed) => Uint8List.fromList(List.generate(32, (i) => (i * 5 + seed) & 0xff));

bool fileHas(File f, String needle) {
  final hay = f.readAsBytesSync();
  final n = needle.codeUnits;
  outer:
  for (var i = 0; i <= hay.length - n.length; i++) {
    for (var j = 0; j < n.length; j++) {
      if (hay[i + j] != n[j]) continue outer;
    }
    return true;
  }
  return false;
}

void main() {
  late Directory dir;
  late File file;
  var clock = 1000;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('exodite_feat001_');
    file = File('${dir.path}/journal.db');
    clock = 1000;
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Future<(JournalDatabase, EntryRepository)> open([Uint8List? k]) async {
    final db = await JournalDatabase.openEncrypted(file, k ?? key(1));
    return (db, EntryRepository(db, nowMs: () => clock++));
  }

  test('AC-1 a saved entry appears with its text and date', () async {
    final (db, repo) = await open();
    final e = await repo.create(day: '2026-09-20', body: 'first words');
    expect(e, isNotNull);
    final all = await repo.watchAll().first;
    expect(all.single.body, 'first words');
    expect(all.single.day, '2026-09-20');
    await db.close();
  });

  test('AC-2 editing changes the text', () async {
    final (db, repo) = await open();
    final e = (await repo.create(day: '2026-09-20', body: 'old'))!;
    expect(await repo.update(id: e.id, day: e.day, body: 'new'), isTrue);
    expect((await repo.get(e.id))!.body, 'new');
    await db.close();
  });

  test('AC-3 saved text survives closing and reopening', () async {
    var (db, repo) = await open();
    await repo.create(day: '2026-09-20', body: 'still here');
    await db.close();
    (db, repo) = await open();
    expect((await repo.watchAll().first).single.body, 'still here');
    await db.close();
  });

  test('AC-4 an unsaved draft is offered back after the app is killed', () async {
    var (db, repo) = await open();
    await repo.saveDraft(day: '2026-09-20', body: 'half a thought');
    await db.close(); // stands in for a forced close: nothing was saved as an entry
    (db, repo) = await open();
    final d = await repo.loadDraft();
    expect(d?.body, 'half a thought');
    expect(await repo.count(), 0);
    await db.close();
  });

  test('AC-4 saving the entry clears the draft', () async {
    final (db, repo) = await open();
    await repo.saveDraft(day: '2026-09-20', body: 'typing');
    await repo.create(day: '2026-09-20', body: 'typing');
    expect(await repo.loadDraft(), isNull);
    await db.close();
  });

  test('AC-5 changing the date moves the entry in the timeline', () async {
    final (db, repo) = await open();
    final a = (await repo.create(day: '2026-09-18', body: 'a'))!;
    await repo.create(day: '2026-09-19', body: 'b');
    await repo.update(id: a.id, day: '2026-09-21', body: 'a');
    final all = await repo.watchAll().first;
    expect(all.map((e) => e.body).toList(), ['a', 'b']);
    expect(all.first.day, '2026-09-21');
    await db.close();
  });

  test('AC-6 a deleted entry is gone, and its text is not left in the file', () async {
    final (db, repo) = await open();
    final e = (await repo.create(day: '2026-09-20', body: 'to be forgotten NEEDLE-9182'))!;
    await repo.delete(e.id);
    expect(await repo.count(), 0);
    await db.close();
    expect(fileHas(file, 'NEEDLE-9182'), isFalse);
  });

  test('FEAT-002 AC-1 the timeline lists newest day first, and the latest written first within a day', () async {
    final (db, repo) = await open();
    await repo.create(day: '2026-09-18', body: 'oldest');
    await repo.create(day: '2026-09-20', body: 'today early');
    await repo.create(day: '2026-09-19', body: 'yesterday');
    await repo.create(day: '2026-09-20', body: 'today late');
    final items = await repo.watchTimeline().first;
    expect(items.map((i) => i.preview).toList(), ['today late', 'today early', 'yesterday', 'oldest']);
    expect(items.map((i) => i.day).toList(), ['2026-09-20', '2026-09-20', '2026-09-19', '2026-09-18']);
    await db.close();
  });

  test('FEAT-002 the timeline reads only a preview of a very long entry', () async {
    final (db, repo) = await open();
    await repo.create(day: '2026-09-20', body: 'x' * 50000);
    final items = await repo.watchTimeline(previewLength: 100).first;
    expect(items.single.preview.length, 100);
    await db.close();
  });

  test('FEAT-002 the timeline updates when an entry changes or is deleted', () async {
    final (db, repo) = await open();
    final events = <List<String>>[];
    final sub = repo.watchTimeline().listen((l) => events.add([for (final i in l) i.preview]));
    final a = (await repo.create(day: '2026-09-20', body: 'first'))!;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await repo.update(id: a.id, day: '2026-09-20', body: 'changed');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await repo.delete(a.id);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();
    expect(events.last, isEmpty);
    expect(events.any((e) => e.length == 1 && e.first == 'changed'), isTrue);
    await db.close();
  });

  test('AC-8 an empty or blank entry is not saved', () async {
    final (db, repo) = await open();
    expect(await repo.create(day: '2026-09-20', body: ''), isNull);
    expect(await repo.create(day: '2026-09-20', body: '  \n '), isNull);
    expect(await repo.count(), 0);
    await db.close();
  });

  test('no entry text is readable in the file on disk', () async {
    final (db, repo) = await open();
    await repo.create(day: '2026-09-20', body: 'secret NEEDLE-5521');
    await repo.saveDraft(day: '2026-09-20', body: 'draft NEEDLE-7733');
    await db.close();
    expect(fileHas(file, 'NEEDLE-5521'), isFalse);
    expect(fileHas(file, 'NEEDLE-7733'), isFalse);
    for (final f in dir.listSync().whereType<File>()) {
      expect(fileHas(f, 'NEEDLE-5521'), isFalse, reason: f.path);
    }
  });

  test('AC-9 a wrong key is refused and the file is left as it was', () async {
    var (db, repo) = await open();
    await repo.create(day: '2026-09-20', body: 'keep me');
    await db.close();
    final before = file.readAsBytesSync();

    await expectLater(JournalDatabase.openEncrypted(file, key(2)), throwsA(isA<JournalOpenException>()));
    expect(file.readAsBytesSync(), before);

    (db, repo) = await open();
    expect((await repo.watchAll().first).single.body, 'keep me');
    await db.close();
  });

  test('AC-9 a damaged file is refused and not deleted', () async {
    var (db, repo) = await open();
    await repo.create(day: '2026-09-20', body: 'keep me');
    await db.close();
    final bytes = file.readAsBytesSync();
    for (var i = 100; i < 400; i++) {
      bytes[i] = bytes[i] ^ 0xff;
    }
    file.writeAsBytesSync(bytes);
    await expectLater(JournalDatabase.openEncrypted(file, key(1)), throwsA(isA<JournalOpenException>()));
    expect(file.existsSync(), isTrue);
  });

  test('AC-10 a journal from a newer schema is not opened or changed', () async {
    final (db, _) = await open();
    await db.close();
    final h = key(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final r = raw.sqlite3.open(file.path);
    r.execute('PRAGMA key = "x\'$h\'";');
    r.execute('PRAGMA user_version = ${journalSchemaVersion + 1};');
    r.close();
    final before = file.readAsBytesSync();
    await expectLater(JournalDatabase.openEncrypted(file, key(1)), throwsA(isA<JournalTooNewException>()));
    expect(file.readAsBytesSync(), before);
  });
}
