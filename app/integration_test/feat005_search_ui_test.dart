// FEAT-005 search screens on a real Android build. Made-up text only.
import 'dart:io';
import 'dart:typed_data';

import 'package:exoditeanima/backup/backup_files.dart';
import 'package:exoditeanima/data/data_key_source.dart';
import 'package:exoditeanima/data/entry_repository.dart';
import 'package:exoditeanima/data/journal_database.dart';
import 'package:exoditeanima/l10n/strings.dart';
import 'package:exoditeanima/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

final key = Uint8List.fromList(List.generate(32, (i) => i * 3 + 4));

Future<void> settle(WidgetTester t, {int ms = 1000}) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await t.pump(const Duration(milliseconds: 50));
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

Future<void> waitFor(WidgetTester t, Finder f, {int seconds = 20}) async {
  for (var i = 0; i < seconds * 20; i++) {
    await t.pump(const Duration(milliseconds: 50));
    if (f.evaluate().isNotEmpty) return;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('exodite_srch_'));
  tearDown(() => dir.deleteSync(recursive: true));

  Future<void> seed(List<(String, String)> entries) async {
    final db = await JournalDatabase.openEncrypted(File('${dir.path}/journal.db'), key);
    final repo = EntryRepository(db);
    for (final (day, text) in entries) {
      await repo.create(day: day, body: text);
    }
    await db.close();
  }

  Future<void> launch(WidgetTester t) async {
    await t.pumpWidget(JournalApp(directory: dir, testKeySource: StaticKeySource(key), files: FakeBackupFiles()));
    await waitFor(t, find.byKey(const Key('search-entry')));
    await settle(t, ms: 500);
  }

  Future<void> search(WidgetTester t, String q) async {
    await t.enterText(find.byKey(const Key('search-field')), q);
    await t.pump();
    await settle(t, ms: 700);
  }

  Future<void> openSearch(WidgetTester t) async {
    await t.tap(find.byKey(const Key('search-entry')));
    await settle(t, ms: 500);
  }

  testWidgets('AC-1, AC-3: matching entries are listed with the word marked; a result opens; the query is kept on return', (t) async {
    await seed([
      ('2026-09-20', 'Walked by the river before work. Quiet.'),
      ('2026-09-19', 'Coffee, a slow start.'),
      ('2026-09-07', 'The river was high after the storm.'),
    ]);
    await launch(t);
    await openSearch(t);
    expect(find.text(S.typeAWord), findsOneWidget);

    await search(t, 'river');
    expect(find.text(S.entryCount(2)), findsOneWidget);
    expect(find.textContaining('matched: river'), findsNWidgets(2));
    // The marked word is drawn as its own piece of text.
    final rich = t.widgetList<RichText>(find.byType(RichText)).where((w) => w.text.toPlainText().contains('river'));
    expect(rich, isNotEmpty);

    await t.tap(find.textContaining('storm', findRichText: true));
    await settle(t, ms: 700);
    expect(find.text(S.save), findsOneWidget, reason: 'the entry opened');
    await t.tap(find.byTooltip(S.back));
    await settle(t, ms: 800);
    expect(find.byKey(const Key('search-field')), findsOneWidget);
    expect(find.text(S.entryCount(2)), findsOneWidget, reason: 'the results are still there');
  });

  testWidgets('AC-2: no match shows the no-results message', (t) async {
    await seed([('2026-09-20', 'Walked by the river.')]);
    await launch(t);
    await openSearch(t);
    await search(t, 'kite');
    expect(find.text('No entries contain "kite".'), findsOneWidget);
    expect(find.text(S.tryAnotherWord), findsOneWidget);
  });

  testWidgets('AC-4: an entry deleted from the journal is no longer found', (t) async {
    await seed([('2026-09-20', 'plum blossom SRCH-1'), ('2026-09-21', 'plum tea SRCH-2')]);
    await launch(t);
    await openSearch(t);
    await search(t, 'plum');
    expect(find.text(S.entryCount(2)), findsOneWidget);
    await t.tap(find.textContaining('blossom', findRichText: true));
    await settle(t, ms: 700);
    await t.tap(find.text(S.deleteEntry));
    await settle(t, ms: 600);
    await t.tap(find.widgetWithText(FilledButton, S.deleteEntry));
    await settle(t, ms: 1200);
    expect(find.text(S.entryCount(1)), findsOneWidget);
    expect(find.textContaining('blossom', findRichText: true), findsNothing);
  });

  testWidgets('AC-7 and AC-8: accents and case are ignored, and a word is matched from its start', (t) async {
    await seed([('2026-09-20', 'A small Café by the river.')]);
    await launch(t);
    await openSearch(t);
    await search(t, 'CAFE');
    expect(find.text(S.entryCount(1)), findsOneWidget);
    await search(t, 'café');
    expect(find.text(S.entryCount(1)), findsOneWidget);
    await search(t, 'riv');
    expect(find.text(S.entryCount(1)), findsOneWidget);
    await search(t, 'iver');
    expect(find.text('No entries contain "iver".'), findsOneWidget);
  });

  testWidgets('an empty query after a search returns to the prompt', (t) async {
    await seed([('2026-09-20', 'lamp light')]);
    await launch(t);
    await openSearch(t);
    await search(t, 'lamp');
    expect(find.text(S.entryCount(1)), findsOneWidget);
    await t.tap(find.byTooltip(S.clearSearch));
    await settle(t, ms: 500);
    expect(find.text(S.typeAWord), findsOneWidget);
  });
}
