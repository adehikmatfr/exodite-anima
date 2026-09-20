import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Small secrets kept in the OS key store (Android Keystore, iOS Keychain).
abstract class SecretStore {
  Future<String?> read(String name);
  Future<void> write(String name, String value);
  Future<void> delete(String name);
}

class OsSecretStore implements SecretStore {
  OsSecretStore()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(),
          // Never synced to another device or to iCloud Keychain.
          iOptions: IOSOptions(accessibility: KeychainAccessibility.passcode, synchronizable: false),
        );
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String name) => _storage.read(key: name);
  @override
  Future<void> write(String name, String value) => _storage.write(key: name, value: value);
  @override
  Future<void> delete(String name) => _storage.delete(key: name);
}

/// For tests only.
class MemorySecretStore implements SecretStore {
  final Map<String, String> values = {};
  @override
  Future<String?> read(String name) async => values[name];
  @override
  Future<void> write(String name, String value) async => values[name] = value;
  @override
  Future<void> delete(String name) async => values.remove(name);
}
