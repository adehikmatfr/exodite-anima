import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart' as p;

import 'secret_store.dart';

/// Argon2id parameters. Stored next to the wrapped key so they can be raised
/// later (security gap G1). Default chosen by the owner on 2026-09-20 from
/// spike S4: 64 MiB, 3 passes, 2 lanes, a median 1.3 s on a physical phone
/// (Android 11, arm64); the earlier 32 MiB, 1 lane took 3.0 s there. A vault
/// keeps the parameters it was written with.
class KdfParams {
  const KdfParams({this.memoryKiB = 65536, this.iterations = 3, this.parallelism = 2});
  final int memoryKiB;
  final int iterations;
  final int parallelism;

  Map<String, Object> toJson() => {'alg': 'argon2id', 'm': memoryKiB, 't': iterations, 'p': parallelism};

  static KdfParams fromJson(Map<String, dynamic> j) {
    if (j['alg'] != 'argon2id') throw const FormatException('unknown key derivation');
    return KdfParams(memoryKiB: j['m'] as int, iterations: j['t'] as int, parallelism: j['p'] as int);
  }
}

sealed class UnlockResult {}

class Unlocked extends UnlockResult {
  Unlocked(this.dataKey);
  final Uint8List dataKey;
}

/// The passcode was wrong. [failedAttempts] counts wrong tries in a row.
class WrongPasscode extends UnlockResult {
  WrongPasscode(this.failedAttempts, this.waitSeconds);
  final int failedAttempts;

  /// Seconds to wait before the next try; 0 when there is no wait yet.
  final int waitSeconds;
}

/// A wait after wrong tries is running; the passcode was not even checked.
class Waiting extends UnlockResult {
  Waiting(this.until);
  final DateTime until;
}

/// The vault file is unreadable or damaged.
class VaultDamaged extends UnlockResult {}

sealed class ChangePasscodeResult {}

class ChangeDone extends ChangePasscodeResult {}

class ChangeWrongCurrent extends ChangePasscodeResult {
  ChangeWrongCurrent(this.failedAttempts, this.waitSeconds);
  final int failedAttempts;
  final int waitSeconds;
}

class ChangeWaiting extends ChangePasscodeResult {
  ChangeWaiting(this.until);
  final DateTime until;
}

/// The vault could not be read or written; nothing was changed.
class ChangeFailed extends ChangePasscodeResult {}

/// Seconds to wait after [failed] wrong passcodes in a row: five are free, then
/// 30 seconds that doubles with each further wrong try, up to one hour (FEAT-003 AC-9).
int waitSecondsAfter(int failed) {
  if (failed <= 5) return 0;
  final s = 30 * pow(2, failed - 6).toInt();
  return s > 3600 ? 3600 : s;
}

