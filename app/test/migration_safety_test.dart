// ADR-006 (protect the journal during data migrations), plus the two real
// schema steps so far (FEAT-010, 1 -> 2: `mood`, `tags`/`entry_tags`; FEAT-011,
// 2 -> 3: `media`). The success tests build a genuine fixture by hand for
// each previous version (the exact CREATE TABLE SQL a real build of that
// version produced, captured once and reproduced here) and check that
// opening it with today's code migrates it and keeps its data. The failure
// test forces a redundant migration attempt against a file that is already
// in the current shape: `addColumn` genuinely fails on a column that already
// exists, which is why the test targets the 1 -> 2 step specifically (`- 2`,
// not `- 1`) - drift's `createTable` is `CREATE TABLE IF NOT EXISTS`, a
// silent no-op on an existing table, so the 2 -> 3 step alone would not fail.
import 'dart:io';
import 'dart:typed_data';

import 'package:exoditeanima/data/entry_repository.dart';
import 'package:exoditeanima/data/journal_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

Uint8List key(int seed) => Uint8List.fromList(List.generate(32, (i) => (i * 5 + seed) & 0xff));

/// Builds a schema-1 journal file by hand: the exact tables a version-1
/// build created, minus `mood` on entries and the `tags`/`entry_tags` tables
/// FEAT-010 adds. There is no schema-snapshot tooling set up in this project
/// to generate this automatically, so it is reproduced from a real schema-1
/// database's own `sqlite_master.sql`, captured once by hand.
void writeSchema1Fixture(File file, Uint8List dbKey, {required String uid, required String day, required String body, required int createdAtMs}) {
  final hex = dbKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  final r = raw.sqlite3.open(file.path);
  r.execute('PRAGMA key = "x\'$hex\'";');
  r.execute(
    'CREATE TABLE "entries" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "uid" TEXT NOT NULL UNIQUE, '
    '"day" TEXT NOT NULL, "body" TEXT NOT NULL, "created_at_ms" INTEGER NOT NULL, "updated_at_ms" INTEGER NOT NULL);',
  );
  r.execute(
    'CREATE TABLE "drafts" ("id" INTEGER NOT NULL, "entry_id" INTEGER NULL, "day" TEXT NOT NULL, '
    '"body" TEXT NOT NULL, "updated_at_ms" INTEGER NOT NULL, PRIMARY KEY ("id"));',
  );
  r.execute('CREATE TABLE "app_values" ("name" TEXT NOT NULL, "value" TEXT NOT NULL, PRIMARY KEY ("name"));');
  r.execute('CREATE INDEX entries_day ON entries(day DESC, id DESC);');
  r.execute(
    "CREATE VIRTUAL TABLE entries_fts USING fts5(body, content='entries', content_rowid='id', "
    "tokenize='unicode61 remove_diacritics 2');",
  );
  r.execute(
    'CREATE TRIGGER entries_fts_insert AFTER INSERT ON entries BEGIN '
    'INSERT INTO entries_fts(rowid, body) VALUES (new.id, new.body); END;',
  );
  r.execute(
    'CREATE TRIGGER entries_fts_delete AFTER DELETE ON entries BEGIN '
    "INSERT INTO entries_fts(entries_fts, rowid, body) VALUES ('delete', old.id, old.body); END;",
  );
  r.execute(
    'CREATE TRIGGER entries_fts_update AFTER UPDATE OF body ON entries BEGIN '
    "INSERT INTO entries_fts(entries_fts, rowid, body) VALUES ('delete', old.id, old.body); "
    'INSERT INTO entries_fts(rowid, body) VALUES (new.id, new.body); END;',
  );
  r.execute(
    'INSERT INTO entries (uid, day, body, created_at_ms, updated_at_ms) VALUES (?, ?, ?, ?, ?);',
    [uid, day, body, createdAtMs, createdAtMs],
  );
  r.execute('PRAGMA user_version = 1;');
  r.close();
}

