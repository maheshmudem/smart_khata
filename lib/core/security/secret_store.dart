/// A small key-value store for values that must not sit in SQLite or
/// plain preferences (PRD 10.3). On the device it is backed by the
/// Android Keystore; tests use an in-memory map.
///
/// It holds a salted PIN hash and lock settings. It never holds a raw
/// PIN, a backup passphrase or a backup key.
abstract interface class SecretStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

/// Asks the device to confirm the owner by fingerprint or face.
abstract interface class BiometricAuth {
  /// Whether the phone has biometrics set up.
  Future<bool> isAvailable();

  /// Shows the system prompt with [reason]. `false` when the owner
  /// cancels, fails, or the prompt cannot be shown.
  Future<bool> authenticate(String reason);
}
