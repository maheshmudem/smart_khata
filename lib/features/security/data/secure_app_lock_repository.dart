import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/failure_mapper.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/core/security/secret_store.dart';
import 'package:smart_khata/features/security/domain/app_lock.dart';

/// Turns a PIN and a salt into the bytes that are stored.
typedef PinHasher =
    Future<List<int>> Function(String pin, List<int> salt, int iterations);

/// PBKDF2-HMAC-SHA256 from the `cryptography` package, off the UI thread.
Future<List<int>> pbkdf2PinHasher(
  String pin,
  List<int> salt,
  int iterations,
) => Isolate.run(() => pbkdf2PinHash(pin, salt, iterations));

/// The same hash on the calling isolate (used by tests).
Future<List<int>> pbkdf2PinHash(
  String pin,
  List<int> salt,
  int iterations,
) async {
  final key = await Pbkdf2.hmacSha256(
    iterations: iterations,
    bits: 256,
  ).deriveKey(secretKey: SecretKey(utf8.encode(pin)), nonce: salt);
  return key.extractBytes();
}

/// [AppLockRepository] over a [SecretStore].
///
/// Only a salted, slow hash of the PIN is kept, in Keystore-backed
/// storage. The PIN itself is never written anywhere and never logged.
final class SecureAppLockRepository implements AppLockRepository {
  SecureAppLockRepository({
    required this._store,
    required this._clock,
    required this._logger,
    this._hasher = pbkdf2PinHasher,
    this._iterations = defaultIterations,
    Random? random,
  }) : _random = random ?? Random.secure();

  static const int defaultIterations = 50000;
  static const int saltLength = 16;

  static const String _hashKey = 'app_lock.pin_hash';
  static const String _saltKey = 'app_lock.pin_salt';
  static const String _iterationsKey = 'app_lock.pin_iterations';
  static const String _biometricsKey = 'app_lock.biometrics';
  static const String _timeoutKey = 'app_lock.timeout';
  static const String _failedKey = 'app_lock.failed_attempts';
  static const String _lockedUntilKey = 'app_lock.locked_until';

  final SecretStore _store;
  final Clock _clock;
  final AppLogger _logger;
  final PinHasher _hasher;
  final int _iterations;
  final Random _random;

  @override
  Future<Result<AppLockConfig>> readConfig() => guard(
    () async => AppLockConfig(
      enabled: await _store.read(_hashKey) != null,
      biometricsEnabled: await _store.read(_biometricsKey) == '1',
      timeout: AutoLockTimeout.fromCode(await _store.read(_timeoutKey)),
    ),
    logger: _logger,
    operation: 'appLock.readConfig',
  );

  @override
  Future<Result<void>> setPin(String pin) => guard(
    () async {
      final error = PinPolicy.validate(pin);
      if (error != null) {
        throw FailureException(ValidationFailure({'pin': error}));
      }
      final salt = List<int>.generate(saltLength, (_) => _random.nextInt(256));
      final hash = await _hasher(pin, salt, _iterations);
      await _store.write(_saltKey, base64Encode(salt));
      await _store.write(_iterationsKey, _iterations.toString());
      await _store.write(_hashKey, base64Encode(hash));
      await _clearAttempts();
    },
    logger: _logger,
    operation: 'appLock.setPin',
  );

  @override
  Future<Result<PinCheck>> verifyPin(String pin) => guard(
    () async {
      final storedHash = await _store.read(_hashKey);
      final storedSalt = await _store.read(_saltKey);
      if (storedHash == null || storedSalt == null) {
        throw const FailureException(NotFoundFailure('app_lock_pin'));
      }

      final now = _clock.nowUtc();
      final lockedUntil = await _lockedUntil();
      if (lockedUntil != null && now.isBefore(lockedUntil)) {
        return PinLockedOut(until: lockedUntil);
      }

      final iterations =
          int.tryParse(await _store.read(_iterationsKey) ?? '') ?? _iterations;
      final hash = await _hasher(pin, base64Decode(storedSalt), iterations);
      if (_constantTimeEquals(hash, base64Decode(storedHash))) {
        await _clearAttempts();
        return const PinAccepted();
      }

      final failed =
          (int.tryParse(await _store.read(_failedKey) ?? '') ?? 0) + 1;
      await _store.write(_failedKey, failed.toString());
      final wait = LockoutPolicy.waitAfter(failed);
      if (wait > Duration.zero) {
        final until = now.add(wait);
        await _store.write(
          _lockedUntilKey,
          until.millisecondsSinceEpoch.toString(),
        );
        return PinLockedOut(until: until);
      }
      return PinRejected(attemptsLeft: LockoutPolicy.attemptsLeft(failed));
    },
    logger: _logger,
    operation: 'appLock.verifyPin',
  );

  @override
  Future<Result<void>> disable() => guard(
    () async {
      for (final key in [
        _hashKey,
        _saltKey,
        _iterationsKey,
        _biometricsKey,
        _failedKey,
        _lockedUntilKey,
      ]) {
        await _store.delete(key);
      }
    },
    logger: _logger,
    operation: 'appLock.disable',
  );

  @override
  Future<Result<void>> setBiometrics({required bool enabled}) => guard(
    () => _store.write(_biometricsKey, enabled ? '1' : '0'),
    logger: _logger,
    operation: 'appLock.setBiometrics',
  );

  @override
  Future<Result<void>> setTimeout(AutoLockTimeout timeout) => guard(
    () => _store.write(_timeoutKey, timeout.code),
    logger: _logger,
    operation: 'appLock.setTimeout',
  );

  Future<DateTime?> _lockedUntil() async {
    final millis = int.tryParse(await _store.read(_lockedUntilKey) ?? '');
    return millis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }

  Future<void> _clearAttempts() async {
    await _store.delete(_failedKey);
    await _store.delete(_lockedUntilKey);
  }

  /// Compares every byte, so the time taken does not show where two
  /// hashes first differ.
  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }
}
