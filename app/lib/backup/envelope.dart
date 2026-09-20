import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// The encrypted envelope of an export (ADR-003, decided in spike S6).
///
/// ```
/// header (47 bytes, not secret, authenticated as associated data):
///   "EXANIMA" 0x01        8   magic and envelope version
///   kdf id                1   1 = Argon2id
///   memory KiB            4   big endian
///   passes                4
///   lanes                 1
///   salt                 16
///   nonce                12
/// then the ciphertext (AES-256-GCM of the ZIP) followed by the 16-byte tag.
/// ```
/// The key comes from the export password with Argon2id; the parameters live in
/// the header so they can be raised later. The ZIP inside is the same one the
/// plaintext export contains.
class EnvelopeParams {
  const EnvelopeParams({this.memoryKiB = 65536, this.iterations = 3, this.lanes = 1});
  final int memoryKiB;
  final int iterations;
  final int lanes;
}

/// What exports use unless a caller says otherwise. Tests replace it with a cheap setting.
EnvelopeParams envelopeDefaults = const EnvelopeParams();

enum EnvelopeProblem { notEncrypted, unsupported, wrongPasswordOrDamaged }

class EnvelopeException implements Exception {
  EnvelopeException(this.problem);
  final EnvelopeProblem problem;
  @override
  String toString() => 'EnvelopeException: $problem';
}

const _magic = [0x45, 0x58, 0x41, 0x4E, 0x49, 0x4D, 0x41, 0x01]; // "EXANIMA" 1
const headerLength = 47;
const _tagLength = 16;

// What a file may ask the importer to spend on key derivation. Anything above is refused.
const _maxMemoryKiB = 262144; // 256 MiB
const _maxIterations = 10;
const _maxLanes = 4;

bool isEncryptedBackup(Uint8List bytes) {
  if (bytes.length < _magic.length) return false;
  for (var i = 0; i < _magic.length; i++) {
    if (bytes[i] != _magic[i]) return false;
  }
  return true;
}

Future<Uint8List> encryptBackup(Uint8List zip, String password, {EnvelopeParams? params}) async {
  params ??= envelopeDefaults;
  final rng = Random.secure();
  final salt = Uint8List.fromList(List.generate(16, (_) => rng.nextInt(256)));
  final nonce = Uint8List.fromList(List.generate(12, (_) => rng.nextInt(256)));
  final header = _header(params, salt, nonce);
  final key = await _derive(password, salt, params);
  final box = await AesGcm.with256bits().encrypt(zip, secretKey: SecretKey(key), nonce: nonce, aad: header);
  final out = BytesBuilder(copy: false)
    ..add(header)
    ..add(box.cipherText)
    ..add(box.mac.bytes);
  return out.toBytes();
}

/// Returns the ZIP. The header is authenticated, so a changed header, a changed
/// body, a cut-off file, and a wrong password all end in the same error.
Future<Uint8List> decryptBackup(Uint8List file, String password) async {
  if (!isEncryptedBackup(file)) throw EnvelopeException(EnvelopeProblem.notEncrypted);
  if (file.length < headerLength + _tagLength) throw EnvelopeException(EnvelopeProblem.wrongPasswordOrDamaged);
  final view = ByteData.sublistView(file);
  if (file[8] != 1) throw EnvelopeException(EnvelopeProblem.unsupported);
  final memory = view.getUint32(9, Endian.big);
  final iterations = view.getUint32(13, Endian.big);
  final lanes = file[17];
  if (memory < 8 || memory > _maxMemoryKiB || iterations < 1 || iterations > _maxIterations || lanes < 1 || lanes > _maxLanes) {
    throw EnvelopeException(EnvelopeProblem.unsupported);
  }
  final salt = file.sublist(18, 34);
  final nonce = file.sublist(34, 46);
  final header = file.sublist(0, headerLength);
  final cipher = file.sublist(headerLength, file.length - _tagLength);
  final mac = file.sublist(file.length - _tagLength);
  final key = await _derive(password, salt, EnvelopeParams(memoryKiB: memory, iterations: iterations, lanes: lanes));
  try {
    final clear = await AesGcm.with256bits().decrypt(
      SecretBox(cipher, nonce: nonce, mac: Mac(mac)),
      secretKey: SecretKey(key),
      aad: header,
    );
    return Uint8List.fromList(clear);
  } on SecretBoxAuthenticationError {
    throw EnvelopeException(EnvelopeProblem.wrongPasswordOrDamaged);
  }
}

Uint8List _header(EnvelopeParams p, Uint8List salt, Uint8List nonce) {
  final h = ByteData(headerLength);
  final bytes = h.buffer.asUint8List();
  bytes.setRange(0, 8, _magic);
  bytes[8] = 1;
  h.setUint32(9, p.memoryKiB, Endian.big);
  h.setUint32(13, p.iterations, Endian.big);
  bytes[17] = p.lanes;
  bytes.setRange(18, 34, salt);
  bytes.setRange(34, 46, nonce);
  return bytes;
}

/// Runs off the main isolate so the screen keeps moving.
Future<Uint8List> _derive(String password, List<int> salt, EnvelopeParams p) {
  final saltBytes = Uint8List.fromList(salt);
  final pw = utf8.encode(password);
  return Isolate.run(() async {
    final algo = Argon2id(memory: p.memoryKiB, parallelism: p.lanes, iterations: p.iterations, hashLength: 32);
    final key = await algo.deriveKey(secretKey: SecretKey(pw), nonce: saltBytes);
    return Uint8List.fromList(await key.extractBytes());
  });
}
