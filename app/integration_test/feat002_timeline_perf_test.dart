// ignore_for_file: avoid_print
// FEAT-002 AC-4 (TC-019): a journal of 20,000 entries. Synthetic text only.
// Numbers from an emulator are indicative; the target is judged on the
// reference device, which is not chosen yet (`nfr-targets-v1`).
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:exoditeanima/data/data_key_source.dart';
import 'package:exoditeanima/data/journal_database.dart';
import 'package:exoditeanima/l10n/strings.dart';
import 'package:exoditeanima/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class _Key implements DataKeySource {
  @override
  Future<Uint8List> load() async =>
      Uint8List.fromList(List.generate(32, (i) => (i * 3 + 1) & 0xff));
}

const entryCount = 20000;

String _body(int i) =>
    'Synthetic entry number $i. The quick brown fox jumps over the lazy dog while the morning light '
    'moves across the table and the kettle starts to sing. Note $i ends here.';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('timeline with $entryCount entries: open time and scrolling frames', (
    t,
  ) async {
    final dir = Directory.systemTemp.createTempSync('exodite_perf_');
    addTearDown(() => dir.deleteSync(recursive: true));

    // Prepare the journal, then close it so the app is its only user.
    final db = await JournalDatabase.openEncrypted(
      File('${dir.path}/journal.db'),
      await _Key().load(),
    );
    final base = DateTime(2026, 9, 20).millisecondsSinceEpoch;
    final seed = Stopwatch()..start();
    await db.batch((b) {
      b.insertAll(db.entries, [
        for (var i = 0; i < entryCount; i++)
          EntriesCompanion.insert(
            uid: i.toRadixString(16).padLeft(32, '0'),
            // Five entries a day, going back in time.
            day: _day(DateTime(2026, 9, 20).subtract(Duration(days: i ~/ 5))),
            body: _body(i),
            createdAtMs: base - i * 60000,
            updatedAtMs: base - i * 60000,
          ),
      ]);
    });
    print('PERF seeded $entryCount entries in ${seed.elapsedMilliseconds} ms');
    await db.close();

    final open = Stopwatch()..start();
    await t.pumpWidget(JournalApp(testKeySource: _Key(), directory: dir));
    while (find.byType(CustomScrollView).evaluate().isEmpty &&
        open.elapsedMilliseconds < 60000) {
      await t.pump(const Duration(milliseconds: 50));
    }
    print(
      'PERF start to a visible list of $entryCount entries: ${open.elapsedMilliseconds} ms',
    );
    expect(find.text(S.newEntry), findsOneWidget);

    final timings = <FrameTiming>[];
    void collect(List<FrameTiming> l) => timings.addAll(l);
    SchedulerBinding.instance.addTimingsCallback(collect);
    final list = find.byType(CustomScrollView);
    for (var i = 0; i < 12; i++) {
      await t.fling(list, const Offset(0, -900), 4000);
      await t.pump(const Duration(milliseconds: 600));
    }
    await t.pump(const Duration(seconds: 1));
    SchedulerBinding.instance.removeTimingsCallback(collect);

    double pct(bool Function(FrameTiming) ok) =>
        timings.isEmpty ? 0 : 100 * timings.where(ok).length / timings.length;
    const budget = Duration(microseconds: 16700);
    print('PERF frames measured: ${timings.length}');
    print(
      'PERF build within 16.7 ms: ${pct((f) => f.buildDuration <= budget).toStringAsFixed(1)} %',
    );
    print(
      'PERF raster within 16.7 ms: ${pct((f) => f.rasterDuration <= budget).toStringAsFixed(1)} %',
    );
    print(
      'PERF build and raster both within 16.7 ms: '
      '${pct((f) => f.buildDuration <= budget && f.rasterDuration <= budget).toStringAsFixed(1)} %',
    );
    final worst = timings
        .map((f) => f.buildDuration.inMicroseconds)
        .fold<int>(0, (a, b) => a > b ? a : b);
    print('PERF worst build: ${(worst / 1000).toStringAsFixed(1)} ms');
    expect(timings, isNotEmpty);
  });
}

String _day(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
