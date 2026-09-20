import 'dart:typed_data';

/// Where the 256-bit data key comes from (ADR-001). In the app it is the key
/// released by the lock screen (`KeyVault`); tests may supply their own.
abstract class DataKeySource {
  Future<Uint8List> load();
}

/// A key already in memory.
class StaticKeySource implements DataKeySource {
  const StaticKeySource(this.key);
  final Uint8List key;

  @override
  Future<Uint8List> load() async => key;
}
