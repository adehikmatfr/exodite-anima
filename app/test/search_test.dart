// FEAT-005 search rules on the encrypted journal. Synthetic text only.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:exoditeanima/data/entry_repository.dart';
import 'package:exoditeanima/data/journal_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  late JournalDatabase db;
  late EntryRepository repo;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('exodite_search_');
    db = await JournalDatabase.openEncrypted(File('${dir.path}/journal.db'), Uint8List.fromList(List.generate(32, (i) => i + 11)));
    repo = EntryRepository(db);
  });
  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  Future<List<String>> found(String q) async => [for (final h in await repo.search(q)) h.pieces.map((p) => p.$1).join()];

  test('AC-1 an entry that contains the word is listed, with the word marked', () async {
    await repo.create(day: '2026-09-20', body: 'Walked by the river before work.');
    await repo.create(day: '2026-09-19', body: 'Coffee, a slow start.');
    final hits = await repo.search('river');
    expect(hits.length, 1);
    expect(hits.single.firstMatch, 'river');
    expect(hits.single.pieces.where((p) => p.$2).map((p) => p.$1), ['river']);
  });

  test('AC-2 nothing matches: an empty list', () async {
    await repo.create(day: '2026-09-20', body: 'Walked by the river.');
    expect(await repo.search('kite'), isEmpty);
  });

  test('AC-4 a deleted entry is not listed, and an edited entry is found by its new words only', () async {
    final a = (await repo.create(day: '2026-09-20', body: 'secret orchid garden'))!;
    final b = (await repo.create(day: '2026-09-21', body: 'plain violet field'))!;
    expect((await repo.search('orchid')).length, 1);
    await repo.delete(a.id);
    expect(await repo.search('orchid'), isEmpty);
    await repo.update(id: b.id, day: '2026-09-21', body: 'plain meadow');
    expect(await repo.search('violet'), isEmpty);
    expect((await repo.search('meadow')).length, 1);
  });

  test('AC-7 case and accents do not matter, in either direction', () async {
    await repo.create(day: '2026-09-20', body: 'We sat in a small Café near the station.');
    await repo.create(day: '2026-09-21', body: 'Kami ke kafe biasa. Dan cafe lain.');
    expect((await found('cafe')).length, 2);
    expect((await found('CAFÉ')).length, 2);
    expect((await found('café')).length, 2);
    expect((await found('CAFE')).length, 2);
  });

  test('AC-8 a word is matched from its start: riv finds river, iver does not', () async {
    await repo.create(day: '2026-09-20', body: 'A river ran by the house.');
    expect((await repo.search('riv')).length, 1);
    expect(await repo.search('iver'), isEmpty);
    expect(await repo.search('ver'), isEmpty);
    expect(await repo.search('driver'), isEmpty);
  });

  test('several words must all match; order does not matter', () async {
    await repo.create(day: '2026-09-20', body: 'Long call with my sister about the old house.');
    await repo.create(day: '2026-09-21', body: 'Read for two hours.');
    expect((await repo.search('sister house')).length, 1);
    expect((await repo.search('house sister')).length, 1);
    expect(await repo.search('sister hours'), isEmpty);
  });

  test('newest first', () async {
    await repo.create(day: '2026-09-01', body: 'tea one');
    await repo.create(day: '2026-09-03', body: 'tea three');
    await repo.create(day: '2026-09-02', body: 'tea two');
    expect(await found('tea'), ['tea three', 'tea two', 'tea one']);
  });

  test('punctuation and operators typed by the user cannot break or change the query', () async {
    await repo.create(day: '2026-09-20', body: 'It is a quiet evening, isn\'t it? AND OR NOT');
    for (final q in ['"', '"quiet', 'quiet"', 'quiet*', '(quiet', 'AND', 'OR', 'NOT', 'NEAR(', 'quiet OR', "isn't", '^quiet', 'body:quiet', '*', '  ', '']) {
      await repo.search(q); // must not throw
    }
    expect((await repo.search('quiet*')).length, 1);
    expect((await repo.search("isn't")).length, 1);
    expect(await repo.search('   '), isEmpty);
    expect(await repo.search(''), isEmpty);
    expect(searchQueryFor('"'), isNull);
  });

  test('other scripts and digits are searchable', () async {
    await repo.create(day: '2026-09-20', body: '日本語のノート 2026 Bahasa Indonesia 😀');
    expect((await repo.search('2026')).length, 1);
    expect((await repo.search('indonesia')).length, 1);
    expect((await repo.search('日本語のノート')).length, 1);
  });

  test('an imported entry is searchable (FEAT-007 with FEAT-005)', () async {
    await repo.importEntries([
      StoredEntry(uid: 'a' * 32, day: '2026-09-01', text: 'restored lantern memory', createdAtMs: 1, updatedAtMs: 1),
    ]);
    expect((await repo.search('lantern')).length, 1);
  });

  test('the search index leaves no readable text in the files on disk (spike S2, FEAT-005)', () async {
    await repo.create(day: '2026-09-20', body: 'unique word ZEBRAQUILLPLANT and more');
    await repo.delete((await repo.watchAll().first).single.id);
    await repo.create(day: '2026-09-20', body: 'another IBEXSTONEFERN entry');
    await db.close();
    for (final f in dir.listSync().whereType<File>()) {
      final text = latin1.decode(f.readAsBytesSync()).toLowerCase();
      expect(text.contains('zebraquillplant'), isFalse, reason: f.path);
      expect(text.contains('ibexstonefern'), isFalse, reason: f.path);
    }
    db = await JournalDatabase.openEncrypted(File('${dir.path}/journal.db'), Uint8List.fromList(List.generate(32, (i) => i + 11)));
    repo = EntryRepository(db);
  });

  test('a deleted word is not left in the index or in free pages', () async {
    final e = (await repo.create(day: '2026-09-20', body: 'vanishing QUOKKAWILLOW text'))!;
    await repo.delete(e.id);
    expect(await repo.search('quokkawillow'), isEmpty);
    await db.close();
    for (final f in dir.listSync().whereType<File>()) {
      expect(latin1.decode(f.readAsBytesSync()).toLowerCase().contains('quokkawillow'), isFalse, reason: f.path);
    }
    db = await JournalDatabase.openEncrypted(File('${dir.path}/journal.db'), Uint8List.fromList(List.generate(32, (i) => i + 11)));
    repo = EntryRepository(db);
  });
}
