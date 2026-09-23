// ADR-006 (protect the journal during data migrations). The schema is still
// version 1, so there is no real onUpgrade step yet: these tests exercise the
// copy-before/restore-on-failure mechanics in openEncrypted directly, using
// drift's own behaviour when it is asked to migrate from an older version
// with no onUpgrade defined for that step (which fails, on purpose, because
// none exists yet). A real second schema (its first user, FEAT-010) still
// needs its own migration test with a real fixture, per ADR-006's follow-up
// work; this file is not that test.
import 'dart:io';
import 'dart:typed_data';

import 'package:exoditeanima/data/entry_repository.dart';
import 'package:exoditeanima/data/journal_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

Uint8List key(int seed) => Uint8List.fromList(List.generate(32, (i) => (i * 5 + seed) & 0xff));

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

    // Make the file claim an older schema than journalSchemaVersion. There is
    // no onUpgrade step for that yet, so drift's own migration must fail;
    // openEncrypted must catch that and restore the file, not leave it half
    // migrated.
    final hex = key(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final r = raw.sqlite3.open(file.path);
    r.execute('PRAGMA key = "x\'$hex\'";');
    r.execute('PRAGMA user_version = ${journalSchemaVersion - 1};');
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
}
