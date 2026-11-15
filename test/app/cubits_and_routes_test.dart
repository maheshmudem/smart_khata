import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/features/onboarding/presentation/cubit/onboarding_cubit.dart';

import '../helpers/fakes.dart';

void main() {
  group('AppLocales.resolveInitial', () {
    Locale resolve(String? saved, String device) => AppLocales.resolveInitial(
      savedCode: saved,
      deviceLocale: Locale(device),
    );

    test('the saved choice wins over the device language', () {
      expect(resolve('te', 'en'), AppLocales.telugu);
      expect(resolve('en', 'te'), AppLocales.english);
    });

    test('with no saved choice a supported device language is used', () {
      expect(resolve(null, 'te'), AppLocales.telugu);
    });

    test('an unsupported device language falls back to English', () {
      expect(resolve(null, 'hi'), AppLocales.english);
      expect(resolve('xx', 'hi'), AppLocales.english);
    });
  });

  group('LocaleCubit', () {
    late InMemorySettingsRepository settings;
    late LocaleCubit cubit;

    setUp(() {
      settings = InMemorySettingsRepository();
      cubit = LocaleCubit(
        settings: settings,
        initialLocale: AppLocales.english,
      );
    });

    tearDown(() => cubit.close());

    test('switches language and saves the choice', () async {
      final emitted = expectLater(cubit.stream, emits(AppLocales.telugu));
      await cubit.setLocale(AppLocales.telugu);
      await emitted;
      expect(settings.localeCode, 'te');
    });

    test('ignores an unsupported language and the current one', () async {
      await cubit.setLocale(const Locale('hi'));
      await cubit.setLocale(AppLocales.english);
      expect(cubit.state, AppLocales.english);
      expect(settings.localeCode, isNull);
    });

    test('still switches for this session when saving fails', () async {
      settings.failWrites = true;
      await cubit.setLocale(AppLocales.telugu);
      expect(cubit.state, AppLocales.telugu);
      expect(settings.localeCode, isNull);
    });
  });

  group('OnboardingCubit', () {
    test('completing saves the flag and emits true', () async {
      final settings = InMemorySettingsRepository();
      final cubit = OnboardingCubit(settings: settings, isComplete: false);
      addTearDown(cubit.close);

      expect(await cubit.complete(), isTrue);
      expect(cubit.state, isTrue);
      expect(settings.onboardingComplete, isTrue);
    });

    test('stays in onboarding when the flag cannot be saved', () async {
      final settings = InMemorySettingsRepository()..failWrites = true;
      final cubit = OnboardingCubit(settings: settings, isComplete: false);
      addTearDown(cubit.close);

      expect(await cubit.complete(), isFalse);
      expect(cubit.state, isFalse);
    });
  });

  group('AppRoutes.redirect', () {
    test('before setup every route leads to onboarding', () {
      for (final location in [AppRoutes.home, AppRoutes.parties, '/x']) {
        expect(
          AppRoutes.redirect(onboardingComplete: false, location: location),
          AppRoutes.onboardingLanguage,
        );
      }
    });

    test('before setup an onboarding route is left alone', () {
      expect(
        AppRoutes.redirect(
          onboardingComplete: false,
          location: AppRoutes.onboardingLanguage,
        ),
        isNull,
      );
    });

    test('after setup onboarding routes lead home', () {
      expect(
        AppRoutes.redirect(
          onboardingComplete: true,
          location: AppRoutes.onboardingLanguage,
        ),
        AppRoutes.home,
      );
    });

    test('after setup other routes are left alone', () {
      expect(
        AppRoutes.redirect(onboardingComplete: true, location: AppRoutes.more),
        isNull,
      );
    });
  });
}
