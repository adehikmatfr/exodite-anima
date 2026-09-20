// FEAT-009: strings in two languages, the settings file, changing the passcode.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:exoditeanima/data/entry_repository.dart';
import 'package:exoditeanima/data/journal_database.dart';
import 'package:exoditeanima/l10n/strings.dart';
import 'package:exoditeanima/security/biometrics.dart';
import 'package:exoditeanima/security/key_vault.dart';
import 'package:exoditeanima/security/secret_store.dart';
import 'package:exoditeanima/settings/settings_controller.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';

const fast = KdfParams(memoryKiB: 1024, iterations: 1, parallelism: 1);
const oldPass = 'correct horse battery';
const newPass = 'another long passphrase';

void main() {
  tearDown(() => setLanguage('en'));

  group('two languages (AC-8, AC-9)', () {
    test('every string exists in English and Indonesian, and none is empty', () {
      final all = allStringsForTest();
      expect(all.length, greaterThan(150));
      const same = {'languageEnglish', 'languageIndonesian', 'languageSystem', 'themeSystem'};
      for (final (name, en, id) in all) {
        expect(en.trim(), isNotEmpty, reason: name);
        expect(id.trim(), isNotEmpty, reason: name);
        if (!same.contains(name)) {
          // Nearly every string differs; a few short words are the same in both languages.
          if (en == id) {
            expect(en.length, lessThan(14), reason: '$name looks untranslated: $en');
          }
        }
      }
    });

    test('the same string names are used for both languages, with no duplicates', () {
      final names = allStringsForTest().map((e) => e.$1).toList();
      expect(names.toSet().length, names.length);
    });

    test('text with values reads in both languages and keeps the value', () {
      for (final lang in ['en', 'id']) {
        setLanguage(lang);
        expect(S.entryCount(1), contains('1'));
        expect(S.entryCount(12), contains('12'));
        expect(S.lastExport('X-WHEN'), contains('X-WHEN'));
        expect(S.waitMessage('0:30'), contains('0:30'));
        expect(S.noResults('kite'), contains('kite'));
        expect(S.matched('river'), contains('river'));
        expect(S.importDoneBody(312, 4), allOf(contains('312'), contains('4')));
        expect(S.entryDateLabel('Sat, 20 Sep 2026'), contains('Sat, 20 Sep 2026'));
      }
    });

    test('switching the language changes the text at once and back again', () {
      setLanguage('en');
      expect(S.save, 'Save');
      setLanguage('id');
      expect(S.save, 'Simpan');
      expect(currentLanguage, 'id');
      setLanguage('xx'); // anything unknown falls back to English
      expect(S.save, 'Save');
    });

    test('a phone in another language gets English; Indonesian and English are followed (AC-9)', () {
      expect(languageForPhone('id'), 'id');
      expect(languageForPhone('en'), 'en');
      expect(languageForPhone('fr'), 'en');
      expect(languageForPhone('ja'), 'en');
      expect(languageForPhone(''), 'en');
    });

    test('dates are written in the chosen language', () {
      setLanguage('en');
      expect(formatDay('2026-08-17'), 'Mon, 17 Aug 2026');
      setLanguage('id');
      expect(formatDay('2026-08-17'), 'Sen, 17 Agu 2026');
      expect(formatDay('2026-05-03'), 'Min, 3 Mei 2026');
    });
  });

  group('settings file and journal', () {
    late Directory dir;
    late MemorySecretStore secrets;

    SettingsController controller({String phone = 'en'}) => SettingsController(
          directory: dir,
          vault: KeyVault(directory: dir, secrets: secrets, params: fast),
          biometrics: FakeBiometrics(),
          phoneLanguage: () => phone,
        );

    setUp(() {
      dir = Directory.systemTemp.createTempSync('exodite_settings_');
      secrets = MemorySecretStore();
    });
    tearDown(() => dir.deleteSync(recursive: true));

    test('theme and language are kept across a restart (AC-1, AC-8)', () async {
      final a = controller();
      await a.loadPrefs();
      expect((a.theme, a.language), (ThemeChoice.system, LanguageChoice.system));
      await a.setTheme(ThemeChoice.dark);
      await a.setLanguageChoice(LanguageChoice.id);
      expect(S.save, 'Simpan');

      setLanguage('en');
      final b = controller();
      await b.loadPrefs();
      expect((b.theme, b.language), (ThemeChoice.dark, LanguageChoice.id));
      expect(b.themeMode, ThemeMode.dark);
      expect(S.save, 'Simpan', reason: 'the saved language is applied when settings load');
    });

    test('follow the phone: English for an unsupported language, Indonesian for Indonesian (AC-9)', () async {
      final fr = controller(phone: 'fr');
      await fr.loadPrefs();
      expect(fr.languageCode, 'en');
      expect(S.save, 'Save');
      final id = controller(phone: 'id');
      await id.loadPrefs();
      expect(id.languageCode, 'id');
      expect(S.save, 'Simpan');
    });

    test('an unreadable or wrong settings file falls back to following the phone', () async {
      File('${dir.path}/prefs.json').writeAsStringSync('{ not json');
      final a = controller();
      await a.loadPrefs();
      expect((a.theme, a.language), (ThemeChoice.system, LanguageChoice.system));
      File('${dir.path}/prefs.json').writeAsStringSync(jsonEncode({'theme': 'neon', 'language': 'klingon'}));
      await a.loadPrefs();
      expect((a.theme, a.language), (ThemeChoice.system, LanguageChoice.system));
    });

    test('the settings file holds no secret (it is plain text)', () async {
      final a = controller();
      await a.loadPrefs();
      await a.setTheme(ThemeChoice.light);
      expect(File('${dir.path}/prefs.json').readAsStringSync(), '{"theme":"light","language":"system"}');
    });

    test('the lock timeout is kept inside the encrypted journal, not in a plain file (AC-5)', () async {
      final key = Uint8List.fromList(List.generate(32, (i) => i + 3));
      var db = await JournalDatabase.openEncrypted(File('${dir.path}/journal.db'), key);
      final a = controller();
      await a.attach(EntryRepository(db), () => key);
      expect(a.lockTimeout, Duration.zero);
      await a.setLockTimeout(const Duration(minutes: 5));
      expect(File('${dir.path}/prefs.json').existsSync() ? File('${dir.path}/prefs.json').readAsStringSync().contains('300') : false, isFalse);
      await db.close();

      db = await JournalDatabase.openEncrypted(File('${dir.path}/journal.db'), key);
      final b = controller();
      await b.attach(EntryRepository(db), () => key);
      expect(b.lockTimeout, const Duration(minutes: 5));
      await db.close();
    });

    test('a stored value that is not one of the four choices is ignored', () async {
      final key = Uint8List.fromList(List.generate(32, (i) => i + 3));
      final db = await JournalDatabase.openEncrypted(File('${dir.path}/journal.db'), key);
      final repo = EntryRepository(db);
      await repo.setLockTimeoutSeconds(999999);
      final a = controller();
      await a.attach(repo, () => key);
      expect(a.lockTimeout, Duration.zero);
      await db.close();
    });

    test('biometrics: off is off; on needs the phone to recognise you (AC-6)', () async {
      final vault = KeyVault(directory: dir, secrets: secrets, params: fast);
      final key = await vault.create(oldPass);
      final bio = FakeBiometrics();
      final a = SettingsController(directory: dir, vault: vault, biometrics: bio, phoneLanguage: () => 'en');
      final db = await JournalDatabase.openEncrypted(File('${dir.path}/journal.db'), key);
      await a.attach(EntryRepository(db), () => key);
      expect(a.biometricsOn, isFalse);

      bio.passes = false;
      expect(await a.setBiometrics(true), BiometricsChange.notRecognised);
      expect(await vault.biometricsEnabled, isFalse);

      bio.passes = true;
      expect(await a.setBiometrics(true), BiometricsChange.on);
      expect(await vault.biometricsEnabled, isTrue);
      expect(await vault.releaseBiometricKey(), key);

      expect(await a.setBiometrics(false), BiometricsChange.off);
      expect(await vault.biometricsEnabled, isFalse);
      expect(await vault.releaseBiometricKey(), isNull);

      bio.isAvailable = false;
      expect(await a.setBiometrics(true), BiometricsChange.unavailable);
      await db.close();
    });
  });

  group('changing the passcode (AC-2 to AC-4)', () {
    late Directory dir;
    late MemorySecretStore secrets;
    var now = DateTime(2026, 9, 20, 12);
    KeyVault vault() => KeyVault(directory: dir, secrets: secrets, params: fast, now: () => now);

    setUp(() {
      dir = Directory.systemTemp.createTempSync('exodite_changepass_');
      secrets = MemorySecretStore();
      now = DateTime(2026, 9, 20, 12);
    });
    tearDown(() => dir.deleteSync(recursive: true));

    test('the new passcode opens the journal, the old one no longer does, and the key is unchanged', () async {
      final key = await vault().create(oldPass);
      expect(await vault().changePasscode(oldPass, newPass), isA<ChangeDone>());
      final r = await vault().unlockWithPasscode(newPass);
      expect(r, isA<Unlocked>());
      expect((r as Unlocked).dataKey, key);
      expect(await vault().unlockWithPasscode(oldPass), isA<WrongPasscode>());
    });

    test('every entry is still readable after the change (AC-3)', () async {
      final key = await vault().create(oldPass);
      var db = await JournalDatabase.openEncrypted(File('${dir.path}/journal.db'), key);
      await EntryRepository(db).create(day: '2026-09-20', body: 'still here CHG-1');
      await db.close();

      await vault().changePasscode(oldPass, newPass);
      final r = await vault().unlockWithPasscode(newPass) as Unlocked;
      db = await JournalDatabase.openEncrypted(File('${dir.path}/journal.db'), r.dataKey);
      expect((await EntryRepository(db).watchAll().first).single.body, 'still here CHG-1');
      await db.close();
    });

    test('a wrong current passcode is refused, nothing changes, and it counts as a wrong try (AC-4)', () async {
      await vault().create(oldPass);
      final before = File('${dir.path}/vault.json').readAsStringSync();
      final r = await vault().changePasscode('not the passcode', newPass);
      expect(r, isA<ChangeWrongCurrent>());
      expect(File('${dir.path}/vault.json').readAsStringSync(), before);
      expect(await vault().failedAttempts(), 1);
      expect(await vault().unlockWithPasscode(oldPass), isA<Unlocked>());
    });

    test('the wait after wrong tries also applies to changing the passcode', () async {
      await vault().create(oldPass);
      for (var i = 0; i < 6; i++) {
        await vault().changePasscode('wrong $i wrong', newPass);
      }
      expect(await vault().changePasscode(oldPass, newPass), isA<ChangeWaiting>());
      expect(await vault().unlockWithPasscode(newPass), isA<Waiting>());
      now = now.add(const Duration(seconds: 31));
      expect(await vault().changePasscode(oldPass, newPass), isA<ChangeDone>());
    });

    test('the biometric shortcut keeps working after a change, with the same key', () async {
      final v = vault();
      final key = await v.create(oldPass, enableBiometrics: true);
      await v.changePasscode(oldPass, newPass);
      expect(await vault().releaseBiometricKey(), key);
    });

    test('an interruption leaves the old passcode working (TC-082): a half-written new file is ignored', () async {
      final key = await vault().create(oldPass);
      // The change writes a temporary file and then moves it over the vault; simulate a crash between the two.
      File('${dir.path}/vault.json.tmp').writeAsStringSync('{"half": "writ');
      final r = await vault().unlockWithPasscode(oldPass);
      expect(r, isA<Unlocked>());
      expect((r as Unlocked).dataKey, key);
      // A later change is not confused by the leftover file.
      expect(await vault().changePasscode(oldPass, newPass), isA<ChangeDone>());
      expect(await vault().unlockWithPasscode(newPass), isA<Unlocked>());
    });

    test('the vault files never hold the passcodes or the key', () async {
      final key = await vault().create(oldPass);
      await vault().changePasscode(oldPass, newPass);
      for (final f in dir.listSync().whereType<File>()) {
        final text = f.readAsStringSync();
        expect(text.contains(oldPass), isFalse);
        expect(text.contains(newPass), isFalse);
        expect(text.contains(base64.encode(key)), isFalse);
      }
    });
  });
}
