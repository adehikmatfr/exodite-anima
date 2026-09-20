// FEAT-003 / FEAT-004 key handling. Made-up passcodes only. Small Argon2id
// settings keep the tests fast; the real defaults are measured in spike S4.
import 'dart:convert';
import 'dart:io';

import 'package:exoditeanima/security/key_vault.dart';
import 'package:exoditeanima/security/passcode_rules.dart';
import 'package:exoditeanima/security/secret_store.dart';
import 'package:flutter_test/flutter_test.dart';

const fast = KdfParams(memoryKiB: 1024, iterations: 1, parallelism: 1);
const good = 'correct horse battery';

void main() {
  late Directory dir;
  late MemorySecretStore secrets;
  var now = DateTime(2026, 9, 20, 12);

  KeyVault vault() => KeyVault(directory: dir, secrets: secrets, params: fast, now: () => now);

  setUp(() {
    dir = Directory.systemTemp.createTempSync('exodite_vault_');
    secrets = MemorySecretStore();
    now = DateTime(2026, 9, 20, 12);
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('the passcode opens what setup created, and the key is 256 bits (FEAT-004 AC-5)', () async {
    final v = vault();
    expect(v.isSetUp, isFalse);
    final created = await v.create(good);
    expect(created.length, 32);
    expect(v.isSetUp, isTrue);
    final r = await vault().unlockWithPasscode(good);
    expect(r, isA<Unlocked>());
    expect((r as Unlocked).dataKey, created);
  });

  test('a vault written with other settings still opens when the app default differs (G1)', () async {
    const older = KdfParams(memoryKiB: 2048, iterations: 2, parallelism: 1);
    final key = await KeyVault(directory: dir, secrets: secrets, params: older, now: () => now).create(good);
    // a vault built with the app default reads the settings stored in the file
    final r = await KeyVault(directory: dir, secrets: secrets, now: () => now).unlockWithPasscode(good);
    expect(r, isA<Unlocked>());
    expect((r as Unlocked).dataKey, key);
    expect(const KdfParams().memoryKiB, 65536);
    expect(const KdfParams().parallelism, 2);
  });

  test('two setups never produce the same key', () async {
    final a = await vault().create(good);
    dir.listSync().forEach((f) => f.deleteSync());
    final b = await vault().create(good);
    expect(a, isNot(b));
  });

  test('the passcode and the data key are not readable in the stored files (THR-007)', () async {
    final key = await vault().create(good);
    await vault().unlockWithPasscode('wrong wrong wrong');
    for (final f in dir.listSync().whereType<File>()) {
      final text = f.readAsStringSync();
      expect(text.contains(good), isFalse, reason: f.path);
      expect(text.contains(base64.encode(key)), isFalse, reason: f.path);
    }
  });

  test('a wrong passcode is refused and counted (FEAT-003 AC-6)', () async {
    await vault().create(good);
    final r = await vault().unlockWithPasscode('not the passcode');
    expect(r, isA<WrongPasscode>());
    expect((r as WrongPasscode).failedAttempts, 1);
    expect(r.waitSeconds, 0);
  });

  test('five wrong tries are free, then the wait is 30 s and doubles up to one hour (AC-9)', () {
    expect([for (var i = 1; i <= 5; i++) waitSecondsAfter(i)], [0, 0, 0, 0, 0]);
    expect(waitSecondsAfter(6), 30);
    expect(waitSecondsAfter(7), 60);
    expect(waitSecondsAfter(8), 120);
    expect(waitSecondsAfter(11), 960);
    expect(waitSecondsAfter(12), 1920);
    expect(waitSecondsAfter(13), 3600);
    expect(waitSecondsAfter(40), 3600);
  });

  test('after the sixth wrong try the vault waits, even for the right passcode, and the wait survives a restart (AC-7, AC-10)', () async {
    await vault().create(good);
    late UnlockResult last;
    for (var i = 0; i < 6; i++) {
      last = await vault().unlockWithPasscode('wrong $i wrong');
    }
    expect((last as WrongPasscode).waitSeconds, 30);

    // "Restart": a new object over the same folder.
    final r = await vault().unlockWithPasscode(good);
    expect(r, isA<Waiting>());
    expect((r as Waiting).until, now.add(const Duration(seconds: 30)));
    expect(await vault().failedAttempts(), 6);
  });

  test('once the wait is over the right passcode works and clears the count', () async {
    await vault().create(good);
    for (var i = 0; i < 6; i++) {
      await vault().unlockWithPasscode('wrong $i wrong');
    }
    now = now.add(const Duration(seconds: 31));
    expect(await vault().unlockWithPasscode(good), isA<Unlocked>());
    expect(await vault().failedAttempts(), 0);
  });

  test('a wrong try after the wait doubles the wait', () async {
    await vault().create(good);
    for (var i = 0; i < 6; i++) {
      await vault().unlockWithPasscode('wrong $i wrong');
    }
    now = now.add(const Duration(seconds: 31));
    final r = await vault().unlockWithPasscode('again wrong');
    expect((r as WrongPasscode).waitSeconds, 60);
  });

  test('a damaged vault is reported and nothing is deleted (FEAT-001 AC-9)', () async {
    await vault().create(good);
    final f = File('${dir.path}/vault.json');
    f.writeAsStringSync('{ not json');
    expect(await vault().unlockWithPasscode(good), isA<VaultDamaged>());
    expect(f.existsSync(), isTrue);
  });

  test('the biometric copy is released only when enabled, and only holds the same key (FEAT-003 AC-4, AC-8)', () async {
    final v = vault();
    final key = await v.create(good);
    expect(await v.biometricsEnabled, isFalse);
    expect(await v.releaseBiometricKey(), isNull);
    await v.setBiometrics(true, dataKey: key);
    expect(await v.biometricsEnabled, isTrue);
    expect(await v.releaseBiometricKey(), key);
    // The passcode path still works with biometrics on (enrolment change).
    expect(await vault().unlockWithPasscode(good), isA<Unlocked>());
    await v.setBiometrics(false);
    expect(await v.releaseBiometricKey(), isNull);
  });

  test('passcode rules: 8 characters or more, not very common (FEAT-004 AC-3, AC-7)', () {
    expect(checkPasscode('short'), PasscodeProblem.tooShort);
    expect(checkPasscode('1234567'), PasscodeProblem.tooShort);
    expect(checkPasscode('12345678'), PasscodeProblem.tooCommon);
    expect(checkPasscode('Password'), PasscodeProblem.tooCommon);
    expect(checkPasscode(good), isNull);
    expect(checkPasscode('correct horse'), isNull);
  });
}
