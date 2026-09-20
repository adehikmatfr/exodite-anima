// FEAT-008 export reminder on a real Android build. Made-up text only.
import 'dart:io';
import 'dart:typed_data';

import 'package:exoditeanima/backup/backup_files.dart';
import 'package:exoditeanima/backup/envelope.dart';
import 'package:exoditeanima/data/data_key_source.dart';
import 'package:exoditeanima/data/entry_repository.dart';
import 'package:exoditeanima/data/journal_database.dart';
import 'package:exoditeanima/l10n/strings.dart';
import 'package:exoditeanima/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

final key = Uint8List.fromList(List.generate(32, (i) => i * 5 + 2));

Future<void> settle(WidgetTester t, {int ms = 1200}) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await t.pump(const Duration(milliseconds: 50));
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

Future<void> waitFor(WidgetTester t, Finder f, {int seconds = 30}) async {
  for (var i = 0; i < seconds * 20; i++) {
    await t.pump(const Duration(milliseconds: 50));
    if (f.evaluate().isNotEmpty) return;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  envelopeDefaults = const EnvelopeParams(memoryKiB: 1024, iterations: 1, lanes: 1);
  late Directory dir;
  var clock = DateTime(2026, 9, 20, 10);

  setUp(() {
    dir = Directory.systemTemp.createTempSync('exodite_rem_');
    clock = DateTime(2026, 9, 20, 10);
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Future<T> withRepo<T>(Future<T> Function(EntryRepository) body) async {
    final db = await JournalDatabase.openEncrypted(File('${dir.path}/journal.db'), key);
    try {
      return await body(EntryRepository(db, nowMs: () => clock.millisecondsSinceEpoch));
    } finally {
      await db.close();
    }
  }

  Future<void> launch(WidgetTester t, BackupFiles files) async {
    await t.pumpWidget(const SizedBox());
    await settle(t, ms: 300);
    await t.pumpWidget(JournalApp(directory: dir, testKeySource: StaticKeySource(key), files: files, now: () => clock));
    await waitFor(t, find.text(S.settings));
    await settle(t, ms: 600);
  }

  final card = find.byKey(const Key('export-reminder'));

  testWidgets('AC-1, AC-6: never exported and entries exist: the reminder is shown and holds no entry text', (t) async {
    await withRepo((r) => r.create(day: '2026-09-19', body: 'my private words REM-1'));
    await launch(t, FakeBackupFiles());
    expect(card, findsOneWidget);
    expect(find.text(S.reminderNeverTitle), findsOneWidget);
    final inside = find.descendant(of: card, matching: find.byType(Text)).evaluate().map((e) => (e.widget as Text).data).toList();
    expect(inside, [S.reminderNeverTitle, S.reminderBody, S.reminderExportNow, S.reminderLater]);
    expect(inside.join(' ').contains('REM-1'), isFalse);
  });

  testWidgets('an empty journal shows no reminder', (t) async {
    await withRepo((r) => r.count());
    await launch(t, FakeBackupFiles());
    expect(card, findsNothing);
  });

  testWidgets('AC-4: Later hides it for 7 days, and it returns on the 7th day after', (t) async {
    await withRepo((r) => r.create(day: '2026-09-19', body: 'words REM-2'));
    final files = FakeBackupFiles();
    await launch(t, files);
    await t.tap(find.text(S.reminderLater));
    await settle(t, ms: 800);
    expect(card, findsNothing);

    clock = DateTime(2026, 9, 26, 22);
    await launch(t, files);
    expect(card, findsNothing, reason: 'six days later it is still hidden');

    clock = DateTime(2026, 9, 27, 8);
    await launch(t, files);
    expect(card, findsOneWidget, reason: 'the condition still holds, so it returns');
  });

  testWidgets('AC-5: exporting from the reminder makes it disappear', (t) async {
    await withRepo((r) => r.create(day: '2026-09-19', body: 'words REM-3'));
    final files = FakeBackupFiles();
    await launch(t, files);
    await t.tap(find.text(S.reminderExportNow));
    await settle(t, ms: 600);
    expect(find.text(S.exportRow), findsWidgets);
    await t.tap(find.text(S.continueLabel));
    await settle(t, ms: 400);
    await t.enterText(find.byKey(const Key('export-password')), 'export password 1');
    await t.enterText(find.byKey(const Key('export-password-repeat')), 'export password 1');
    await t.pump();
    await t.tap(find.text(S.exportButton));
    await waitFor(t, find.text(S.exportDoneTitle));
    await t.tap(find.text(S.done));
    await settle(t, ms: 800);
    expect(card, findsNothing);
    expect(files.lastShared, isNotNull);
  });

  testWidgets('AC-2 and AC-3: a recent export with nothing new shows nothing; 45 days later with a new entry it is shown', (t) async {
    await withRepo((r) async {
      await r.create(day: '2026-09-19', body: 'words REM-4');
      clock = DateTime(2026, 9, 20, 11);
      await r.recordExport(clock);
    });
    clock = DateTime(2026, 9, 22, 10);
    await launch(t, FakeBackupFiles());
    expect(card, findsNothing);

    clock = DateTime(2026, 11, 4, 10); // 45 days after the export
    await withRepo((r) => r.create(day: '2026-11-03', body: 'newer words REM-5'));
    await launch(t, FakeBackupFiles());
    expect(find.text(S.reminderOverdueTitle), findsOneWidget);
  });

  testWidgets('FEAT-008 point 1: the export screen shows the last export, or that none was made', (t) async {
    await withRepo((r) => r.create(day: '2026-09-19', body: 'words REM-6'));
    await launch(t, FakeBackupFiles());
    await t.tap(find.text(S.settings));
    await settle(t, ms: 500);
    expect(find.text(S.neverExported), findsOneWidget);
    await t.tap(find.text(S.exportRow));
    await settle(t, ms: 500);
    expect(find.text(S.neverExported), findsOneWidget);
  });
}
