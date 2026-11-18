// Renders the real app, with real fonts and icons, to PNG files so the
// design can be reviewed without a phone. Not part of `flutter test`.
//
//   flutter test test_screenshots --update-goldens
//
// Output: test_screenshots/out/*.png (git-ignored). Fixture data only.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/app.dart';
import 'package:smart_khata/app/di/injection.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/entry_type.dart';
import 'package:smart_khata/features/ledger/domain/ledger.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';
import 'package:smart_khata/features/shop/domain/shop_repository.dart';

import '../test/helpers/fakes.dart';
import '../test/helpers/test_database.dart';

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      loader.addFont(
        File(path).readAsBytes().then((b) => ByteData.view(b.buffer)),
      );
    }
    await loader.load();
  }

  const fonts = 'assets/fonts';
  await load('NotoSans', [
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold'])
      '$fonts/NotoSans-$w.ttf',
  ]);
  await load('NotoSansTelugu', [
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold'])
      '$fonts/NotoSansTelugu-$w.ttf',
  ]);
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? 'D:/flutter';
  await load('MaterialIcons', [
    '$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
  ]);
}

void main() {
  setUpAll(_loadFonts);

  late AppDatabase database;

  setUp(() {
    database = createTestDatabase();
    configureDependencies(database: database, clock: FakeClock());
  });

  tearDown(() async {
    await getIt.reset(dispose: false);
    await database.close();
  });

  Future<void> seed() async {
    await getIt<ShopRepository>().createShop(
      profile: const ShopProfile(
        name: 'Sri Lakshmi Kirana',
        ownerName: 'Owner',
        phone: '9876543210',
      ),
      localeCode: 'en',
      openingCash: Money.fromPaise(500000),
    );
    final parties = getIt<PartyRepository>();
    var op = 0;
    Future<void> add(
      String name,
      Set<PartyRole> roles, {
      String? phone,
      Map<PartyRole, int> opening = const {},
    }) async {
      final id = (await parties.create(
        PartyDraft(name: name, roles: roles, phone: phone),
      )).valueOrNull!;
      final details = (await parties.watchDetails(id).first).valueOrNull!;
      for (final MapEntry(key: role, value: paise) in opening.entries) {
        await parties.postOpeningBalance(
          OpeningBalancePosting(
            accountId: details.account(role)!.accountId,
            signedAmount: Money.fromPaise(paise),
            operationId: 'op-${op++}',
          ),
        );
      }
    }

    await add(
      'Ravi Kumar',
      {PartyRole.customer},
      phone: '9876543210',
      opening: {PartyRole.customer: 180000},
    );
    await add(
      'Lakshmi Devi',
      {PartyRole.customer},
      phone: '9700000042',
      opening: {PartyRole.customer: 245050},
    );
    await add(
      'Suresh',
      {PartyRole.customer},
      opening: {PartyRole.customer: -20000},
    );
    await add('Meena', {PartyRole.customer}, phone: '9600000023');
    await add(
      'Anil Traders',
      {PartyRole.customer, PartyRole.supplier},
      phone: '9000000007',
      opening: {PartyRole.customer: 300000, PartyRole.supplier: 500000},
    );
    await add(
      'ABC Distributors',
      {PartyRole.supplier},
      opening: {PartyRole.supplier: 140000},
    );

    // A few everyday entries for Anil Traders' customer account.
    final anil =
        (await parties
                .watchList(
                  const PartyListQuery(
                    role: PartyRole.customer,
                    search: 'Anil',
                  ),
                )
                .first)
            .valueOrNull!
            .single;
    final ledger = getIt<LedgerRepository>();
    for (final (type, paise, method, note) in [
      (EntryType.customerCredit, 125000, null, 'Monthly groceries'),
      (EntryType.customerPayment, 200000, PaymentMethod.upi, null),
      (EntryType.customerCredit, 48050, null, 'Rice and oil'),
    ]) {
      await ledger.post(
        EntryPosting(
          accountId: anil.accountId,
          type: type,
          amount: Money.fromPaise(paise),
          operationId: 'op-${op++}',
          method: method,
          description: note,
        ),
      );
    }
  }

  Future<void> pumpApp(
    WidgetTester tester, {
    required bool onboarded,
    Locale locale = AppLocales.english,
    Brightness brightness = Brightness.light,
  }) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    if (onboarded) await tester.runAsync(seed);
    await tester.pumpWidget(
      SmartKhataApp(
        settings: InMemorySettingsRepository(onboardingComplete: onboarded),
        initialLocale: locale,
        onboardingComplete: onboarded,
        onAppReset: () {},
      ),
    );
    await settle(tester);
  }

  Future<void> shot(WidgetTester tester, String name) async {
    await settle(tester);
    await expectLater(
      find.byType(MaterialApp).first,
      matchesGoldenFile('out/$name.png'),
    );
  }

  /// A screenshot test with real soft shadows, as on a phone. Tests draw
  /// shadows solid by default and require that default back at the end.
  void shotTest(String name, Future<void> Function(WidgetTester) body) =>
      testWidgets(name, (tester) async {
        debugDisableShadows = false;
        try {
          await body(tester);
        } finally {
          debugDisableShadows = true;
        }
      });

  GoRouter router(WidgetTester tester) =>
      GoRouter.of(tester.element(find.byType(Navigator).first));

  shotTest('onboarding', (tester) async {
    await pumpApp(tester, onboarded: false);
    await shot(tester, '01_language');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await shot(tester, '02_shop_setup');
  });

  shotTest('home and tabs', (tester) async {
    await pumpApp(tester, onboarded: true);
    await shot(tester, '03_home');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
    await shot(tester, '04_home_scrolled');

    await tester.tap(find.text('Parties'));
    await shot(tester, '05_parties');
    await tester.tap(find.text('Suppliers'));
    await shot(tester, '06_parties_suppliers');

    await tester.tap(find.text('More'));
    await shot(tester, '07_more');

    await tester.tap(find.text('Add'));
    await shot(tester, '08_quick_add');
  });

  shotTest('party pages', (tester) async {
    await pumpApp(tester, onboarded: true);
    final id = (await tester.runAsync(
      () async => database
          .customSelect(
            "SELECT id FROM parties WHERE display_name = 'Anil Traders'",
          )
          .getSingle(),
    ))!.read<String>('id');
    unawaited(router(tester).push('/party/$id'));
    await shot(tester, '09_party_detail');
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -900));
    await shot(tester, '09b_party_ledger');
    unawaited(router(tester).push('/new-party?role=customer'));
    await shot(tester, '10_party_form');
  });

  shotTest('entry forms', (tester) async {
    await pumpApp(tester, onboarded: true);
    unawaited(router(tester).push(AppRoutes.entry(EntryType.customerCredit)));
    await shot(tester, '13_credit_pick_party');
    await tester.tap(find.text('Lakshmi Devi'));
    await settle(tester);
    await tester.enterText(find.byType(TextFormField).first, '1500');
    await shot(tester, '14_payment_like_review');

    final id = (await tester.runAsync(
      () async => database
          .customSelect(
            "SELECT id FROM parties WHERE display_name = 'Ravi Kumar'",
          )
          .getSingle(),
    ))!.read<String>('id');
    unawaited(
      router(
        tester,
      ).push(AppRoutes.entry(EntryType.customerPayment, partyId: id)),
    );
    await settle(tester);
    await tester.enterText(find.byType(TextFormField).first, '2000');
    await shot(tester, '15_payment_advance');
  });

  shotTest('home dark and Telugu', (tester) async {
    await pumpApp(tester, onboarded: true, brightness: Brightness.dark);
    await shot(tester, '11_home_dark');
  });

  shotTest('home Telugu', (tester) async {
    await pumpApp(tester, onboarded: true, locale: AppLocales.telugu);
    await shot(tester, '12_home_telugu');
  });
}

/// Lets real database futures finish, then settles animations.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }
  await tester.pumpAndSettle();
}
