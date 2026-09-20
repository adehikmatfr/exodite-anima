import 'package:local_auth/local_auth.dart';

/// The platform face or fingerprint prompt (drawn by the operating system).
abstract class Biometrics {
  /// True when at least one face or fingerprint is set up on the phone.
  Future<bool> get available;

  /// Shows the system prompt. True only when the user passed it.
  Future<bool> authenticate(String reason);
}

class PlatformBiometrics implements Biometrics {
  final _auth = LocalAuthentication();

  @override
  Future<bool> get available async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      return (await _auth.getAvailableBiometrics()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true, // the device passcode is not accepted; the app passcode is the fallback
        persistAcrossBackgrounding: false,
      );
    } catch (_) {
      return false;
    }
  }
}

/// For tests only.
class FakeBiometrics implements Biometrics {
  FakeBiometrics({this.isAvailable = true, this.passes = true});
  bool isAvailable;
  bool passes;

  @override
  Future<bool> get available async => isAvailable;

  @override
  Future<bool> authenticate(String reason) async => passes;
}
