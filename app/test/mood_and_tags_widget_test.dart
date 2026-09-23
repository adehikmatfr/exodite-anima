// FEAT-010 AC-1 to AC-4 at the widget level: the mood picker and tag input
// built in `app/lib/journal/mood_and_tags.dart`, matching the design in
// `product-design/tools/gen_screens.py` ("S7 Editor / Mood and tags").
import 'package:exoditeanima/data/entry_repository.dart';
import 'package:exoditeanima/journal/mood_and_tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('AC-1, AC-2: tapping a mood selects it; tapping the selected one again clears it', (tester) async {
    Mood? current;
    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) => MoodPicker(
            selected: current,
            onChanged: (m) => setState(() => current = m),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Good'));
    await tester.pump();
    expect(current, Mood.good);

    await tester.tap(find.text('Good'));
    await tester.pump();
    expect(current, isNull, reason: 'tapping the selected mood again clears it');
  });

  testWidgets('AC-3, AC-4: tapping a preset tag adds it; tapping it again removes it', (tester) async {
    List<String> current = [];
    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) => TagInput(
            tags: current,
            onChanged: (t) => setState(() => current = t),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Family'));
    await tester.pump();
    expect(current, ['Family']);

    await tester.tap(find.text('Family'));
    await tester.pump();
    expect(current, isEmpty, reason: 'tapping the selected tag again removes it');
  });

  testWidgets('AC-3: a free-text tag typed through "Add a tag" is added once', (tester) async {
    List<String> current = [];
    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) => TagInput(
            tags: current,
            onChanged: (t) => setState(() => current = t),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add a tag'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'photography');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(current, ['photography']);
    expect(find.text('photography'), findsOneWidget, reason: 'the free-text tag now shows as a chip, same as a preset one');
  });
}
