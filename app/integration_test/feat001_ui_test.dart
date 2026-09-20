// FEAT-001 screens on a real Android build. Synthetic text and a made-up key only.
import 'dart:io';
import 'dart:typed_data';

import 'package:exoditeanima/data/data_key_source.dart';
import 'package:exoditeanima/data/entry_repository.dart';
import 'package:exoditeanima/data/journal_database.dart';
import 'package:exoditeanima/l10n/strings.dart';
import 'package:exoditeanima/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class _Key implements DataKeySource {
  _Key(this.seed);
  final int seed;
  @override
  Future<Uint8List> load() async =>
      Uint8List.fromList(List.generate(32, (i) => (i * 3 + seed) & 0xff));
}

Future<void> settle(WidgetTester t) async {
  for (var i = 0; i < 20; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('exodite_ui_'));
  tearDown(() => dir.deleteSync(recursive: true));

  Future<void> launch(WidgetTester t, {int seed = 1}) async {
    await t.pumpWidget(JournalApp(testKeySource: _Key(seed), directory: dir));
    await settle(t);
  }

  // Prepares the journal file, then closes it so the app is the only user of the file.
  Future<T> withRepo<T>(
    int seed,
    Future<T> Function(EntryRepository) body,
  ) async {
    final db = await JournalDatabase.openEncrypted(
      File('${dir.path}/journal.db'),
      await _Key(seed).load(),
    );
    try {
      return await body(EntryRepository(db));
    } finally {
      await db.close();
    }
  }

  testWidgets(
    'empty state, write, save (AC-1), Save is off while empty (AC-8)',
    (t) async {
      await launch(t);
      expect(find.text(S.emptyTitle), findsOneWidget);
      await t.tap(find.text(S.writeFirst));
      await settle(t);
      // Empty editor: Save cannot be used and says why.
      final save = t.widget<TextButton>(
        find.widgetWithText(TextButton, S.save),
      );
      expect(save.onPressed, isNull);
      expect(find.text(S.saveNeedsText), findsOneWidget);

      await t.enterText(find.byType(TextField), 'A quiet morning UI-1');
      await t.pump();
      expect(find.text(S.draftKept), findsOneWidget);
      await t.tap(find.text(S.save));
      await settle(t);
      expect(find.text('A quiet morning UI-1'), findsOneWidget);
      expect(find.text(S.today), findsOneWidget);
    },
  );

  testWidgets('edit an entry and save (AC-2)', (t) async {
    await withRepo(
      1,
      (r) => r.create(day: dayKey(DateTime.now()), body: 'before UI-2'),
    );
    await launch(t);
    await t.tap(find.text('before UI-2'));
    await settle(t);
    await t.enterText(find.byType(TextField), 'after UI-2');
    await t.tap(find.text(S.save));
    await settle(t);
    expect(find.text('after UI-2'), findsOneWidget);
    expect(find.text('before UI-2'), findsNothing);
  });

  testWidgets(
    'delete: cancel keeps the entry (AC-7), confirm removes it (AC-6)',
    (t) async {
      await withRepo(
        1,
        (r) => r.create(day: dayKey(DateTime.now()), body: 'doomed UI-3'),
      );
      await launch(t);
      await t.tap(find.text('doomed UI-3'));
      await settle(t);

      await t.tap(find.text(S.deleteEntry));
      await settle(t);
      expect(find.text(S.deleteTitle), findsOneWidget);
      await t.tap(find.text(S.cancel));
      await settle(t);
      await t.tap(find.byTooltip(S.back));
      await settle(t);
      expect(find.text('doomed UI-3'), findsOneWidget);

      await t.tap(find.text('doomed UI-3'));
      await settle(t);
      await t.tap(find.text(S.deleteEntry));
      await settle(t);
      await t.tap(find.widgetWithText(FilledButton, S.deleteEntry));
      await settle(t);
      expect(find.text('doomed UI-3'), findsNothing);
      expect(find.text(S.emptyTitle), findsOneWidget);
    },
  );

  testWidgets('an unsaved draft is offered back at the next start (AC-4)', (
    t,
  ) async {
    await withRepo(
      1,
      (r) =>
          r.saveDraft(day: dayKey(DateTime.now()), body: 'half written UI-4'),
    );
    await launch(t);
    expect(find.text(S.resumeTitle), findsOneWidget);
    await t.tap(find.text(S.resumeContinue));
    await settle(t);
    expect(find.text('half written UI-4'), findsOneWidget);
  });

  testWidgets('discarding the draft removes it', (t) async {
    await withRepo(
      1,
      (r) => r.saveDraft(day: dayKey(DateTime.now()), body: 'unwanted UI-5'),
    );
    await launch(t);
    await t.tap(find.text(S.resumeDiscard));
    await settle(t);
    await t.pumpWidget(const SizedBox()); // the app lets go of the file
    await settle(t);
    expect(await withRepo(1, (r) => r.loadDraft()), isNull);
  });

  testWidgets(
    'a journal that cannot be opened shows S14 and deletes nothing (AC-9)',
    (t) async {
      await withRepo(
        1,
        (r) => r.create(day: dayKey(DateTime.now()), body: 'safe UI-6'),
      );
      final file = File('${dir.path}/journal.db');
      final before = file.lengthSync();
      await launch(t, seed: 9); // a key that does not match
      expect(find.text(S.cannotOpenTitle), findsOneWidget);
      expect(find.textContaining('Nothing has been deleted'), findsOneWidget);
      expect(find.text(S.tryAgain), findsOneWidget);
      expect(find.text(S.importJournal), findsOneWidget);
      expect(file.lengthSync(), before);
    },
  );

  testWidgets('FEAT-002 AC-1 the list groups by day, newest first', (t) async {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    await withRepo(1, (r) async {
      await r.create(day: dayKey(yesterday), body: 'from yesterday UI-7');
      await r.create(day: dayKey(today), body: 'today first UI-7');
      await r.create(day: dayKey(today), body: 'today second UI-7');
    });
    await launch(t);
    expect(find.text(S.today), findsOneWidget);
    expect(find.text(S.yesterday), findsOneWidget);
    double y(String s) => t.getTopLeft(find.text(s)).dy;
    expect(y(S.today), lessThan(y('today second UI-7')));
    expect(y('today second UI-7'), lessThan(y('today first UI-7')));
    expect(y('today first UI-7'), lessThan(y(S.yesterday)));
    expect(y(S.yesterday), lessThan(y('from yesterday UI-7')));
  });

  testWidgets(
    'FEAT-002 the list and the editor lay out at 200 percent text without overflow',
    (t) async {
      t.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      await withRepo(
        1,
        (r) => r.create(
          day: dayKey(DateTime.now()),
          body: 'large text check UI-8',
        ),
      );
      await launch(t);
      expect(find.textContaining('large text check'), findsOneWidget);
      // At 200 percent the search field and the reminder take most of the screen, so the entry
      // is reached by scrolling.
      await t.ensureVisible(find.textContaining('large text check'));
      await t.pump();
      await t.tap(find.textContaining('large text check'));
      await settle(t);
      expect(find.text(S.save), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );
}
