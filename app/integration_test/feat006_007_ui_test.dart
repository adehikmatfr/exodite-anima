// FEAT-006 (export) and FEAT-007 (import) screens on a real Android build.
// Made-up text and passwords; nothing is shared or picked through the real system dialogs.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:exoditeanima/backup/backup_files.dart';
import 'package:exoditeanima/backup/backup_service.dart';
import 'package:exoditeanima/backup/envelope.dart';
import 'package:exoditeanima/data/data_key_source.dart';
import 'package:exoditeanima/data/entry_repository.dart';
import 'package:exoditeanima/data/journal_database.dart';
import 'package:exoditeanima/l10n/strings.dart';
import 'package:exoditeanima/main.dart';
import 'package:exoditeanima/security/biometrics.dart';
import 'package:exoditeanima/security/key_vault.dart';
import 'package:exoditeanima/security/secret_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const cheap = EnvelopeParams(memoryKiB: 1024, iterations: 1, lanes: 1);
const pw = 'export password 1';
final key = Uint8List.fromList(List.generate(32, (i) => i * 7 + 1));

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

StoredEntry stored(int i, {String? text}) => StoredEntry(
      uid: i.toRadixString(16).padLeft(32, '0'),
      day: '2026-09-${(i % 28 + 1).toString().padLeft(2, '0')}',
      text: text ?? 'imported entry $i BK-$i',
      createdAtMs: DateTime.utc(2026, 9, 1).millisecondsSinceEpoch + i * 1000,
      updatedAtMs: DateTime.utc(2026, 9, 1).millisecondsSinceEpoch + i * 1000,
    );

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  envelopeDefaults = cheap; // a cheap key derivation keeps the tests fast
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('exodite_bk_'));
  tearDown(() => dir.deleteSync(recursive: true));

  Future<void> launch(WidgetTester t, BackupFiles files) async {
    await t.pumpWidget(const SizedBox());
    await settle(t, ms: 300);
    await t.pumpWidget(JournalApp(directory: dir, testKeySource: StaticKeySource(key), files: files));
    await waitFor(t, find.text(S.settings));
    await settle(t, ms: 300);
  }

  Future<void> seed(List<String> texts) async {
    final db = await JournalDatabase.openEncrypted(File('${dir.path}/journal.db'), key);
    final repo = EntryRepository(db);
    for (var i = 0; i < texts.length; i++) {
      await repo.create(day: '2026-09-${(i + 1).toString().padLeft(2, '0')}', body: texts[i]);
    }
    await db.close();
  }

  Future<void> openExport(WidgetTester t) async {
    await t.tap(find.text(S.settings));
    await settle(t, ms: 500);
    await t.tap(find.text(S.exportRow));
    await settle(t, ms: 500);
  }

  Future<void> enter(WidgetTester t, String k, String v) async {
    await t.enterText(find.byKey(Key(k)), v);
    await t.pump();
  }

  testWidgets('FEAT-006 AC-1, AC-4, AC-6: a protected export is made, holds every entry, and the last export time is updated', (t) async {
    await seed(['first EXP-1', 'second EXP-2', 'third EXP-3']);
    final files = FakeBackupFiles();
    await launch(t, files);
    await openExport(t);
    expect(find.text(S.exportProtected), findsOneWidget);
    await t.tap(find.text(S.continueLabel));
    await settle(t, ms: 400);

    // A short password is refused with no file created (AC-9).
    await enter(t, 'export-password', 'short');
    await enter(t, 'export-password-repeat', 'short');
    expect(t.widget<FilledButton>(find.widgetWithText(FilledButton, S.exportButton)).onPressed, isNull);
    expect(files.lastShared, isNull);

    await enter(t, 'export-password', pw);
    await enter(t, 'export-password-repeat', pw);
    await t.tap(find.text(S.exportButton));
    await waitFor(t, find.text(S.exportDoneTitle));
    expect(find.text(S.exportDoneTitle), findsOneWidget);
    expect(find.text(S.keepPasswordTitle), findsOneWidget);

    final shared = files.lastShared!;
    expect(isEncryptedBackup(shared), isTrue);
    expect(latin1.decode(shared).contains('EXP-1'), isFalse);
    expect(files.lastSharedName, endsWith('.anima'));
    final back = await readBackup(shared, password: pw);
    expect(back.entries.length, 3);
    expect(back.entries.map((e) => e.text), containsAll(['first EXP-1', 'second EXP-2', 'third EXP-3']));

    await t.tap(find.text(S.done));
    await settle(t, ms: 500);
    expect(find.textContaining('Last export: today'), findsOneWidget);
  });

  testWidgets('FEAT-006 AC-3: the readable export shows its warning first and creates nothing until it is confirmed', (t) async {
    await seed(['plain PL-1']);
    final files = FakeBackupFiles();
    await launch(t, files);
    await openExport(t);
    await t.tap(find.text(S.exportPlain));
    await t.pump();
    await t.tap(find.text(S.continueLabel));
    await settle(t, ms: 600);
    expect(find.text(S.warnPlainTitle), findsOneWidget);
    expect(files.lastShared, isNull);

    await t.tap(find.text(S.goBack));
    await settle(t, ms: 500);
    expect(files.lastShared, isNull, reason: 'going back creates nothing');

    await t.tap(find.text(S.continueLabel));
    await settle(t, ms: 600);
    await t.tap(find.text(S.exportWithoutProtection));
    await waitFor(t, find.text(S.exportDoneTitle));
    final shared = files.lastShared!;
    expect(isEncryptedBackup(shared), isFalse);
    expect(files.lastSharedName, endsWith('.zip'));
    expect((await readBackup(shared)).entries.single.text, 'plain PL-1');
  });

  testWidgets('FEAT-006 AC-7: an export that fails, or is closed in the share dialog, leaves the last export time unchanged', (t) async {
    await seed(['keep KP-1']);
    final files = FakeBackupFiles(shareFails: true);
    await launch(t, files);
    await openExport(t);
    await t.tap(find.text(S.continueLabel));
    await settle(t, ms: 400);
    await enter(t, 'export-password', pw);
    await enter(t, 'export-password-repeat', pw);
    await t.tap(find.text(S.exportButton));
    await waitFor(t, find.text(S.exportErrorTitle));
    expect(find.text(S.exportErrorTitle), findsOneWidget);
    await t.tap(find.text(S.cancel));
    await settle(t, ms: 500);
    expect(find.text(S.neverExported), findsOneWidget);

    files
      ..shareFails = false
      ..shareOutcome = ShareOutcome.cancelled;
    await t.tap(find.text(S.exportRow));
    await settle(t, ms: 500);
    await t.tap(find.text(S.continueLabel));
    await settle(t, ms: 400);
    await enter(t, 'export-password', pw);
    await enter(t, 'export-password-repeat', pw);
    await t.tap(find.text(S.exportButton));
    await waitFor(t, find.text(S.exportPasswordTitle));
    await settle(t, ms: 500);
    expect(find.text(S.exportDoneTitle), findsNothing);
    await t.tap(find.byTooltip('Back'));
    await settle(t, ms: 300);
    await t.tap(find.byTooltip('Back'));
    await settle(t, ms: 500);
    expect(find.text(S.neverExported), findsOneWidget);
  });

  testWidgets('FEAT-007 AC-1, AC-6, AC-8: a protected file is imported; entries that are already here are kept', (t) async {
    await seed(['already here, my own text OWN-1']);
    final db = await JournalDatabase.openEncrypted(File('${dir.path}/journal.db'), key);
    final mine = (await EntryRepository(db).readAllForExport()).single;
    await db.close();
    final file = await createBackup([
      StoredEntry(uid: mine.uid, day: mine.day, text: 'CHANGED TEXT', createdAtMs: 1, updatedAtMs: 1),
      stored(2),
      stored(3),
    ], password: pw);
    final files = FakeBackupFiles(picked: file);
    await launch(t, files);
    await t.tap(find.text(S.settings));
    await settle(t, ms: 500);
    await t.tap(find.text(S.importRow));
    await settle(t, ms: 500);
    await t.tap(find.text(S.chooseFile));
    await waitFor(t, find.text(S.importPasswordTitle));

    await enter(t, 'import-password', 'the wrong password');
    await t.tap(find.text(S.importButton));
    await waitFor(t, find.text(S.importWrongPassword));
    expect(find.text(S.importWrongPassword), findsOneWidget);

    await enter(t, 'import-password', pw);
    await t.tap(find.text(S.importButton));
    await waitFor(t, find.text(S.importDoneTitle));
    expect(find.text(S.importDoneBody(2, 1)), findsOneWidget);
    await t.tap(find.text(S.openMyJournal));
    await settle(t, ms: 800);
    expect(find.text('imported entry 2 BK-2'), findsOneWidget);
    expect(find.text('already here, my own text OWN-1'), findsOneWidget);
    expect(find.text('CHANGED TEXT'), findsNothing);
  });

  testWidgets('FEAT-007 AC-3, AC-5: a damaged file, a file that is not an export, and a newer export all leave the journal unchanged', (t) async {
    await seed(['safe SF-1']);
    final good = await createBackup([stored(5)]);
    final cut = good.sublist(0, good.length - 20);
    final files = FakeBackupFiles(picked: cut);
    await launch(t, files);
    await t.tap(find.text(S.settings));
    await settle(t, ms: 500);
    await t.tap(find.text(S.importRow));
    await settle(t, ms: 500);

    await t.tap(find.text(S.chooseFile));
    await waitFor(t, find.textContaining('nothing was imported'));
    expect(find.text(S.importDamagedTitle), findsOneWidget);

    files.picked = Uint8List.fromList(utf8.encode('this is just some text, not a backup at all'));
    await t.tap(find.text(S.chooseAnotherFile));
    await waitFor(t, find.text(S.importWrongFileTitle));
    expect(find.text(S.importWrongFileTitle), findsOneWidget);

    await t.tap(find.text(S.cancel));
    await settle(t, ms: 500);
    await t.tap(find.byTooltip(S.back));
    await settle(t, ms: 500);
    expect(find.text('safe SF-1'), findsOneWidget);
    expect(find.textContaining('BK-5'), findsNothing);
  });

  testWidgets('FEAT-007 AC-9: on a fresh install, restoring sets the passcode first and then starts the import', (t) async {
    final file = await createBackup([stored(7), stored(8)]);
    final files = FakeBackupFiles(picked: file);
    final secrets = MemorySecretStore();
    await t.pumpWidget(JournalApp(
      directory: dir,
      secrets: secrets,
      biometrics: FakeBiometrics(isAvailable: false),
      kdf: const KdfParams(memoryKiB: 1024, iterations: 1, parallelism: 1),
      files: files,
    ));
    await waitFor(t, find.text(S.importJournal));
    await t.tap(find.text(S.importJournal));
    await settle(t, ms: 500);
    // The passcode comes first.
    expect(find.text(S.passcodeTitle), findsOneWidget);
    expect(find.text(S.importTitle), findsNothing);
    await t.enterText(find.byKey(const Key('passcode')), 'correct horse battery');
    await t.enterText(find.byKey(const Key('repeat')), 'correct horse battery');
    await t.pump();
    await t.tap(find.text(S.continueLabel));
    await settle(t, ms: 600);
    await t.tap(find.text(S.continueLabel)); // biometrics not available
    await settle(t, ms: 500);
    await t.tap(find.byType(Checkbox));
    await t.pump();
    await t.tap(find.text(S.startJournaling));
    await waitFor(t, find.text(S.importTitle));
    expect(find.text(S.importTitle), findsOneWidget, reason: 'the import starts after setup');
    expect(File('${dir.path}/vault.json').existsSync(), isTrue);

    await t.tap(find.text(S.chooseFile));
    await waitFor(t, find.text(S.importDoneTitle));
    await t.tap(find.text(S.openMyJournal));
    await settle(t, ms: 800);
    expect(find.text('imported entry 7 BK-7'), findsOneWidget);
    expect(find.text('imported entry 8 BK-8'), findsOneWidget);
  });
}
