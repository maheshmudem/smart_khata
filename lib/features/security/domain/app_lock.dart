import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';

/// How long the app may stay in the background before it asks for the
/// PIN again (WF-082).
enum AutoLockTimeout {
  immediately('0', Duration.zero),
  oneMinute('60', Duration(minutes: 1)),
  fiveMinutes('300', Duration(minutes: 5));

  const AutoLockTimeout(this.code, this.duration);

  final String code;
  final Duration duration;

  static AutoLockTimeout fromCode(String? code) => values.firstWhere(
    (value) => value.code == code,
    orElse: () => AutoLockTimeout.immediately,
  );
}

/// The owner's app-lock choices. None of this is a secret.
class AppLockConfig extends Equatable {
  const AppLockConfig({
    required this.enabled,
    required this.biometricsEnabled,
    required this.timeout,
  });

  static const AppLockConfig off = AppLockConfig(
    enabled: false,
    biometricsEnabled: false,
    timeout: AutoLockTimeout.immediately,
  );

  /// A PIN has been set.
  final bool enabled;
  final bool biometricsEnabled;
  final AutoLockTimeout timeout;

  @override
  List<Object?> get props => [enabled, biometricsEnabled, timeout];
}

/// The rule for a PIN: four to six digits.
abstract final class PinPolicy {
  static const int minLength = 4;
  static const int maxLength = 6;

  static final RegExp _digits = RegExp(r'^\d+$');

  /// `null` when [pin] is acceptable.
  static ValidationError? validate(String pin) {
    if (pin.isEmpty) return ValidationError.required;
    final ok =
        pin.length >= minLength &&
        pin.length <= maxLength &&
        _digits.hasMatch(pin);
    return ok ? null : ValidationError.invalidPin;
  }
}

/// How long to refuse PIN entry after wrong attempts in a row. A short
/// PIN can be guessed, so guessing is slowed down sharply (SK-1109).
abstract final class LockoutPolicy {
  /// Wrong attempts allowed before the first wait.
  static const int freeAttempts = 5;

  /// The wait after [failedAttempts] wrong PINs in a row; zero while
  /// attempts remain.
  static Duration waitAfter(int failedAttempts) {
    if (failedAttempts < freeAttempts) return Duration.zero;
    return switch (failedAttempts - freeAttempts) {
      0 => const Duration(seconds: 30),
      1 => const Duration(minutes: 1),
      2 => const Duration(minutes: 5),
      _ => const Duration(minutes: 15),
    };
  }

  /// Attempts left before the next wait.
  static int attemptsLeft(int failedAttempts) =>
      failedAttempts >= freeAttempts ? 0 : freeAttempts - failedAttempts;
}

/// What checking a PIN came to.
sealed class PinCheck extends Equatable {
  const PinCheck();
}

final class PinAccepted extends PinCheck {
  const PinAccepted();

  @override
  List<Object?> get props => const [];
}

final class PinRejected extends PinCheck {
  const PinRejected({required this.attemptsLeft});

  /// Tries left before PIN entry is paused.
  final int attemptsLeft;

  @override
  List<Object?> get props => [attemptsLeft];
}

final class PinLockedOut extends PinCheck {
  const PinLockedOut({required this.until});

  /// PIN entry is refused until this instant (UTC).
  final DateTime until;

  @override
  List<Object?> get props => [until];
}

/// App lock: a screen lock against casual access. It does not encrypt the
/// records on the phone and is not a substitute for a backup (WF-003).
///
/// There is no recovery of a forgotten PIN: nothing that could reveal or
/// reset it is stored.
abstract interface class AppLockRepository {
  Future<Result<AppLockConfig>> readConfig();

  /// Sets or replaces the PIN and turns the lock on. Fails with a
  /// validation failure when [pin] breaks [PinPolicy].
  Future<Result<void>> setPin(String pin);

  /// Checks [pin], counting wrong attempts and enforcing [LockoutPolicy].
  Future<Result<PinCheck>> verifyPin(String pin);

  /// Turns the lock off and forgets the PIN hash.
  Future<Result<void>> disable();

  Future<Result<void>> setBiometrics({required bool enabled});

  Future<Result<void>> setTimeout(AutoLockTimeout timeout);
}
