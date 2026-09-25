// The editor screen (S7) at the widget level: FEAT-001 writing, and two
// regressions found on a real emulator on 2026-09-25 - the text field was
// squeezed to nothing by mood, tags and photos when the keyboard was open, and
// a photo's silent first save left a draft that would come back as a second,
// photo-less entry.
import 'dart:io';
import 'dart:typed_data';

import 'package:exoditeanima/data/entry_repository.dart';
import 'package:exoditeanima/data/journal_database.dart';
import 'package:exoditeanima/journal/editor_page.dart';
import 'package:exoditeanima/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List key(int seed) => Uint8List.fromList(List.generate(32, (i) => (i * 7 + seed) & 0xff));

void main() {
  late Directory dir;
  late JournalDatabase db;
  late EntryRepository repo;

  // Real file work never completes under testWidgets' fake clock; see
  // photo_strip_widget_test.dart for the same pattern.
  Future<T> real<T>(WidgetTester tester, Future<T> Function() body) async {
    final result = await tester.runAsync(body);
    return result as T;
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
  }

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('exodite_editor_widget_');
    db = await JournalDatabase.openEncrypted(File('${dir.path}/journal.db'), key(1));
    repo = EntryRepository(db, mediaDirectory: Directory('${dir.path}/media'), dataKey: key(1));
  });
  tearDown(() async {
    await TestWidgetsFlutterBinding.instance.runAsync(() async {
      await db.close();
      for (var i = 0; i < 20; i++) {
        try {
          dir.deleteSync(recursive: true);
          break;
        } on PathAccessException {
          if (i == 19) rethrow;
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    });
  });

  testWidgets('the text field keeps room to write when the keyboard is open on a small screen', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(home: EditorPage(repository: repo)));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, 'Hari ini menulis');
    await tester.pump();

    final field = find.widgetWithText(TextField, 'Hari ini menulis');
    expect(field, findsOneWidget);
    // Before the fix the field got whatever height mood, tags and photos left
    // over: none. It must stay tall enough for several lines.
    expect(tester.getSize(field).height, greaterThan(150));
  });

  testWidgets('a photo\'s silent first save leaves no draft that would restore as a second entry', (tester) async {
    await tester.pumpWidget(MaterialApp(home: EditorPage(repository: repo)));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, 'with a photo');
    await tester.pump();

    // Tap "Add photo", choose the library. The real picker's platform channel
    // does not exist in a test, so the add itself fails and is reported - but
    // not before the entry was saved silently, which is the part under test.
    await tester.tap(find.text(S.addPhoto));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.chooseFromLibrary));
    await settle(tester);
    await settle(tester);

    expect((await real(tester, () => repo.search('with a photo'))).length, 1);

    // The app goes to the background: the editor writes its draft.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await settle(tester);

    // The text is already stored, so there is nothing unsaved to offer back.
    expect(await real(tester, () => repo.loadDraft()), isNull);
  });
}
