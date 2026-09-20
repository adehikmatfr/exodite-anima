// FEAT-009 Settings on a real Android build. Made-up passcodes; small key derivation for speed.
import 'dart:io';
import 'dart:typed_data';

import 'package:exoditeanima/backup/backup_files.dart';
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

const fast = KdfParams(memoryKiB: 1024, iterations: 1, parallelism: 1);
const pass = 'correct horse battery';
const newPass = 'another long passphrase';

Future<void> settle(WidgetTester t, {int ms = 1000}) async {
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

Future<void> background(WidgetTester t, {int ms = 400}) async {
  t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  t.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
  await Future<void>.delayed(Duration(milliseconds: ms));
}

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
    dir = Directory.systemTemp.createTempSync('exodite_set_');
    secrets = MemorySecretStore();
    clock = DateTime(2026, 9, 20, 12);
    setLanguage('en');
  });
  tearDown(() {
    dir.deleteSync(recursive: true);
    setLanguage('en');
  });

  KeyVault vault() => KeyVault(directory: dir, secrets: secrets, params: fast, now: () => clock);

  /// A journal that was set up earlier, with the given entries.
  Future<Uint8List> prepare({List<String> entries = const [], bool biometrics = false}) async {
    final key = await vault().create(pass, enableBiometrics: biometrics);
    final db = await JournalDatabase.openEncrypted(File('${dir.path}/journal.db'), key);
    final repo = EntryRepository(db);
    for (final e in entries) {
      await repo.create(day: '2026-09-19', body: e);
    }
    await db.close();
    return key;
  }

  Future<void> launch(WidgetTester t, {Biometrics? bio, String phone = 'en'}) async {
    await t.pumpWidget(const SizedBox());
    await settle(t, ms: 300);
    await t.pumpWidget(JournalApp(
      directory: dir,
      secrets: secrets,
      biometrics: bio ?? FakeBiometrics(isAvailable: false),
      kdf: fast,
      files: FakeBackupFiles(),
      now: () => clock,
      phoneLanguage: () => phone,
    ));
    await waitFor(t, find.byKey(const Key('lock-passcode')));
    await settle(t, ms: 400);
  }

  Future<void> unlock(WidgetTester t, String code, Finder expected) async {
    await t.enterText(find.byKey(const Key('lock-passcode')), code);
    await t.pump();
    await t.tap(find.text(S.unlock));
    await waitFor(t, expected);
    await settle(t, ms: 400);
  }

  Future<void> openSettings(WidgetTester t) async {
    await t.tap(find.text(S.settings));
    await settle(t, ms: 600);
  }

  Future<void> tapRow(WidgetTester t, String key) async {
    final f = find.byKey(Key(key));
    if (f.evaluate().isEmpty) {
      await t.scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).first);
    }
    await t.ensureVisible(f);
    await t.pump();
    await t.tap(f);
    await settle(t, ms: 600);
  }

  Future<void> toTop(WidgetTester t) async {
    await t.drag(find.byType(ListView).first, const Offset(0, 900));
    await settle(t, ms: 400);
  }

  Brightness brightness(WidgetTester t) => Theme.of(t.element(find.byType(Scaffold).first)).brightness;

  testWidgets('AC-1: the theme can be light, dark, or follow the phone, and is kept after a restart', (t) async {
    await prepare(entries: ['theme text SET-1']);
    await launch(t);
    expect(brightness(t), Brightness.light);
    await unlock(t, pass, find.text('theme text SET-1'));
    await openSettings(t);
    expect(find.text(S.themeSystem), findsWidgets);
    await tapRow(t, 'row-theme');
    await t.tap(find.text(S.themeDark));
    await settle(t, ms: 700);
    expect(brightness(t), Brightness.dark);
    expect(find.text(S.themeDark), findsOneWidget, reason: 'the row shows the choice');

    await launch(t);
    expect(brightness(t), Brightness.dark, reason: 'kept after a restart, even on the lock screen');
    await unlock(t, pass, find.text('theme text SET-1'));
    expect(brightness(t), Brightness.dark);

    await openSettings(t);
    await tapRow(t, 'row-theme');
    await t.tap(find.text(S.themeLight));
    await settle(t, ms: 700);
    expect(brightness(t), Brightness.light);
  });

  testWidgets('AC-8: picking Indonesian changes all text at once, and it stays after a restart', (t) async {
    await prepare(entries: ['catatan bahasa SET-2']);
    await launch(t);
    await unlock(t, pass, find.text('catatan bahasa SET-2'));
    await openSettings(t);
    await tapRow(t, 'row-language');
    expect(find.text(S.languageSystemNote), findsOneWidget);
    await t.tap(find.text('Bahasa Indonesia'));
    await settle(t, ms: 800);
    await toTop(t);

    // The open Settings screen is already in Indonesian.
    expect(find.text('Pengaturan'), findsOneWidget);
    expect(find.text('Tampilan'), findsOneWidget);
    expect(find.text('Keamanan'), findsOneWidget);
    expect(find.text('Ganti kode sandi'), findsOneWidget);
    expect(find.text('Settings'), findsNothing);

    await t.tap(find.byTooltip('Kembali'));
    await settle(t, ms: 600);
    expect(find.text('Jurnal'), findsOneWidget);
    expect(find.text('Cari catatan Anda'), findsOneWidget);
    expect(find.text('Hari ini'), findsNothing, reason: 'the entry is dated 19 Sep');

    await launch(t);
    expect(find.text('Masukkan kode sandi Anda'), findsOneWidget, reason: 'the lock screen is in Indonesian after a restart');
    expect(find.text('Enter your passcode'), findsNothing);
  });

  testWidgets('AC-9: a phone in another language starts in English; an Indonesian phone starts in Indonesian', (t) async {
    await prepare();
    await launch(t, phone: 'fr');
    expect(find.text('Enter your passcode'), findsOneWidget);
    await launch(t, phone: 'id');
    expect(find.text('Masukkan kode sandi Anda'), findsOneWidget);
    await launch(t, phone: 'en');
    expect(find.text('Enter your passcode'), findsOneWidget);
  });

  testWidgets('AC-2, AC-3, AC-4: change the passcode; a wrong current one is refused; entries stay readable', (t) async {
    await prepare(entries: ['keep me SET-3']);
    await launch(t);
    await unlock(t, pass, find.text('keep me SET-3'));
    await openSettings(t);
    await tapRow(t, 'row-change-passcode');

    // A wrong current passcode is refused.
    await t.enterText(find.byKey(const Key('current-passcode')), 'not my passcode');
    await t.enterText(find.byKey(const Key('new-passcode')), newPass);
    await t.enterText(find.byKey(const Key('repeat-new-passcode')), newPass);
    await t.pump();
    await t.tap(find.widgetWithText(FilledButton, S.changePasscodeButton));
    await waitFor(t, find.text(S.currentPasscodeWrong));
    expect(find.text(S.currentPasscodeWrong), findsOneWidget);
    expect(find.text(S.passcodeChangedTitle), findsNothing);

    // The right one changes it.
    await t.enterText(find.byKey(const Key('current-passcode')), pass);
    await t.pump();
    await t.tap(find.widgetWithText(FilledButton, S.changePasscodeButton));
    await waitFor(t, find.text(S.passcodeChangedTitle));
    expect(find.text(S.passcodeChangedTitle), findsOneWidget);
    await t.tap(find.text(S.done));
    await settle(t, ms: 500);

    await launch(t);
    await t.enterText(find.byKey(const Key('lock-passcode')), pass);
    await t.pump();
    await t.tap(find.text(S.unlock));
    await waitFor(t, find.text(S.wrongPasscode));
    expect(find.text(S.wrongPasscode), findsOneWidget, reason: 'the old passcode no longer works');
    await unlock(t, newPass, find.text('keep me SET-3'));
    expect(find.text('keep me SET-3'), findsOneWidget, reason: 'the entry is still readable');
  });

  testWidgets('the new passcode must follow the rules: too short, very common, and different repeats are refused', (t) async {
    await prepare();
    await launch(t);
    await unlock(t, pass, find.text(S.emptyTitle));
    await openSettings(t);
    await tapRow(t, 'row-change-passcode');
    FilledButton button() => t.widget<FilledButton>(find.widgetWithText(FilledButton, S.changePasscodeButton));

    await t.enterText(find.byKey(const Key('current-passcode')), pass);
    await t.enterText(find.byKey(const Key('new-passcode')), 'short12');
    await t.enterText(find.byKey(const Key('repeat-new-passcode')), 'short12');
    await t.pump();
    expect(button().onPressed, isNull);

    await t.enterText(find.byKey(const Key('new-passcode')), 'password123');
    await t.enterText(find.byKey(const Key('repeat-new-passcode')), 'password123');
    await t.pump();
    expect(find.text(S.passcodeTooCommon), findsOneWidget);
    expect(button().onPressed, isNull);

    await t.enterText(find.byKey(const Key('new-passcode')), newPass);
    await t.enterText(find.byKey(const Key('repeat-new-passcode')), 'different one');
    await t.pump();
    expect(find.text(S.passcodeMismatch), findsOneWidget);
    expect(button().onPressed, isNull);
  });

  testWidgets('AC-5: a chosen lock timeout is used, and kept after a restart', (t) async {
    await prepare(entries: ['timeout SET-4']);
    await launch(t);
    await unlock(t, pass, find.text('timeout SET-4'));
    await openSettings(t);
    expect(find.text(S.timeoutImmediately), findsOneWidget, reason: 'the default');
    await tapRow(t, 'row-lock-timeout');
    expect(find.text(S.timeoutRecommended), findsOneWidget);
    await t.tap(find.text(S.timeout1));
    await settle(t, ms: 700);
    expect(find.text(S.timeout1), findsOneWidget);
    await toTop(t);
    await t.tap(find.byTooltip(S.back));
    await settle(t, ms: 500);

    await background(t);
    clock = clock.add(const Duration(seconds: 30));
    await foreground(t);
    expect(find.text('timeout SET-4'), findsOneWidget, reason: 'back within a minute');

    await background(t);
    clock = clock.add(const Duration(minutes: 2));
    await foreground(t);
    expect(find.text(S.lockTitle), findsOneWidget, reason: 'away longer than a minute');

    await launch(t);
    await unlock(t, pass, find.text('timeout SET-4'));
    await openSettings(t);
    expect(find.text(S.timeout1), findsOneWidget, reason: 'kept after a restart');
  });

  testWidgets('AC-6: with face and fingerprint turned off, only the passcode unlocks', (t) async {
    await prepare(entries: ['bio SET-5'], biometrics: true);
    final bio = FakeBiometrics(isAvailable: true, passes: false);
    await launch(t, bio: bio);
    expect(find.text(S.useBiometrics), findsOneWidget, reason: 'the shortcut is offered while it is on');
    await unlock(t, pass, find.text('bio SET-5'));
    await openSettings(t);
    expect(find.text(S.on), findsWidgets);

    await tapRow(t, 'row-biometrics');
    await settle(t, ms: 600);
    expect(find.text(S.off), findsWidgets);
    expect(await vault().biometricsEnabled, isFalse);

    await launch(t, bio: bio);
    expect(find.text(S.useBiometrics), findsNothing, reason: 'no shortcut when it is off');
    await unlock(t, pass, find.text('bio SET-5'));
    expect(find.text('bio SET-5'), findsOneWidget);
  });

  testWidgets('turning face and fingerprint on: refused when the phone has none, and when it does not recognise you', (t) async {
    await prepare();
    final bio = FakeBiometrics(isAvailable: false);
    await launch(t, bio: bio);
    await unlock(t, pass, find.text(S.emptyTitle));
    await openSettings(t);
    await tapRow(t, 'row-biometrics');
    expect(find.text(S.biometricsUnavailable), findsOneWidget);
    expect(await vault().biometricsEnabled, isFalse);

    bio
      ..isAvailable = true
      ..passes = false;
    await tapRow(t, 'row-biometrics');
    expect(find.text(S.biometricsFailed), findsOneWidget);
    expect(await vault().biometricsEnabled, isFalse);

    bio.passes = true;
    await tapRow(t, 'row-biometrics');
    expect(await vault().biometricsEnabled, isTrue);
    expect(find.text(S.biometricsFailed), findsNothing);
  });

  testWidgets('AC-7: About and privacy states the four points, in both languages', (t) async {
    await prepare();
    await launch(t);
    await unlock(t, pass, find.text(S.emptyTitle));
    await openSettings(t);
    await tapRow(t, 'row-about');
    for (final s in [S.aboutPoint1, S.aboutPoint2, S.aboutPoint3, S.aboutPoint4]) {
      expect(find.text(s), findsOneWidget);
    }
    expect(find.text('Nothing you write is uploaded or shared by the app.'), findsOneWidget);
    setLanguage('id');
    expect(S.aboutPoint4, 'Jika Anda lupa kode sandi, jurnal Anda tidak bisa dipulihkan.');
  });
}
