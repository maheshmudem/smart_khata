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

  static const String partyPickPattern = '/party-pick/:role';
  static const String partyLedgerPattern = '/party/:partyId/ledger/:accountId';
  static const String chargePattern = '/charge/:role';
  static const String transactionPattern = '/transaction/:transactionId';
  static const String transactionReversePattern =
      '/transaction/:transactionId/reverse';

  static const String roleParam = 'role';
  static const String partyIdParam = 'partyId';
  static const String returnOnSaveParam = 'return';

  /// The add-party form. With [returnOnSave] it pops with the new party ID
  /// instead of opening the party page (create-inline from a picker).
  static String partyNew({
    required PartyRole role,
    bool returnOnSave = false,
  }) =>
      '$partyNewPattern?$roleParam=${role.code}'
      '${returnOnSave ? '&$returnOnSaveParam=1' : ''}';

  /// Party chooser for an entry form; pops with the chosen party ID.
  static String partyPick({required PartyRole role}) =>
      '/party-pick/${role.code}';

  static String partyLedger(String partyId, String accountId) =>
      '/party/$partyId/ledger/$accountId';

  /// Give customer credit (customer) or add a purchase (supplier).
  static String charge({required PartyRole role, String? partyId}) =>
      '/charge/${role.code}'
      '${partyId == null ? '' : '?$partyIdParam=$partyId'}';

  static const String paymentPattern = '/payment/:role';
  static const String returnPattern = '/return/:role';

  /// Receive a customer payment (customer) or pay a supplier (supplier).
  static String payment({required PartyRole role, String? partyId}) =>
      '/payment/${role.code}'
      '${partyId == null ? '' : '?$partyIdParam=$partyId'}';

  /// Sales return (customer) or purchase return (supplier).
  static String returned({required PartyRole role, String? partyId}) =>
      '/return/${role.code}'
      '${partyId == null ? '' : '?$partyIdParam=$partyId'}';

  static String transaction(String transactionId) =>
      '/transaction/$transactionId';

  static String transactionReverse(String transactionId) =>
      '/transaction/$transactionId/reverse';

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
