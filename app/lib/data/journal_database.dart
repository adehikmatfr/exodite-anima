import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' show sqlite3;

part 'journal_database.g.dart';

/// One journal entry. `day` is the calendar date the user sees (yyyy-MM-dd),
/// kept as text so a change of time zone or clock never moves an entry.
class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// A random identifier that never changes and is never reused. It travels in
  /// exports so an import can tell which entries are already present (ADR-003).
  TextColumn get uid => text().unique()();
  TextColumn get day => text()();
  TextColumn get body => text()();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();
}

/// The one unsaved draft. `id` is always 1. `entryId` is null for a new entry.
class Drafts extends Table {
  IntColumn get id => integer()();
  IntColumn get entryId => integer().nullable()();
  TextColumn get day => text()();
  TextColumn get body => text()();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Small values the app keeps for itself, such as the time of the last export.
class AppValues extends Table {
  TextColumn get name => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {name};
}

/// The journal cannot be opened: damaged data, or a key that does not match.
/// Nothing is deleted when this is thrown (FEAT-001 AC-9).
class JournalOpenException implements Exception {
  JournalOpenException(this.message);
  final String message;
  @override
  String toString() => 'JournalOpenException: $message';
}

/// The journal was saved by a newer version of the app (FEAT-001 AC-10, ADR-006).
class JournalTooNewException implements Exception {
  JournalTooNewException(this.found, this.known);
  final int found;
  final int known;
  @override
  String toString() => 'JournalTooNewException: schema $found is newer than $known';
}

const int journalSchemaVersion = 1;

/// Path of the temporary copy kept while a migration runs (ADR-006). It sits
/// next to the journal file, never inside it, so a half-written copy can
/// never be mistaken for the journal itself.
File preMigrationBackupPath(File dbFile) => File('${dbFile.path}.pre-migration.bak');

/// Copies the journal file byte for byte before a migration runs. The copy is
/// exactly as protected as the original: it is the same ciphertext, not a
/// second key or a decrypted form (ADR-006, rule 1).
Future<File> backupBeforeMigration(File dbFile) => dbFile.copy(preMigrationBackupPath(dbFile).path);

/// Restores the journal from its pre-migration copy after a failed migration,
/// so a half-migrated file is never left in place (ADR-006, rule 2).
Future<void> restoreFromBackup(File dbFile, File backup) async {
  await backup.copy(dbFile.path);
}

/// Deletes a pre-migration copy once the app has opened successfully again,
/// on the new schema. Called on every open that is not itself a migration, so
/// the copy from the last migration is only removed on the *next* successful
/// launch, never the one that just migrated (ADR-006, rule 1).
Future<void> cleanupOldMigrationBackup(File dbFile) async {
  final backup = preMigrationBackupPath(dbFile);
  if (await backup.exists()) {
    await backup.delete();
  }
}

@DriftDatabase(tables: [Entries, Drafts, AppValues])
class JournalDatabase extends _$JournalDatabase {
  JournalDatabase(super.e);

  /// Opens (or creates) the encrypted journal file with a 256-bit data key.
  /// Throws [JournalOpenException] for a wrong key, a damaged file, or a
  /// migration that failed to complete, and [JournalTooNewException] when a
  /// newer app version wrote the file. A migration is protected per ADR-006:
  /// a copy is kept before it runs and restored if it fails, so this call
  /// either ends on the new schema or leaves the journal exactly as it was.
  static Future<JournalDatabase> openEncrypted(File file, Uint8List key) async {
    if (key.length != 32) {
      throw ArgumentError('The data key must be 32 bytes');
    }
    final hex = key.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    String keyPragma() => "PRAGMA key = \"x'$hex'\";";

    // Look at the file with a plain connection first, so a wrong key, damage,
    // or a newer schema is found before drift can change anything.
    int? found;
    if (file.existsSync() && file.lengthSync() > 0) {
      final probe = sqlite3.open(file.path);
      try {
        probe.execute(keyPragma());
        found = probe.select('PRAGMA user_version;').first.values.first as int;
        probe.select('SELECT count(*) FROM sqlite_master;');
        if (found > journalSchemaVersion) {
          throw JournalTooNewException(found, journalSchemaVersion);
        }
      } on JournalTooNewException {
        rethrow;
      } catch (e) {
        throw JournalOpenException('The journal could not be opened: ${e.runtimeType}');
      } finally {
        probe.close();
      }
    }

    final migrating = found != null && found < journalSchemaVersion;
    File? backup;
    if (migrating) {
      backup = await backupBeforeMigration(file);
    }

    final executor = NativeDatabase(
      file,
      setup: (raw) {
        raw.execute(keyPragma());
        // Deleted text must not linger in free pages (FEAT-001 AC-6).
        raw.execute('PRAGMA secure_delete = ON;');
      },
    );
    final db = JournalDatabase(executor);

    if (migrating) {
      try {
        // Force the connection open (and any migration) now, so a failure is
        // caught here, not at an arbitrary later point in the app.
        await db.customSelect('SELECT 1').getSingle();
      } catch (e) {
        await db.close();
        await restoreFromBackup(file, backup!);
        await cleanupOldMigrationBackup(file);
        throw JournalOpenException('The migration could not finish: ${e.runtimeType}');
      }
      // Migration succeeded. The copy stays until the next successful launch
      // (below), in case this run is killed right after opening.
    } else {
      await cleanupOldMigrationBackup(file);
    }

    return db;
  }

  @override
  int get schemaVersion => journalSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement('CREATE INDEX entries_day ON entries(day DESC, id DESC);');
          // Full-text search inside the encrypted file (ADR-002, FEAT-005). Letters
          // are matched without regard to case or accents; the triggers keep the
          // index equal to the entries, including after an edit or a delete.
          await customStatement(
            "CREATE VIRTUAL TABLE entries_fts USING fts5(body, content='entries', content_rowid='id', "
            "tokenize='unicode61 remove_diacritics 2');",
          );
          await customStatement(
            'CREATE TRIGGER entries_fts_insert AFTER INSERT ON entries BEGIN '
            'INSERT INTO entries_fts(rowid, body) VALUES (new.id, new.body); END;',
          );
          await customStatement(
            'CREATE TRIGGER entries_fts_delete AFTER DELETE ON entries BEGIN '
            "INSERT INTO entries_fts(entries_fts, rowid, body) VALUES ('delete', old.id, old.body); END;",
          );
          await customStatement(
            'CREATE TRIGGER entries_fts_update AFTER UPDATE OF body ON entries BEGIN '
            "INSERT INTO entries_fts(entries_fts, rowid, body) VALUES ('delete', old.id, old.body); "
            'INSERT INTO entries_fts(rowid, body) VALUES (new.id, new.body); END;',
          );
        },
        // No earlier schema exists yet, so there is no onUpgrade step: the
        // copy-before, restore-on-failure mechanics live in openEncrypted
        // above and already protect whatever the first onUpgrade step does.
        // ADR-006 rule 4 (large migrations run in one transaction or
        // resumably) is the first onUpgrade author's responsibility to keep;
        // this comment stays until that step exists.
      );
}
