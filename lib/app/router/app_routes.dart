import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/features/ledger/domain/entry_type.dart';

/// Route paths. Navigate with these constants, never with string literals.
abstract final class AppRoutes {
  // First run (WF-001, WF-002, WF-004).
  static const String onboardingLanguage = '/onboarding/language';
  static const String onboardingShop = '/onboarding/shop';
  static const String onboardingDone = '/onboarding/done';

  // Shell tabs.
  static const String home = '/home';
  static const String parties = '/parties';
  static const String reports = '/reports';
  static const String more = '/more';

  // Full-screen pages above the shell, so the bottom bar never competes
  // with a form's Save button.
  static const String partyNew = '/new-party';
  static const String partyDetailPattern = '/party/:id';
  static const String partyEditPattern = '/party/:id/edit';
  static const String shopProfile = '/shop-profile';

  /// Debug builds only.
  static const String gallery = '/gallery';

  static const String _onboardingPrefix = '/onboarding';

  /// The Parties tab opened on [role].
  static String partiesFor(PartyRole role) => '$parties?role=${role.code}';

  /// The add-party form, with [role] already ticked.
  static String partyNewFor(PartyRole role) => '$partyNew?role=${role.code}';

  /// The add-party form opened from inside an entry: on save it returns to
  /// the entry with the new party's ID instead of opening its page.
  static String partyNewToPick(PartyRole role) =>
      '$partyNew?role=${role.code}&$pickParam=1';

  static const String pickParam = 'pick';

  /// Give credit / receive payment / purchase / pay supplier (WF-030..033),
  /// optionally already for a party.
  static const String entryPattern = '/entry/:type';

  static String entry(EntryType type, {String? partyId}) => partyId == null
      ? '/entry/${type.code}'
      : '/entry/${type.code}?party=$partyId';

  static String partyDetail(String partyId) => '/party/$partyId';

  static String partyEdit(String partyId) => '/party/$partyId/edit';

  /// Reads a `role` query parameter written by the helpers above.
  static PartyRole? roleFrom(Map<String, String> query) {
    final code = query['role'];
    for (final role in PartyRole.values) {
      if (role.code == code) return role;
    }
    return null;
  }

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
