// FEAT-011 / FEAT-003: picking a photo hands control to the camera or the
// photo library, backgrounding the app the same way switching to any other
// app does. Without [AutoLockGuard], the shell's "lock immediately" rule
// (`app/lib/main.dart`) fired mid-pick: the database closed, the key was
// wiped, and every screen was popped back to the timeline before the picked
// photo could ever be saved - found on a real device 2026-09-23. These tests
// prove the guard itself, and that the shell actually defers its lock while
// one is held and applies it the moment the last hold ends.
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:exoditeanima/backup/backup_files.dart';
import 'package:exoditeanima/data/data_key_source.dart';
import 'package:exoditeanima/journal/timeline_page.dart';
import 'package:exoditeanima/lock/auto_lock_guard.dart';
import 'package:exoditeanima/lock/lock_page.dart';
import 'package:exoditeanima/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List key(int seed) => Uint8List.fromList(List.generate(32, (i) => (i * 11 + seed) & 0xff));

void main() {
  group('AutoLockGuard', () {
    test('held is false with no active hold', () {
      expect(AutoLockGuard.held, isFalse);
    });

    test('held is true only while an action is in flight', () async {
      final started = Completer<void>();
      final release = Completer<void>();
      final task = AutoLockGuard.hold(() async {
        started.complete();
        await release.future;
        return 1;
      });
      await started.future;
      expect(AutoLockGuard.held, isTrue);
      release.complete();
      expect(await task, 1);
      expect(AutoLockGuard.held, isFalse);
    });

    test('nested holds: held stays true until every hold has released', () async {
      final innerStarted = Completer<void>();
      final releaseOuter = Completer<void>();
      final releaseInner = Completer<void>();
      final outer = AutoLockGuard.hold(() async {
        final inner = AutoLockGuard.hold(() async {
          innerStarted.complete();
          await releaseInner.future;
        });
        await releaseOuter.future;
        await inner;
      });
      await innerStarted.future;
      expect(AutoLockGuard.held, isTrue);
      releaseInner.complete();
      await Future<void>.delayed(Duration.zero);
      expect(AutoLockGuard.held, isTrue, reason: 'the outer hold is still active');
      releaseOuter.complete();
      await outer;
      expect(AutoLockGuard.held, isFalse);
    });

    test('an exception inside the action still releases the hold', () async {
      await expectLater(
        AutoLockGuard.hold(() async => throw StateError('picker failed')),
        throwsStateError,
      );
      expect(AutoLockGuard.held, isFalse);
    });
  });

  group('the app shell defers its lock while a hold is active', () {
    late Directory dir;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('exodite_autolock_shell_');
    });

    tearDown(() async {
      await TestWidgetsFlutterBinding.instance.runAsync(() async {
        for (var i = 0; i < 20; i++) {
          try {
            dir.deleteSync(recursive: true);
            break;
          } on FileSystemException {
            if (i == 19) rethrow;
            await Future<void>.delayed(const Duration(milliseconds: 100));
          }
        }
      });
    });

    /// Opening the journal does real file and native-database work (the same
    /// key derivation and `sqlite3mc` open every other test here needs
    /// `tester.runAsync` for): `pumpAndSettle` alone, under the fake clock,
    /// never sees it finish.
    Future<void> pumpOpenJournal(WidgetTester tester) async {
      await tester.pumpWidget(JournalApp(
        directory: dir,
        lockTimeout: Duration.zero,
        testKeySource: StaticKeySource(key(1)),
        files: FakeBackupFiles(),
      ));
      await tester.runAsync(() async {
        for (var i = 0; i < 100 && find.byType(TimelinePage).evaluate().isEmpty; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          await tester.pump();
        }
      });
      expect(find.byType(TimelinePage), findsOneWidget, reason: 'the journal should be open before each case');
    }

    testWidgets('without a hold, backgrounding locks immediately (baseline)', (tester) async {
      await pumpOpenJournal(tester);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();

      expect(find.byType(LockPage), findsOneWidget);
      expect(find.byType(TimelinePage), findsNothing);
    });

    testWidgets('a photo pick in flight (FEAT-011) keeps the journal open while backgrounded, '
        'then locks the moment it finishes', (tester) async {
      await pumpOpenJournal(tester);

      final release = Completer<void>();
      final pick = AutoLockGuard.hold(() => release.future);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();
      expect(find.byType(TimelinePage), findsOneWidget, reason: 'still open: the picker has not returned yet');
      expect(find.byType(LockPage), findsNothing);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.byType(TimelinePage), findsOneWidget, reason: 'resumed while still held: the lock stays deferred');
      expect(find.byType(LockPage), findsNothing);

      release.complete();
      await pick;
      await tester.pumpAndSettle();
      expect(find.byType(LockPage), findsOneWidget, reason: 'the deferred lock applies the moment the hold ends');
      expect(find.byType(TimelinePage), findsNothing);
    });
  });
}
