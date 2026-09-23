import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart' show DartSha256;
import 'package:path/path.dart' as p;

/// The content hash `media.sha256` stores: of the plaintext bytes, so a
/// consistency check can tell a photo apart from a corrupted or substituted
/// one without needing the data key to decrypt and compare files. The same
/// algorithm `app/lib/backup/backup_service.dart` uses for `entriesSha256`.
String sha256Hex(List<int> bytes) {
  final hash = const DartSha256().hashSync(bytes);
  return hash.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// The encrypted files that back the `media` table (FEAT-011, ADR-002 update
/// 2026-09-23): one file per photo, at `<directory>/<uid>.enc`, encrypted
/// with the app's own data key using AES-256-GCM and a fresh random nonce
/// each time - the same primitive already used for the export envelope and
/// key wrapping (`app/lib/backup/envelope.dart`, `app/lib/security/key_vault.dart`),
/// not a new choice. Layout: `nonce (12 bytes) | ciphertext | mac (16 bytes)`;
/// no header is needed, since this file is never read by anything but this
/// app's own current code, unlike the export envelope.
class MediaFiles {
  MediaFiles(this.directory, this.dataKey);
  final Directory directory;
  final Uint8List dataKey;

  static const _nonceLength = 12;
  static const _macLength = 16;

  File pathFor(String uid) => File(p.join(directory.path, '$uid.enc'));

  /// Encrypts [bytes] and writes them under [uid]. Atomic (ADR-002's
  /// atomic-write rule): written to a temp file first, then moved into
  /// place, so a crash mid-write never leaves a half-written photo file
  /// that a `media` row could end up pointing to.
  Future<void> write(String uid, Uint8List bytes) async {
    final rng = Random.secure();
    final nonce = Uint8List.fromList(List.generate(_nonceLength, (_) => rng.nextInt(256)));
    final box = await AesGcm.with256bits().encrypt(bytes, secretKey: SecretKey(dataKey), nonce: nonce);
    final out = BytesBuilder(copy: false)
      ..add(nonce)
      ..add(box.cipherText)
      ..add(box.mac.bytes);
    await directory.create(recursive: true);
    final tmp = File('${pathFor(uid).path}.tmp');
    await tmp.writeAsBytes(out.toBytes(), flush: true);
    await tmp.rename(pathFor(uid).path);
  }

  /// Decrypts and returns [uid]'s bytes. Throws if the file is missing,
  /// too short to hold a nonce and a tag, or fails authentication (damaged,
  /// or encrypted under a different key) - FEAT-011 AC-8's "photo cannot be
  /// read" path.
  Future<Uint8List> read(String uid) async {
    final raw = await pathFor(uid).readAsBytes();
    if (raw.length < _nonceLength + _macLength) {
      throw const FormatException('photo file is too short to be genuine');
    }
    final nonce = raw.sublist(0, _nonceLength);
    final mac = Mac(raw.sublist(raw.length - _macLength));
    final cipherText = raw.sublist(_nonceLength, raw.length - _macLength);
    final clear = await AesGcm.with256bits().decrypt(
      SecretBox(cipherText, nonce: nonce, mac: mac),
      secretKey: SecretKey(dataKey),
    );
    return Uint8List.fromList(clear);
  }

  /// Deletes [uid]'s file, if it exists. Not an error if it does not -
  /// callers use this both to clean up normally and to recover from a
  /// partially-added photo (FEAT-011 AC-3, AC-4).
  Future<void> delete(String uid) async {
    final f = pathFor(uid);
    if (await f.exists()) await f.delete();
  }
}
