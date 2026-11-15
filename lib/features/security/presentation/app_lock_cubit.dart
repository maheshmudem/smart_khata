import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/security/secret_store.dart';
import 'package:smart_khata/features/security/domain/app_lock.dart';

/// Whether the app's content may be shown.
enum LockPhase {
  /// The lock settings are still being read; nothing is shown yet.
  starting,
  unlocked,
  locked,
}

class AppLockState extends Equatable {
  const AppLockState({
    this.phase = LockPhase.starting,
    this.config = AppLockConfig.off,
    this.biometricsAvailable = false,
    this.isChecking = false,
    this.attemptsLeft,
    this.lockedUntil,
    this.failure,
  });

  final LockPhase phase;
  final AppLockConfig config;

  /// The phone has a fingerprint or face set up.
  final bool biometricsAvailable;

  /// A PIN is being checked.
  final bool isChecking;

  /// Set after a wrong PIN: tries left before entry is paused.
  final int? attemptsLeft;

  /// Set while PIN entry is paused after too many wrong tries.
  final DateTime? lockedUntil;
  final Failure? failure;

  bool get canUseBiometrics =>
      config.enabled && config.biometricsEnabled && biometricsAvailable;

  AppLockState copyWith({
    LockPhase? phase,
    AppLockConfig? config,
    bool? biometricsAvailable,
    bool? isChecking,
    int? Function()? attemptsLeft,
    DateTime? Function()? lockedUntil,
    Failure? failure,
  }) => AppLockState(
    phase: phase ?? this.phase,
    config: config ?? this.config,
    biometricsAvailable: biometricsAvailable ?? this.biometricsAvailable,
    isChecking: isChecking ?? this.isChecking,
    attemptsLeft: attemptsLeft == null ? this.attemptsLeft : attemptsLeft(),
    lockedUntil: lockedUntil == null ? this.lockedUntil : lockedUntil(),
    failure: failure,
  );

  @override
  List<Object?> get props => [
    phase,
    config,
    biometricsAvailable,
    isChecking,
    attemptsLeft,
    lockedUntil,
    failure,
  ];
}

/// What changing a lock setting came to.
enum LockChange {
  done,

  /// The current PIN typed to confirm the change was wrong.
  wrongPin,

  /// Too many wrong PINs; entry is paused.
  lockedOut,
  failed,
}

/// The app-wide screen lock (FR-SET-006, WF-082).
///
/// It decides only whether the content is covered. It holds no PIN: each
/// PIN goes straight to the repository to be checked and is then dropped.
class AppLockCubit extends Cubit<AppLockState> {
  AppLockCubit({
    required this._repository,
    required this._biometrics,
    required this._clock,
  }) : super(const AppLockState());

  final AppLockRepository _repository;
  final BiometricAuth _biometrics;
  final Clock _clock;

  DateTime? _pausedAt;

  /// Reads the settings at launch: a shop with a PIN starts locked.
  Future<void> start() async {
    final config = await _readConfig();
    final available = await _biometricsAvailable();
    emit(
      state.copyWith(
        phase: config.enabled ? LockPhase.locked : LockPhase.unlocked,
        config: config,
        biometricsAvailable: available,
      ),
    );
  }

  Future<AppLockConfig> _readConfig() async =>
      // If the settings cannot be read the app stays usable: a lock that
      // shuts the owner out of their own records helps nobody.
      (await _repository.readConfig()).valueOrNull ?? AppLockConfig.off;

  Future<bool> _biometricsAvailable() async {
    try {
      return await _biometrics.isAvailable();
    } on Object {
      return false;
    }
  }

  /// The app went to the background.
  void paused() {
    if (!state.config.enabled || state.phase != LockPhase.unlocked) return;
    _pausedAt = _clock.nowUtc();
    // "Immediately" covers the content before the app is left, so the
    // app switcher does not show it either.
    if (state.config.timeout == AutoLockTimeout.immediately) _lock();
  }

  /// The app came back to the foreground.
  void resumed() {
    final pausedAt = _pausedAt;
    _pausedAt = null;
    if (pausedAt == null || state.phase != LockPhase.unlocked) return;
    final away = _clock.nowUtc().difference(pausedAt);
    if (away >= state.config.timeout.duration) _lock();
  }

  void _lock() => emit(
    state.copyWith(
      phase: LockPhase.locked,
      attemptsLeft: () => null,
      lockedUntil: () => null,
    ),
  );

  /// Checks [pin] and uncovers the app when it is right.
  Future<void> unlockWithPin(String pin) async {
    if (state.isChecking || state.phase != LockPhase.locked) return;
    emit(state.copyWith(isChecking: true));
    switch (await _repository.verifyPin(pin)) {
      case Ok(value: PinAccepted()):
        emit(
          state.copyWith(
            phase: LockPhase.unlocked,
            isChecking: false,
            attemptsLeft: () => null,
            lockedUntil: () => null,
          ),
        );
      case Ok(value: PinRejected(:final attemptsLeft)):
        emit(
          state.copyWith(
            isChecking: false,
            attemptsLeft: () => attemptsLeft,
            lockedUntil: () => null,
          ),
        );
      case Ok(value: PinLockedOut(:final until)):
        emit(
          state.copyWith(
            isChecking: false,
            attemptsLeft: () => null,
            lockedUntil: () => until,
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(isChecking: false, failure: failure));
    }
  }

  /// Shows the fingerprint or face prompt. Never bypasses a paused PIN
  /// entry: biometrics are a shortcut to the PIN, not a second way in.
  Future<void> unlockWithBiometrics(String reason) async {
    if (!state.canUseBiometrics || state.phase != LockPhase.locked) return;
    final until = state.lockedUntil;
    if (until != null && _clock.nowUtc().isBefore(until)) return;
    bool ok;
    try {
      ok = await _biometrics.authenticate(reason);
    } on Object {
      ok = false;
    }
    if (ok && !isClosed && state.phase == LockPhase.locked) {
      emit(
        state.copyWith(
          phase: LockPhase.unlocked,
          attemptsLeft: () => null,
          lockedUntil: () => null,
        ),
      );
    }
  }

  // ---- Settings (WF-082) --------------------------------------------------

  /// Turns the lock on with a first PIN.
  Future<LockChange> enable(String pin) async {
    final result = await _repository.setPin(pin);
    if (!result.isOk) return LockChange.failed;
    await _reload();
    return LockChange.done;
  }

  Future<LockChange> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    final check = await _confirm(currentPin);
    if (check != LockChange.done) return check;
    return enable(newPin);
  }

  Future<LockChange> disable({required String currentPin}) async {
    final check = await _confirm(currentPin);
    if (check != LockChange.done) return check;
    final result = await _repository.disable();
    if (!result.isOk) return LockChange.failed;
    await _reload();
    return LockChange.done;
  }

  Future<void> setBiometrics({required bool enabled}) async {
    await _repository.setBiometrics(enabled: enabled);
    await _reload();
  }

  Future<void> setTimeout(AutoLockTimeout timeout) async {
    await _repository.setTimeout(timeout);
    await _reload();
  }

  Future<LockChange> _confirm(String pin) async =>
      switch (await _repository.verifyPin(pin)) {
        Ok(value: PinAccepted()) => LockChange.done,
        Ok(value: PinRejected()) => LockChange.wrongPin,
        Ok(value: PinLockedOut()) => LockChange.lockedOut,
        Err() => LockChange.failed,
      };

  Future<void> _reload() async {
    final config = await _readConfig();
    if (!isClosed) emit(state.copyWith(config: config));
  }
}