/// Builds a schema-2 journal file by hand: schema 1's tables, plus the
/// `mood` column and `tags`/`entry_tags` tables FEAT-010 added, minus the
/// `media` table FEAT-011 adds. Reproduced from a real schema-2 database's
/// own `sqlite_master.sql`, the same way [writeSchema1Fixture] is.
void writeSchema2Fixture(File file, Uint8List dbKey, {required String uid, required String day, required String body, required int createdAtMs, int? mood, String? tag}) {
  final hex = dbKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  final r = raw.sqlite3.open(file.path);
  r.execute('PRAGMA key = "x\'$hex\'";');
  r.execute(
    'CREATE TABLE "entries" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "uid" TEXT NOT NULL UNIQUE, '
    '"day" TEXT NOT NULL, "body" TEXT NOT NULL, "created_at_ms" INTEGER NOT NULL, "updated_at_ms" INTEGER NOT NULL, "mood" INTEGER NULL);',
  );
  r.execute(
    'CREATE TABLE "drafts" ("id" INTEGER NOT NULL, "entry_id" INTEGER NULL, "day" TEXT NOT NULL, '
    '"body" TEXT NOT NULL, "updated_at_ms" INTEGER NOT NULL, PRIMARY KEY ("id"));',
  );
  r.execute('CREATE TABLE "app_values" ("name" TEXT NOT NULL, "value" TEXT NOT NULL, PRIMARY KEY ("name"));');
  r.execute('CREATE TABLE "tags" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" TEXT NOT NULL UNIQUE);');
  r.execute('CREATE TABLE "entry_tags" ("entry_id" INTEGER NOT NULL REFERENCES entries (id), "tag_id" INTEGER NOT NULL REFERENCES tags (id), PRIMARY KEY ("entry_id", "tag_id"));');
  r.execute('CREATE INDEX entries_day ON entries(day DESC, id DESC);');
  r.execute(
    "CREATE VIRTUAL TABLE entries_fts USING fts5(body, content='entries', content_rowid='id', "
    "tokenize='unicode61 remove_diacritics 2');",
  );
  r.execute(
    'CREATE TRIGGER entries_fts_insert AFTER INSERT ON entries BEGIN '
    'INSERT INTO entries_fts(rowid, body) VALUES (new.id, new.body); END;',
  );
  r.execute(
    'CREATE TRIGGER entries_fts_delete AFTER DELETE ON entries BEGIN '
    "INSERT INTO entries_fts(entries_fts, rowid, body) VALUES ('delete', old.id, old.body); END;",
  );
  r.execute(
    'CREATE TRIGGER entries_fts_update AFTER UPDATE OF body ON entries BEGIN '
    "INSERT INTO entries_fts(entries_fts, rowid, body) VALUES ('delete', old.id, old.body); "
    'INSERT INTO entries_fts(rowid, body) VALUES (new.id, new.body); END;',
  );
  r.execute(
    'INSERT INTO entries (uid, day, body, created_at_ms, updated_at_ms, mood) VALUES (?, ?, ?, ?, ?, ?);',
    [uid, day, body, createdAtMs, createdAtMs, mood],
  );
  if (tag != null) {
    r.execute('INSERT INTO tags (name) VALUES (?);', [tag]);
    r.execute('INSERT INTO entry_tags (entry_id, tag_id) VALUES (1, 1);');
  }
  r.execute('PRAGMA user_version = 2;');
  r.close();
}

