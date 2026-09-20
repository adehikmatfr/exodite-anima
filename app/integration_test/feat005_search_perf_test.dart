// ignore_for_file: avoid_print
// FEAT-005 AC-6 (TC-045): search time in a journal of 20,000 entries. Synthetic text.
// Emulator numbers are indicative; the target is judged on the reference device.
import 'dart:io';
import 'dart:typed_data';

import 'package:exoditeanima/data/entry_repository.dart';
import 'package:exoditeanima/data/journal_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('search in 20,000 entries', (t) async {
    final dir = Directory.systemTemp.createTempSync('exodite_sperf_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final db = await JournalDatabase.openEncrypted(File('${dir.path}/journal.db'), Uint8List.fromList(List.generate(32, (i) => i + 1)));
    final repo = EntryRepository(db);
    final base = DateTime(2026, 9, 20).millisecondsSinceEpoch;
    final sw = Stopwatch()..start();
    await db.batch((b) {
      b.insertAll(db.entries, [
        for (var i = 0; i < 20000; i++)
          EntriesCompanion.insert(
            uid: i.toRadixString(16).padLeft(32, '0'),
            day: '2026-${(i % 12 + 1).toString().padLeft(2, '0')}-${(i % 28 + 1).toString().padLeft(2, '0')}',
            body: 'Entry $i. The quick brown fox jumps over the lazy dog while the morning light moves across the table '
                'and the kettle starts to sing. Word${i % 500} and marker${i}x end here.',
            createdAtMs: base - i * 60000,
            updatedAtMs: base - i * 60000,
          ),
      ]);
    });
    print('SPERF inserted 20000 entries with the search index in ${sw.elapsedMilliseconds} ms');

    for (final q in ['fox', 'marker19999x', 'kett', 'word250 fox', 'nomatchatall', 'brown lazy dog']) {
      // warm up once, then take the median of five runs
      await repo.search(q);
      final times = <int>[];
      var hits = 0;
      for (var i = 0; i < 5; i++) {
        final s = Stopwatch()..start();
        hits = (await repo.search(q)).length;
        times.add(s.elapsedMilliseconds);
      }
      times.sort();
      print('SPERF query "$q": $hits results, median ${times[2]} ms (min ${times.first}, max ${times.last})');
    }
    await db.close();
  }, timeout: const Timeout(Duration(minutes: 10)));
}
