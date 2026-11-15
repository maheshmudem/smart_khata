/// Route paths. Navigate with these constants, never with string literals.
abstract final class AppRoutes {
  static const String onboardingLanguage = '/onboarding/language';
  static const String home = '/home';
  static const String parties = '/parties';
  static const String reports = '/reports';
  static const String more = '/more';

  /// Debug builds only.
  static const String gallery = '/gallery';

  static const String _onboardingPrefix = '/onboarding';

  /// Where to send the owner instead of [location], or `null` to stay.
  ///
  /// Until first-run setup is finished every route leads to onboarding;
  /// afterwards onboarding routes lead home.
  static String? redirect({
    required bool onboardingComplete,
    required String location,
  }) {
    final inOnboarding = location.startsWith(_onboardingPrefix);
    if (!onboardingComplete) return inOnboarding ? null : onboardingLanguage;
    return inOnboarding ? home : null;
  }
}
