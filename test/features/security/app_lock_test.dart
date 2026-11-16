import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/features/security/domain/app_lock.dart';
import 'package:smart_khata/features/security/presentation/app_lock_cubit.dart';

import '../../helpers/test_env.dart';

void main() {
  late TestEnv env;

  setUp(() => env = TestEnv());
  tearDown(() => env.dispose());

  void wait(Duration by) => env.clock.now = env.clock.now.add(by);

  group('PIN and lockout rules (SK-1109)', () {
    test('a PIN is four to six digits', () {
      expect(PinPolicy.validate('1234'), isNull);
      expect(PinPolicy.validate('123456'), isNull);
      expect(PinPolicy.validate(''), ValidationError.required);
      expect(PinPolicy.validate('123'), ValidationError.invalidPin);
      expect(PinPolicy.validate('1234567'), ValidationError.invalidPin);
      expect(PinPolicy.validate('12a4'), ValidationError.invalidPin);
      expect(PinPolicy.validate('12 4'), ValidationError.invalidPin);
    });

    test('five tries are free; then the wait grows', () {
      expect(LockoutPolicy.waitAfter(0), Duration.zero);
      expect(LockoutPolicy.waitAfter(4), Duration.zero);
      expect(LockoutPolicy.attemptsLeft(4), 1);
      expect(LockoutPolicy.waitAfter(5), const Duration(seconds: 30));
      expect(LockoutPolicy.attemptsLeft(5), 0);
      expect(LockoutPolicy.waitAfter(6), const Duration(minutes: 1));
      expect(LockoutPolicy.waitAfter(7), const Duration(minutes: 5));
      expect(LockoutPolicy.waitAfter(8), const Duration(minutes: 15));
      expect(LockoutPolicy.waitAfter(50), const Duration(minutes: 15));
    });

    test('an unknown timeout code falls back to locking at once', () {
      expect(AutoLockTimeout.fromCode('60'), AutoLockTimeout.oneMinute);
      expect(AutoLockTimeout.fromCode(null), AutoLockTimeout.immediately);
      expect(AutoLockTimeout.fromCode('x'), AutoLockTimeout.immediately);
    });
  });

  group('SecureAppLockRepository', () {
    test('the lock is off until a PIN is set', () async {
      expect((await env.appLock.readConfig()).valueOrNull, AppLockConfig.off);
      expect((await env.appLock.verifyPin('1234')).isOk, isFalse);
    });

    test('a bad PIN is refused and nothing is stored', () async {
      final result = await env.appLock.setPin('12');
      expect(
        result.failureOrNull,
        const ValidationFailure({'pin': ValidationError.invalidPin}),
      );
      expect(env.secrets.values, isEmpty);
    });

    test('only a salted hash is stored, never the PIN', () async {
      await env.appLock.setPin('482913');
      expect((await env.appLock.readConfig()).valueOrNull!.enabled, isTrue);
      for (final value in env.secrets.values.values) {
        expect(value, isNot(contains('482913')));
      }
      // The same PIN set again gets a new salt and so a different hash.
      final first = env.secrets.values['app_lock.pin'];
      await env.appLock.setPin('482913');
      expect(env.secrets.values['app_lock.pin'], isNot(first));
      // Nothing about it reaches the log.
      expect(
        env.logger.records.where((r) => r.message.contains('482913')),
        isEmpty,
      );
    });

    test('the right PIN is accepted; a wrong one counts down', () async {
      await env.appLock.setPin('1234');
      expect(
        (await env.appLock.verifyPin('1234')).valueOrNull,
        const PinAccepted(),
      );
      expect(
        (await env.appLock.verifyPin('9999')).valueOrNull,
        const PinRejected(attemptsLeft: 4),
      );
      expect(
        (await env.appLock.verifyPin('1235')).valueOrNull,
        const PinRejected(attemptsLeft: 3),
      );
      // A right PIN clears the count.
      await env.appLock.verifyPin('1234');
      expect(
        (await env.appLock.verifyPin('0000')).valueOrNull,
        const PinRejected(attemptsLeft: 4),
      );
    });

    test('too many wrong PINs pause entry, even for the right PIN', () async {
      await env.appLock.setPin('1234');
      for (var i = 0; i < 4; i++) {
        await env.appLock.verifyPin('0000');
      }
      final fifth = (await env.appLock.verifyPin('0000')).valueOrNull;
      final until = env.clock.now.add(const Duration(seconds: 30));
      expect(fifth, PinLockedOut(until: until));

      // The right PIN is refused while paused.
      expect(
        (await env.appLock.verifyPin('1234')).valueOrNull,
        PinLockedOut(until: until),
      );

      wait(const Duration(seconds: 31));
      // One more wrong try after the pause doubles the wait.
      expect(
        (await env.appLock.verifyPin('0000')).valueOrNull,
        PinLockedOut(until: env.clock.now.add(const Duration(minutes: 1))),
      );
      wait(const Duration(minutes: 2));
      expect(
        (await env.appLock.verifyPin('1234')).valueOrNull,
        const PinAccepted(),
      );
    });

    test(
      'the PIN record is one value, so a change cannot be half done',
      () async {
        await env.appLock.setPin('1234');
        // Hash, salt and rounds live under a single key.
        expect(env.secrets.values.keys, ['app_lock.pin']);

        // Storage fails while the PIN is being changed: the old PIN must
        // still open the app.
        env.secrets.fail = true;
        expect((await env.appLock.setPin('5678')).isOk, isFalse);
        env.secrets.fail = false;
        expect(
          (await env.appLock.verifyPin('1234')).valueOrNull,
          const PinAccepted(),
        );
        expect(
          (await env.appLock.verifyPin('5678')).valueOrNull,
          const PinRejected(attemptsLeft: 4),
        );
      },
    );

    test('a damaged PIN record is a failure, never an open door', () async {
      await env.appLock.setPin('1234');
      env.secrets.values['app_lock.pin'] = '{"hash": 7}';
      expect((await env.appLock.verifyPin('1234')).isOk, isFalse);
      expect((await env.appLock.readConfig()).isOk, isFalse);
    });

    test('setting the clock back does not end or stretch a pause', () async {
      await env.appLock.setPin('1234');
      for (var i = 0; i < 5; i++) {
        await env.appLock.verifyPin('0000');
      }
      // The owner (or anyone) moves the phone's date back a year.
      env.clock.now = env.clock.now.subtract(const Duration(days: 365));
      final check = (await env.appLock.verifyPin('1234')).valueOrNull;
      // Still paused, and only for the 30 seconds that were earned: not
      // for a year.
      expect(
        check,
        PinLockedOut(until: env.clock.now.add(const Duration(seconds: 30))),
      );
      wait(const Duration(seconds: 31));
      expect(
        (await env.appLock.verifyPin('1234')).valueOrNull,
        const PinAccepted(),
      );
    });

    test('settings are kept; turning the lock off forgets the PIN', () async {
      await env.appLock.setPin('1234');
      await env.appLock.setBiometrics(enabled: true);
      await env.appLock.setTimeout(AutoLockTimeout.fiveMinutes);
      expect(
        (await env.appLock.readConfig()).valueOrNull,
        const AppLockConfig(
          enabled: true,
          biometricsEnabled: true,
          timeout: AutoLockTimeout.fiveMinutes,
        ),
      );

      await env.appLock.disable();
      final config = (await env.appLock.readConfig()).valueOrNull!;
      expect(config.enabled, isFalse);
      expect(config.biometricsEnabled, isFalse);
      expect(env.secrets.values.keys, ['app_lock.timeout']);
    });

    test('a storage failure is a failure, not a crash', () async {
      env.secrets.fail = true;
      expect((await env.appLock.readConfig()).isOk, isFalse);
      expect((await env.appLock.setPin('1234')).isOk, isFalse);
    });
  });

  group('AppLockCubit (FR-SET-006, WF-082)', () {
    AppLockCubit build() {
      final cubit = AppLockCubit(
        repository: env.appLock,
        biometrics: env.biometrics,
        clock: env.clock,
      );
      addTearDown(cubit.close);
      return cubit;
    }

    test('without a PIN the app opens unlocked', () async {
      final cubit = build();
      expect(cubit.state.phase, LockPhase.starting);
      await cubit.start();
      expect(cubit.state.phase, LockPhase.unlocked);
      // Leaving and returning never locks an app that has no PIN.
      cubit
        ..paused()
        ..resumed();
      expect(cubit.state.phase, LockPhase.unlocked);
    });

    test('with a PIN the app starts locked and the PIN opens it', () async {
      await env.appLock.setPin('1234');
      final cubit = build();
      await cubit.start();
      expect(cubit.state.phase, LockPhase.locked);

      await cubit.unlockWithPin('0000');
      expect(cubit.state.phase, LockPhase.locked);
      expect(cubit.state.attemptsLeft, 4);

      await cubit.unlockWithPin('1234');
      expect(cubit.state.phase, LockPhase.unlocked);
      expect(cubit.state.attemptsLeft, isNull);
    });

    test('too many wrong PINs show when entry opens again', () async {
      await env.appLock.setPin('1234');
      final cubit = build();
      await cubit.start();
      for (var i = 0; i < 5; i++) {
        await cubit.unlockWithPin('0000');
      }
      expect(cubit.state.phase, LockPhase.locked);
      expect(
        cubit.state.lockedUntil,
        env.clock.now.add(const Duration(seconds: 30)),
      );
      expect(cubit.state.attemptsLeft, isNull);
    });

    test('"immediately" locks as soon as the app is left', () async {
      await env.appLock.setPin('1234');
      final cubit = build();
      await cubit.start();
      await cubit.unlockWithPin('1234');

      cubit.paused();
      expect(cubit.state.phase, LockPhase.locked);
    });

    test('a timeout locks only after that long away', () async {
      await env.appLock.setPin('1234');
      await env.appLock.setTimeout(AutoLockTimeout.oneMinute);
      final cubit = build();
      await cubit.start();
      await cubit.unlockWithPin('1234');

      cubit.paused();
      expect(cubit.state.phase, LockPhase.unlocked);
      wait(const Duration(seconds: 59));
      cubit.resumed();
      expect(cubit.state.phase, LockPhase.unlocked);

      cubit.paused();
      wait(const Duration(seconds: 60));
      cubit.resumed();
      expect(cubit.state.phase, LockPhase.locked);
    });

    test('fingerprint unlocks only when turned on and available', () async {
      await env.appLock.setPin('1234');
      final cubit = build();
      await cubit.start();

      await cubit.unlockWithBiometrics('reason');
      expect(env.biometrics.prompts, 0);
      expect(cubit.state.phase, LockPhase.locked);

      env.biometrics.available = true;
      await env.appLock.setBiometrics(enabled: true);
      await cubit.start();
      expect(cubit.state.canUseBiometrics, isTrue);

      env.biometrics.accept = false;
      await cubit.unlockWithBiometrics('reason');
      expect(cubit.state.phase, LockPhase.locked);

      env.biometrics.accept = true;
      await cubit.unlockWithBiometrics('reason');
      expect(cubit.state.phase, LockPhase.unlocked);
      expect(env.biometrics.prompts, 2);
    });

    test('fingerprint does not get past a paused PIN entry', () async {
      await env.appLock.setPin('1234');
      await env.appLock.setBiometrics(enabled: true);
      env.biometrics.available = true;
      final cubit = build();
      await cubit.start();
      for (var i = 0; i < 5; i++) {
        await cubit.unlockWithPin('0000');
      }
      await cubit.unlockWithBiometrics('reason');
      expect(env.biometrics.prompts, 0);
      expect(cubit.state.phase, LockPhase.locked);
    });

    test('turning on, changing and turning off need the right PIN', () async {
      final cubit = build();
      await cubit.start();

      expect(await cubit.enable('1234'), LockChange.done);
      expect(cubit.state.config.enabled, isTrue);
      // Setting a PIN does not lock the app the owner is using.
      expect(cubit.state.phase, LockPhase.unlocked);

      expect(
        await cubit.changePin(currentPin: '0000', newPin: '5678'),
        LockChange.wrongPin,
      );
      expect(
        await cubit.changePin(currentPin: '1234', newPin: '5678'),
        LockChange.done,
      );
      expect(
        (await env.appLock.verifyPin('5678')).valueOrNull,
        const PinAccepted(),
      );

      expect(await cubit.disable(currentPin: '1234'), LockChange.wrongPin);
      expect(cubit.state.config.enabled, isTrue);
      expect(await cubit.disable(currentPin: '5678'), LockChange.done);
      expect(cubit.state.config.enabled, isFalse);
    });

    test('settings changes show in the state', () async {
      final cubit = build();
      await cubit.start();
      await cubit.enable('1234');
      await cubit.setTimeout(AutoLockTimeout.fiveMinutes);
      await cubit.setBiometrics(enabled: true);
      expect(cubit.state.config.timeout, AutoLockTimeout.fiveMinutes);
      expect(cubit.state.config.biometricsEnabled, isTrue);
      // On, but the phone has no fingerprint: the shortcut is not offered.
      expect(cubit.state.canUseBiometrics, isFalse);
    });

    test('if lock settings cannot be read the app stays usable', () async {
      env.secrets.fail = true;
      final cubit = build();
      await cubit.start();
      expect(cubit.state.phase, LockPhase.unlocked);
    });
  });
}
