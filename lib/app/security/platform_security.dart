import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:smart_khata/core/security/secret_store.dart';

/// [SecretStore] on the device: values encrypted with a key held in the
/// Android Keystore, in app-private storage.
final class PlatformSecretStore implements SecretStore {
  const PlatformSecretStore();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// [BiometricAuth] through the system fingerprint or face prompt.
final class PlatformBiometricAuth implements BiometricAuth {
  PlatformBiometricAuth();

  final LocalAuthentication _auth = LocalAuthentication();

  @override
  Future<bool> isAvailable() async {
    if (!await _auth.isDeviceSupported()) return false;
    return (await _auth.getAvailableBiometrics()).isNotEmpty;
  }

  @override
  Future<bool> authenticate(String reason) =>
      _auth.authenticate(localizedReason: reason, biometricOnly: true);
}
