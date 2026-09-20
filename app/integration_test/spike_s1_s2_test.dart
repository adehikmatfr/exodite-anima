// ignore_for_file: avoid_print
// Spike S1 and S2 (ADR-002). Synthetic data and a made-up key only.
import 'dart:io';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const marker = 'ZEBRAQUILL-marker-7431';

String hexKey(int seed) => List.generate(
  32,
  (i) => ((i * 7 + seed) & 0xff).toRadixString(16).padLeft(2, '0'),
).join();

// Raw key form understood by SQLite3MultipleCiphers: pragma key = "x'<64 hex>'".
void unlock(Database db, String hex) => db.execute("PRAGMA key = \"x'$hex'\";");

bool containsBytes(Uint8List data, String needle) {
  final n = needle.codeUnits;
  outer:
  for (var i = 0; i <= data.length - n.length; i++) {
    for (var j = 0; j < n.length; j++) {
      if (data[i + j] != n[j]) continue outer;
    }
    return true;
  }
  return false;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  late String path;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('exodite_spike_');
    path = '${dir.path}/journal.db';
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('S1: cipher build is the one loaded', () {
    final db = sqlite3.openInMemory();
    final v = db.select('SELECT sqlite_version() AS v').first['v'];
    // The multiple-ciphers build answers this pragma; plain SQLite returns no rows.
    final ciphers = db.select('PRAGMA cipher;');
    print(
      'sqlite_version=$v cipher_rows=${ciphers.map((r) => r.values).toList()}',
    );
    expect(ciphers, isNotEmpty);
    db.close();
  });

  test('S1: create, write, close, reopen with right key, refuse wrong key', () {
    final good = hexKey(1), bad = hexKey(2);
    var db = sqlite3.open(path);
    unlock(db, good);
    db.execute(
      'CREATE TABLE entry(id INTEGER PRIMARY KEY, day TEXT, body TEXT)',
    );
    db.execute('INSERT INTO entry(day, body) VALUES (?, ?)', [
      '2026-09-20',
      'hello $marker',
    ]);
    db.close();

    db = sqlite3.open(path);
    unlock(db, good);
    expect(db.select('SELECT body FROM entry').first['body'], 'hello $marker');
    db.close();

    db = sqlite3.open(path);
    unlock(db, bad);
    expect(
      () => db.select('SELECT body FROM entry'),
      throwsA(isA<SqliteException>()),
    );
    db.close();

    // No key at all is refused as well.
    db = sqlite3.open(path);
    expect(
      () => db.select('SELECT body FROM entry'),
      throwsA(isA<SqliteException>()),
    );
    db.close();
  });

  test(
    'S2: full-text search works inside the encrypted file, and no plaintext hits disk',
    () {
      final key = hexKey(3);
      final db = sqlite3.open(path);
      unlock(db, key);
      db.execute('PRAGMA journal_mode = WAL;');
      db.execute('CREATE VIRTUAL TABLE entry_fts USING fts5(body)');
      db.execute('INSERT INTO entry_fts(body) VALUES (?), (?)', [
        'walk in the park $marker',
        'quiet evening',
      ]);
      final hits = db.select(
        "SELECT body FROM entry_fts WHERE entry_fts MATCH 'park'",
      );
      expect(hits.length, 1);

      // Inspect every file the database owns while it is still open (WAL not yet checkpointed).
      final files = dir.listSync().whereType<File>().toList();
      print(
        'files while open: ${files.map((f) => f.uri.pathSegments.last).toList()}',
      );
      for (final f in files) {
        expect(
          containsBytes(f.readAsBytesSync(), marker),
          isFalse,
          reason: f.path,
        );
        expect(
          containsBytes(f.readAsBytesSync(), 'quiet evening'),
          isFalse,
          reason: f.path,
        );
      }
      db.close();
      for (final f in dir.listSync().whereType<File>()) {
        expect(
          containsBytes(f.readAsBytesSync(), marker),
          isFalse,
          reason: f.path,
        );
      }
    },
  );

  test(
    'S2: plain SQLite control shows the inspection method can find plaintext',
    () {
      final db = sqlite3.open(path);
      db.execute('CREATE TABLE t(body TEXT)');
      db.execute('INSERT INTO t VALUES (?)', [marker]);
      db.close();
      expect(containsBytes(File(path).readAsBytesSync(), marker), isTrue);
    },
  );
}