void main() {
  late Directory dir;
  late File file;
  var clock = 1000;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('exodite_adr006_');
    file = File('${dir.path}/journal.db');
    clock = 1000;
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Future<(JournalDatabase, EntryRepository)> open([Uint8List? k]) async {
    final db = await JournalDatabase.openEncrypted(file, k ?? key(1));
    return (db, EntryRepository(db, nowMs: () => clock++));
  }

  test('backupBeforeMigration copies the file exactly; restoreFromBackup copies it back', () async {
    file.writeAsBytesSync([1, 2, 3, 4, 5]);
    final backup = await backupBeforeMigration(file);
    expect(backup.readAsBytesSync(), [1, 2, 3, 4, 5]);

    file.writeAsBytesSync([9, 9, 9]); // stand-in for a half-written migration
    await restoreFromBackup(file, backup);
    expect(file.readAsBytesSync(), [1, 2, 3, 4, 5]);
  });

  test('cleanupOldMigrationBackup deletes a leftover backup, and does nothing when there is none', () async {
    final backup = preMigrationBackupPath(file);
    await cleanupOldMigrationBackup(file); // nothing to delete; must not throw

    file.writeAsBytesSync([1]);
    backup.writeAsBytesSync([1]);
    await cleanupOldMigrationBackup(file);
    expect(backup.existsSync(), isFalse);
  });

  test('a normal open and close leaves no migration backup behind', () async {
    final (db, repo) = await open();
    await repo.create(day: '2026-09-20', body: 'ordinary entry');
    await db.close();
    expect(preMigrationBackupPath(file).existsSync(), isFalse);
  });

  test('a backup left over from an earlier migration is removed the next time the journal opens cleanly', () async {
    var (db, repo) = await open();
    await repo.create(day: '2026-09-20', body: 'entry');
    await db.close();

    // Stand in for the app being killed right after a migration succeeded,
    // before the cleanup on the next launch could run.
    final backup = preMigrationBackupPath(file);
    file.copySync(backup.path);
    expect(backup.existsSync(), isTrue);

    (db, repo) = await open();
    await db.close();

    expect(backup.existsSync(), isFalse);
  });

  test('ADR-006: a migration that fails leaves the journal exactly as it was, and cleans up its own backup', () async {
    var (db, repo) = await open();
    await repo.create(day: '2026-09-20', body: 'safe entry');
    await db.close();

    // Make the file claim an older schema than journalSchemaVersion, while
    // its actual shape is already current (built by open() above). The real
    // onUpgrade step then tries to add a column that already exists, which
    // fails; openEncrypted must catch that and restore the file, not leave
    // it half migrated. Deliberately `- 2`, not `- 1`: drift's `createTable`
    // is `CREATE TABLE IF NOT EXISTS` (a silent no-op on an existing table,
    // found while adding FEAT-011's `media` table step), so only the
    // `addColumn` step (genuinely not idempotent) reliably fails here.
    final hex = key(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final r = raw.sqlite3.open(file.path);
    r.execute('PRAGMA key = "x\'$hex\'";');
    r.execute('PRAGMA user_version = ${journalSchemaVersion - 2};');
    r.close();
    final before = file.readAsBytesSync();

    await expectLater(JournalDatabase.openEncrypted(file, key(1)), throwsA(isA<JournalOpenException>()));

    expect(file.readAsBytesSync(), before, reason: 'the file must be restored to what it was before this attempt');
    expect(preMigrationBackupPath(file).existsSync(), isFalse, reason: 'the backup is cleaned up once it has restored the file');

    // The entry itself is still there and readable: nothing was lost.
    final check = raw.sqlite3.open(file.path);
    check.execute('PRAGMA key = "x\'$hex\'";');
    final rows = check.select('SELECT body FROM entries;');
    expect(rows.first['body'], 'safe entry');
    check.close();
  });

  test('TC-015, TC-100: a genuine schema-1 journal migrates to schema 2 and keeps its entry', () async {
    writeSchema1Fixture(file, key(1), uid: 'fixture-uid-1', day: '2024-09-20', body: 'from before mood and tags existed', createdAtMs: 500);
    expect(preMigrationBackupPath(file).existsSync(), isFalse);

    final db = await JournalDatabase.openEncrypted(file, key(1));
    // Right after a migration, rule 1 keeps the backup until the *next*
    // successful launch, in case this run is killed right after opening.
    expect(preMigrationBackupPath(file).existsSync(), isTrue);

    final repo = EntryRepository(db, nowMs: () => clock++);
    final entry = (await repo.watchAll().first).single;
    expect(entry.uid, 'fixture-uid-1');
    expect(entry.day, '2024-09-20');
    expect(entry.body, 'from before mood and tags existed');
    expect(entry.mood, isNull, reason: 'an old entry never had a mood; the migration must not invent one');
    expect(entry.tags, isEmpty);

    // The mood and tags machinery is fully usable on the migrated file, not
    // just present as empty columns.
    expect(await repo.update(id: entry.id, day: entry.day, body: entry.body, mood: Mood.good, tags: ['Family']), isTrue);
    final updated = await repo.get(entry.id);
    expect(updated!.mood, Mood.good);
    expect(updated.tags, ['Family']);

    await db.close();
  });

  test('TC-015, TC-100 (FEAT-011): a genuine schema-2 journal migrates to schema 3, keeping its entry, mood, and tag', () async {
    writeSchema2Fixture(file, key(1), uid: 'fixture-uid-2', day: '2024-09-20', body: 'from before photos existed', createdAtMs: 500, mood: Mood.good.index, tag: 'Family');
    expect(preMigrationBackupPath(file).existsSync(), isFalse);

    final db = await JournalDatabase.openEncrypted(file, key(1));
    expect(preMigrationBackupPath(file).existsSync(), isTrue, reason: 'the pre-migration copy is kept until the next clean launch (ADR-006 rule 1)');

    final repo = EntryRepository(db, nowMs: () => clock++);
    final row = (await repo.watchAll().first).single;
    final entry = await repo.get(row.id);
    expect(entry!.uid, 'fixture-uid-2');
    expect(entry.body, 'from before photos existed');
    expect(entry.mood, Mood.good, reason: 'mood from before this migration must survive it untouched');
    expect(entry.tags, ['Family'], reason: 'tags from before this migration must survive it untouched');

    await db.close();
  });
}