/// Holds the data key wrapped by the passcode (ADR-001).
///
/// * The data key is random, 256 bits, and never stored in the clear here.
/// * `vault.json` keeps it encrypted (AES-256-GCM) under a key derived from the
///   passcode with Argon2id. A wrong passcode fails the authentication tag.
/// * The passcode itself is never stored.
/// * A second copy for the biometric shortcut sits in the OS key store and is
///   released only after the caller has passed the platform biometric prompt.
/// * The count of wrong tries and the running wait are stored in `attempts.json`
///   so they survive closing the app (FEAT-003 AC-10). LIMIT: they are stored in
///   the app's own folder, so changing the phone's clock or clearing app data
///   defeats the wait; clearing app data also destroys the journal key.
class KeyVault {
  KeyVault({
    required this.directory,
    required this.secrets,
    this.params = const KdfParams(),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final Directory directory;
  final SecretStore secrets;
  final KdfParams params;
  final DateTime Function() _now;

  static const _bioName = 'exodite.data_key.bio';

  File get _vaultFile => File(p.join(directory.path, 'vault.json'));
  File get _attemptsFile => File(p.join(directory.path, 'attempts.json'));

  bool get isSetUp => _vaultFile.existsSync();

  /// Creates the journal key and protects it with [passcode]. Returns the data key.
  Future<Uint8List> create(String passcode, {bool enableBiometrics = false}) async {
    final rng = Random.secure();
    final dataKey = Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256)));
    await _writeVault(dataKey, passcode);
    await _clearAttempts();
    if (enableBiometrics) {
      await secrets.write(_bioName, base64.encode(dataKey));
    } else {
      await secrets.delete(_bioName);
    }
    return dataKey;
  }

  /// Wraps [dataKey] under [passcode] with a fresh salt. The new file is written
  /// beside the old one and moved into place, so a crash or a power cut leaves
  /// either the old passcode or the new one working, never neither (FEAT-009, TC-082).
  Future<void> _writeVault(Uint8List dataKey, String passcode) async {
    final rng = Random.secure();
    final salt = Uint8List.fromList(List.generate(16, (_) => rng.nextInt(256)));
    final wrapped = await _wrap(dataKey, passcode, salt, params);
    await directory.create(recursive: true);
    final tmp = File('${_vaultFile.path}.tmp');
    await tmp.writeAsString(jsonEncode({'version': 1, 'kdf': params.toJson(), 'salt': base64.encode(salt), ...wrapped}),
        flush: true);
    await tmp.rename(_vaultFile.path);
  }

  /// Changes the passcode. The current one is checked first, with the same wait
  /// after wrong tries as unlocking. The data key does not change, so every
  /// entry stays readable, and so does the biometric copy.
  Future<ChangePasscodeResult> changePasscode(String current, String next) async {
    final r = await unlockWithPasscode(current);
    switch (r) {
      case Unlocked(:final dataKey):
        try {
          await _writeVault(dataKey, next);
        } catch (_) {
          return ChangeFailed();
        }
        return ChangeDone();
      case WrongPasscode(:final failedAttempts, :final waitSeconds):
        return ChangeWrongCurrent(failedAttempts, waitSeconds);
      case Waiting(:final until):
        return ChangeWaiting(until);
      case VaultDamaged():
        return ChangeFailed();
    }
  }

  Future<bool> get biometricsEnabled async => (await secrets.read(_bioName)) != null;

  /// Turns the biometric shortcut on after the passcode was verified, or off.
  Future<void> setBiometrics(bool on, {Uint8List? dataKey}) async {
    if (on) {
      if (dataKey == null) throw ArgumentError('The data key is needed to turn biometrics on');
      await secrets.write(_bioName, base64.encode(dataKey));
    } else {
      await secrets.delete(_bioName);
    }
  }

  /// Releases the biometric copy of the key. Call it ONLY after the platform
  /// biometric prompt succeeded. Returns null when biometrics are not enabled.
  Future<Uint8List?> releaseBiometricKey() async {
    final s = await secrets.read(_bioName);
    if (s == null) return null;
    final key = base64.decode(s);
    return key.length == 32 ? Uint8List.fromList(key) : null;
  }

  Future<UnlockResult> unlockWithPasscode(String passcode) async {
    final a = await _readAttempts();
    final until = a.lockedUntil;
    if (until != null && until.isAfter(_now())) return Waiting(until);

    final Map<String, dynamic> vault;
    try {
      vault = jsonDecode(await _vaultFile.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return VaultDamaged();
    }
    try {
      final key = await _unwrap(vault, passcode);
      if (key != null) {
        await _clearAttempts();
        return Unlocked(key);
      }
    } on FormatException {
      return VaultDamaged();
    }
    final failed = a.failed + 1;
    final wait = waitSecondsAfter(failed);
    await _writeAttempts(failed, wait == 0 ? null : _now().add(Duration(seconds: wait)));
    return WrongPasscode(failed, wait);
  }

  /// When the current wait ends, or null when there is none.
  Future<DateTime?> waitingUntil() async {
    final until = (await _readAttempts()).lockedUntil;
    return until != null && until.isAfter(_now()) ? until : null;
  }

  Future<int> failedAttempts() async => (await _readAttempts()).failed;

  // ---- internals ---------------------------------------------------------

  Future<Map<String, String>> _wrap(Uint8List dataKey, String passcode, Uint8List salt, KdfParams kdf) async {
    final wrapKey = await _derive(passcode, salt, kdf);
    final box = await AesGcm.with256bits().encrypt(dataKey, secretKey: SecretKey(wrapKey));
    return {
      'nonce': base64.encode(box.nonce),
      'cipher': base64.encode(box.cipherText),
      'mac': base64.encode(box.mac.bytes),
    };
  }

  Future<Uint8List?> _unwrap(Map<String, dynamic> vault, String passcode) async {
    final kdf = KdfParams.fromJson(vault['kdf'] as Map<String, dynamic>);
    final salt = base64.decode(vault['salt'] as String);
    final wrapKey = await _derive(passcode, salt, kdf);
    final box = SecretBox(
      base64.decode(vault['cipher'] as String),
      nonce: base64.decode(vault['nonce'] as String),
      mac: Mac(base64.decode(vault['mac'] as String)),
    );
    try {
      final clear = await AesGcm.with256bits().decrypt(box, secretKey: SecretKey(wrapKey));
      return Uint8List.fromList(clear);
    } on SecretBoxAuthenticationError {
      return null; // wrong passcode
    }
  }

  /// Argon2id runs off the main isolate so the screen never freezes.
  static Future<Uint8List> _derive(String passcode, List<int> salt, KdfParams kdf) {
    final saltBytes = Uint8List.fromList(salt);
    return Isolate.run(() async {
      final algo = Argon2id(
        memory: kdf.memoryKiB,
        parallelism: kdf.parallelism,
        iterations: kdf.iterations,
        hashLength: 32,
      );
      final key = await algo.deriveKeyFromPassword(password: passcode, nonce: saltBytes);
      return Uint8List.fromList(await key.extractBytes());
    });
  }

  Future<({int failed, DateTime? lockedUntil})> _readAttempts() async {
    try {
      final j = jsonDecode(await _attemptsFile.readAsString()) as Map<String, dynamic>;
      final ms = j['until'] as int?;
      return (failed: j['failed'] as int, lockedUntil: ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms));
    } catch (_) {
      return (failed: 0, lockedUntil: null);
    }
  }

  Future<void> _writeAttempts(int failed, DateTime? until) async {
    await directory.create(recursive: true);
    await _attemptsFile.writeAsString(
      jsonEncode({'failed': failed, 'until': until?.millisecondsSinceEpoch}),
      flush: true,
    );
  }

  Future<void> _clearAttempts() async {
    if (_attemptsFile.existsSync()) await _attemptsFile.delete();
  }
}
