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

  /// The PIN record: hash, salt and rounds together as one JSON value, so
  /// a change is one write. Three separate writes could be cut short and
  /// leave a hash that no PIN matches, with no way back in.
  static const String _pinKey = 'app_lock.pin';

  /// Wrong attempts in a row and the current pause, as one JSON value.
  static const String _attemptsKey = 'app_lock.attempts';
  static const String _biometricsKey = 'app_lock.biometrics';
  static const String _timeoutKey = 'app_lock.timeout';

  final SecretStore _store;
  final Clock _clock;
  final AppLogger _logger;
  final PinHasher _hasher;
  final int _iterations;
  final Random _random;

  @override
  Future<Result<AppLockConfig>> readConfig() => guard(
    () async => AppLockConfig(
      enabled: await _readPin() != null,
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
      await _store.write(
        _pinKey,
        jsonEncode({
          'hash': base64Encode(hash),
          'salt': base64Encode(salt),
          'iterations': _iterations,
        }),
      );
      await _store.delete(_attemptsKey);
    },
    logger: _logger,
    operation: 'appLock.setPin',
  );

  @override
  Future<Result<PinCheck>> verifyPin(String pin) => guard(
    () async {
      final record = await _readPin();
      if (record == null) {
        throw const FailureException(NotFoundFailure('app_lock_pin'));
      }

      final now = _clock.nowUtc();
      final attempts = await _readAttempts();
      final pausedAt = attempts.pausedAt;
      if (pausedAt != null && now.isBefore(pausedAt)) {
        // The clock was set back to before the pause began. Start the
        // same wait again from the new time, once, so that it neither
        // ends early nor lasts until the clock catches up.
        await _writeAttempts(attempts.failed, now, attempts.pause);
        return PinLockedOut(until: now.add(attempts.pause));
      }
      final pausedUntil = attempts.pausedUntil(now);
      if (pausedUntil != null) return PinLockedOut(until: pausedUntil);

      final hash = await _hasher(pin, record.salt, record.iterations);
      if (_constantTimeEquals(hash, record.hash)) {
        await _store.delete(_attemptsKey);
        return const PinAccepted();
      }

      final failed = attempts.failed + 1;
      final wait = LockoutPolicy.waitAfter(failed);
      await _writeAttempts(failed, now, wait);
      return wait > Duration.zero
          ? PinLockedOut(until: now.add(wait))
          : PinRejected(attemptsLeft: LockoutPolicy.attemptsLeft(failed));
    },
    logger: _logger,
    operation: 'appLock.verifyPin',
  );

  @override
  Future<Result<void>> disable() => guard(
    () async {
      for (final key in [_pinKey, _biometricsKey, _attemptsKey]) {
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

  /// The stored PIN record, or `null` when no PIN is set. A record that
  /// cannot be read is treated as damaged storage, not as "no PIN".
  Future<_PinRecord?> _readPin() async {
    final raw = await _store.read(_pinKey);
    if (raw == null) return null;
    final json = jsonDecode(raw);
    if (json is Map<String, Object?>) {
      final hash = json['hash'];
      final salt = json['salt'];
      final iterations = json['iterations'];
      if (hash is String && salt is String && iterations is int) {
        return _PinRecord(
          hash: base64Decode(hash),
          salt: base64Decode(salt),
          iterations: iterations,
        );
      }
    }
    throw const FormatException('app lock pin record');
  }

  Future<void> _writeAttempts(int failed, DateTime now, Duration pause) =>
      _store.write(
        _attemptsKey,
        jsonEncode({
          'failed': failed,
          if (pause > Duration.zero) ...{
            'paused_at_ms': now.millisecondsSinceEpoch,
            'pause_ms': pause.inMilliseconds,
          },
        }),
      );

  Future<_Attempts> _readAttempts() async {
    final raw = await _store.read(_attemptsKey);
    if (raw == null) return const _Attempts();
    final json = jsonDecode(raw);
    if (json is! Map<String, Object?>) return const _Attempts();
    final failed = json['failed'];
    final pausedAt = json['paused_at_ms'];
    final pause = json['pause_ms'];
    return _Attempts(
      failed: failed is int ? failed : 0,
      pausedAt: pausedAt is int
          ? DateTime.fromMillisecondsSinceEpoch(pausedAt, isUtc: true)
          : null,
      pause: pause is int ? Duration(milliseconds: pause) : Duration.zero,
    );
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

class _PinRecord {
  const _PinRecord({
    required this.hash,
    required this.salt,
    required this.iterations,
  });

  final List<int> hash;
  final List<int> salt;
  final int iterations;
}

/// Wrong attempts in a row and the pause they earned.
///
/// The pause is kept as "started at" plus a length, never as an end time,
/// so the phone's clock cannot stretch it: however the clock is set, the
/// wait is at most the length that was earned.
class _Attempts {
  const _Attempts({
    this.failed = 0,
    this.pausedAt,
    this.pause = Duration.zero,
  });

  final int failed;
  final DateTime? pausedAt;
  final Duration pause;

  /// When PIN entry opens again, or `null` if it is open now.
  DateTime? pausedUntil(DateTime now) {
    final start = pausedAt;
    if (start == null || pause <= Duration.zero) return null;
    final until = start.add(pause);
    return now.isBefore(until) ? until : null;
  }
}
