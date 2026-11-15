import 'package:smart_khata/core/domain/ledger_enums.dart';

/// Route paths. Navigate with these constants and builders, never with
/// string literals.
abstract final class AppRoutes {
  static const String onboardingLanguage = '/onboarding/language';
  static const String onboardingShop = '/onboarding/shop';
  static const String onboardingComplete = '/onboarding/complete';

  static const String home = '/home';
  static const String parties = '/parties';
  static const String reports = '/reports';
  static const String more = '/more';

  // Party pages sit above the tab shell, so the bottom bar does not
  // compete with Save (wireframes 1.2).
  static const String partyNewPattern = '/party/new';
  static const String partyDetailPattern = '/party/:partyId';
  static const String partyEditPattern = '/party/:partyId/edit';
  static const String partyOpeningBalancePattern =
      '/party/:partyId/opening-balance/:accountId';

  static const String roleParam = 'role';

  static String partyNew({required PartyRole role}) =>
      '$partyNewPattern?$roleParam=${role.code}';

  static String partyDetail(String partyId, {PartyRole? role}) => role == null
      ? '/party/$partyId'
      : '/party/$partyId?$roleParam=${role.code}';

  static String partyEdit(String partyId) => '/party/$partyId/edit';

  static String partyOpeningBalance(String partyId, String accountId) =>
      '/party/$partyId/opening-balance/$accountId';

  /// The role named in a `role` query parameter, if it is a known one.
  static PartyRole? roleFromQuery(String? code) {
    for (final role in PartyRole.values) {
      if (role.code == code) return role;
    }
    return null;
  }

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
