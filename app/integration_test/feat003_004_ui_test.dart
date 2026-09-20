// FEAT-003 (lock) and FEAT-004 (setup) on a real Android build.
// Made-up passcodes and a small key-derivation setting for speed.
import 'dart:convert';
import 'dart:io';

import 'package:exoditeanima/l10n/strings.dart';
import 'package:exoditeanima/main.dart';
import 'package:exoditeanima/security/biometrics.dart';
import 'package:exoditeanima/security/key_vault.dart';
import 'package:exoditeanima/security/secret_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const fast = KdfParams(memoryKiB: 1024, iterations: 1, parallelism: 1);
const good = 'correct horse battery';

/// Lets real asynchronous work (files, key derivation) finish, and frames run.
Future<void> settle(WidgetTester t, {int ms = 1500}) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await t.pump(const Duration(milliseconds: 50));
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

/// Waits (in real time) until [finder] matches, or fails after [seconds].
Future<void> waitFor(WidgetTester t, Finder finder, {int seconds = 30}) async {
  for (var i = 0; i < seconds * 20; i++) {
    await t.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

/// A moment in the background: no frames run while the app is paused.
Future<void> background(WidgetTester t, {int ms = 400}) async {
  t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  t.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
  await Future<void>.delayed(Duration(milliseconds: ms));
}

/// Back in the foreground, in the order the platform reports it.
Future<void> foreground(WidgetTester t, {int ms = 800}) async {
  t.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await settle(t, ms: ms);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  late MemorySecretStore secrets;
  var clock = DateTime(2026, 9, 20, 12);

  setUp(() {
    dir = Directory.systemTemp.createTempSync('exodite_lock_');
    secrets = MemorySecretStore();
    clock = DateTime(2026, 9, 20, 12);
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Future<void> launch(
    WidgetTester t, {
    Biometrics? bio,
    Duration timeout = Duration.zero,
  }) async {
    await t.pumpWidget(
      const SizedBox(),
    ); // drop any earlier app, as a restart does
    await settle(t, ms: 300);
    await t.pumpWidget(
      JournalApp(
        directory: dir,
        secrets: secrets,
        biometrics: bio ?? FakeBiometrics(isAvailable: false),
        kdf: fast,
        lockTimeout: timeout,
        now: () => clock,
      ),
    );
    await settle(t);
  }

  Future<void> enter(WidgetTester t, String key, String text) async {
    await t.enterText(find.byKey(Key(key)), text);
    await t.pump();
  }

  /// Runs the whole first-run flow with the biometric choice given.
  Future<void> setUp3(WidgetTester t, {bool bioOn = false}) async {
    await t.tap(find.text(S.getStarted));
    await settle(t, ms: 500);
    await enter(t, 'passcode', good);
    await enter(t, 'repeat', good);
    await t.tap(find.text(S.continueLabel));
    await settle(t, ms: 500);
    await t.tap(
      find.text(
        bioOn
            ? S.bioTurnOn
            : (find.text(S.bioNotNow).evaluate().isNotEmpty
                  ? S.bioNotNow
                  : S.continueLabel),
      ),
    );
    await settle(t, ms: 500);
    await t.tap(find.byType(Checkbox));
    await t.pump();
    await t.tap(find.text(S.startJournaling));
    await waitFor(t, find.text(S.emptyTitle));
  }

  testWidgets(
    'welcome screen at 200 percent text: no overflow, and the main button stays in view',
    (t) async {
      t.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      await launch(t);
      expect(find.text(S.welcomeTitle), findsOneWidget);
      // The button is pinned below the scrolling content, so it can be tapped without scrolling.
      await t.tap(find.text(S.getStarted));
      await settle(t, ms: 500);
      expect(find.text(S.passcodeTitle), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('FEAT-004 AC-1: on first launch the timeline cannot be reached', (
    t,
  ) async {
    await launch(t);
    expect(find.text(S.welcomeTitle), findsOneWidget);
    expect(find.text(S.appTitle), findsNothing);
    expect(find.text(S.emptyTitle), findsNothing);
  });

  testWidgets(
    'FEAT-004 AC-2, AC-3, AC-7: mismatch, short, and very common passcodes are refused',
    (t) async {
      await launch(t);
      await t.tap(find.text(S.getStarted));
      await settle(t, ms: 400);

      FilledButton cont() => t.widget<FilledButton>(
        find.widgetWithText(FilledButton, S.continueLabel),
      );
      expect(cont().onPressed, isNull);
      expect(find.text(S.passcodeNeeded), findsOneWidget);

      await enter(t, 'passcode', 'short1');
      await enter(t, 'repeat', 'short1');
      expect(cont().onPressed, isNull);

      await enter(t, 'passcode', 'password123');
      expect(find.text(S.passcodeTooCommon), findsOneWidget);
      expect(cont().onPressed, isNull);

      await enter(t, 'passcode', good);
      await enter(t, 'repeat', 'something else');
      expect(find.text(S.passcodeMismatch), findsOneWidget);
      expect(cont().onPressed, isNull);

      await enter(t, 'repeat', good);
      expect(cont().onPressed, isNotNull);
    },
  );

  testWidgets(
    'FEAT-004 AC-4: setup cannot finish until the warning is acknowledged',
    (t) async {
      await launch(t);
      await t.tap(find.text(S.getStarted));
      await settle(t, ms: 400);
      await enter(t, 'passcode', good);
      await enter(t, 'repeat', good);
      await t.tap(find.text(S.continueLabel));
      await settle(t, ms: 500);
      await t.tap(
        find.text(S.continueLabel),
      ); // biometrics not available: Continue
      await settle(t, ms: 400);
      expect(find.text(S.warnTitle), findsOneWidget);
      FilledButton start() => t.widget<FilledButton>(
        find.widgetWithText(FilledButton, S.startJournaling),
      );
      expect(start().onPressed, isNull);
      expect(find.text(S.warnNeeded), findsOneWidget);
      await t.tap(find.byType(Checkbox));
      await t.pump();
      expect(start().onPressed, isNotNull);
      expect(
        File('${dir.path}/vault.json').existsSync(),
        isFalse,
        reason: 'nothing is created before the user starts',
      );
    },
  );

  testWidgets(
    'FEAT-004 AC-5 and FEAT-003 AC-1, AC-5: after setup the app locks, and the passcode opens the journal',
    (t) async {
      await launch(t);
      await setUp3(t);
      expect(
        find.text(S.emptyTitle),
        findsOneWidget,
      ); // the empty timeline opens

      await launch(t); // closed and opened again
      expect(find.text(S.lockTitle), findsOneWidget);
      expect(find.text(S.emptyTitle), findsNothing);

      await enter(t, 'lock-passcode', 'not the passcode');
      await t.tap(find.text(S.unlock));
      await waitFor(t, find.text(S.wrongPasscode));
      expect(find.text(S.wrongPasscode), findsOneWidget);
      expect(find.text(S.lockTitle), findsOneWidget);

      await enter(t, 'lock-passcode', good);
      await t.tap(find.text(S.unlock));
      await waitFor(t, find.text(S.emptyTitle));
      expect(find.text(S.emptyTitle), findsOneWidget);
    },
  );

  testWidgets(
    'FEAT-003 AC-6, AC-7, AC-9, AC-10: six wrong passcodes start a wait that survives a restart',
    (t) async {
      await launch(t);
      await setUp3(t);
      await launch(t);

      for (var i = 0; i < 6; i++) {
        await enter(t, 'lock-passcode', 'wrong passcode $i');
        await t.tap(find.text(S.unlock));
        // The try is over when the field is enabled again, or the wait has begun.
        await waitFor(
          t,
          find.byWidgetPredicate(
            (w) =>
                w is Text &&
                (w.data == S.wrongPasscode ||
                    (w.data ?? '').startsWith('Too many')),
          ),
        );
        await settle(t, ms: 200);
      }
      expect(find.textContaining('Too many tries'), findsOneWidget);
      expect(find.textContaining('0:30'), findsOneWidget);
      expect(
        t
            .widget<FilledButton>(find.widgetWithText(FilledButton, S.unlock))
            .onPressed,
        isNull,
      );
      expect(find.text(S.emptyTitle), findsNothing);

      await launch(t); // closed and opened again
      expect(find.textContaining('Too many tries'), findsOneWidget);
      expect(
        t
            .widget<FilledButton>(find.widgetWithText(FilledButton, S.unlock))
            .onPressed,
        isNull,
      );

      clock = clock.add(const Duration(seconds: 31));
      await launch(t);
      expect(find.textContaining('Too many tries'), findsNothing);
      await enter(t, 'lock-passcode', good);
      await t.tap(find.text(S.unlock));
      await waitFor(t, find.text(S.emptyTitle));
      expect(find.text(S.emptyTitle), findsOneWidget);
    },
  );

  testWidgets(
    'FEAT-003 AC-3: the content is covered while the app is inactive',
    (t) async {
      await launch(t);
      await setUp3(t);
      expect(find.byKey(const Key('privacy-cover')), findsNothing);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await t.pump();
      expect(find.byKey(const Key('privacy-cover')), findsOneWidget);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await t.pump();
      expect(find.byKey(const Key('privacy-cover')), findsNothing);
    },
  );

  testWidgets(
    'FEAT-003 AC-2 and FEAT-002 AC-5: the app locks in the background and shows no entry text',
    (t) async {
      await launch(t);
      await setUp3(t);
      await t.tap(find.text(S.writeFirst));
      await settle(t, ms: 500);
      await t.enterText(find.byType(TextField), 'private words LOCK-1');
      await t.pump();
      await t.tap(find.text(S.save));
      await waitFor(t, find.text(S.today));
      await settle(t, ms: 600); // the editor finishes closing
      expect(
        find.text(S.today),
        findsOneWidget,
        reason: 'back on the timeline',
      );
      expect(find.text('private words LOCK-1'), findsOneWidget);

      await background(t);
      await foreground(t, ms: 800);
      expect(find.text(S.lockTitle), findsOneWidget);
      expect(find.text('private words LOCK-1'), findsNothing);
    },
  );

  testWidgets(
    'FEAT-003 AC-2: within the timeout the app stays open, after it the app locks',
    (t) async {
      await launch(t);
      await setUp3(t);
      await launch(t, timeout: const Duration(minutes: 1));
      await enter(t, 'lock-passcode', good);
      await t.tap(find.text(S.unlock));
      await waitFor(t, find.text(S.emptyTitle));
      expect(find.text(S.emptyTitle), findsOneWidget);

      await background(t);
      clock = clock.add(const Duration(seconds: 30));
      await foreground(t, ms: 300);
      expect(
        find.text(S.emptyTitle),
        findsOneWidget,
        reason: 'back within the timeout',
      );

      await background(t);
      clock = clock.add(const Duration(minutes: 2));
      await foreground(t, ms: 800);
      expect(
        find.text(S.lockTitle),
        findsOneWidget,
        reason: 'away longer than the timeout',
      );
    },
  );

  testWidgets(
    'FEAT-001 AC-4 with the lock: text typed when the app is locked is offered back after unlock',
    (t) async {
      await launch(t);
      await setUp3(t);
      await t.tap(find.text(S.writeFirst));
      await settle(t, ms: 500);
      await t.enterText(find.byType(TextField), 'unsaved thought LOCK-2');
      await t.pump();

      await background(t, ms: 800);
      await foreground(t, ms: 800);
      expect(find.text(S.lockTitle), findsOneWidget);

      await enter(t, 'lock-passcode', good);
      await t.tap(find.text(S.unlock));
      await waitFor(t, find.text(S.resumeTitle));
      expect(find.text(S.resumeTitle), findsOneWidget);
      await t.tap(find.text(S.resumeContinue));
      await settle(t, ms: 500);
      expect(find.text('unsaved thought LOCK-2'), findsOneWidget);
    },
  );

  testWidgets(
    'FEAT-003 AC-4, AC-8: with biometrics on, the passcode still unlocks when biometrics fail',
    (t) async {
      final bio = FakeBiometrics(isAvailable: true, passes: true);
      await launch(t, bio: bio);
      await setUp3(t, bioOn: true);
      expect(
        await KeyVault(
          directory: dir,
          secrets: secrets,
          params: fast,
        ).biometricsEnabled,
        isTrue,
      );

      bio.passes = false; // cancelled or not recognised
      await launch(t, bio: bio);
      expect(find.text(S.lockTitle), findsOneWidget);
      expect(find.text(S.useBiometrics), findsOneWidget);
      await enter(t, 'lock-passcode', good);
      await t.tap(find.text(S.unlock));
      await waitFor(t, find.text(S.emptyTitle));
      expect(find.text(S.emptyTitle), findsOneWidget);

      bio.passes = true; // recognised
      await launch(t, bio: bio);
      await waitFor(t, find.text(S.emptyTitle));
      expect(
        find.text(S.emptyTitle),
        findsOneWidget,
        reason: 'the shortcut opened the journal',
      );
    },
  );

  testWidgets(
    'the journal written before a restart is readable after unlocking, and stays encrypted',
    (t) async {
      await launch(t);
      await setUp3(t);
      await t.tap(find.text(S.writeFirst));
      await settle(t, ms: 500);
      await t.enterText(find.byType(TextField), 'kept across restart LOCK-3');
      await t.pump();
      await t.tap(find.text(S.save));
      await waitFor(t, find.text(S.today));
      await launch(t);
      await enter(t, 'lock-passcode', good);
      await t.tap(find.text(S.unlock));
      await waitFor(t, find.text('kept across restart LOCK-3'));
      expect(find.text('kept across restart LOCK-3'), findsOneWidget);
      for (final f in dir.listSync().whereType<File>()) {
        expect(
          latin1.decode(f.readAsBytesSync()).contains('LOCK-3'),
          isFalse,
          reason: f.path,
        );
      }
    },
  );
}
