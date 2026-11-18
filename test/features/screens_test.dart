import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/features/dashboard/presentation/home_cubit.dart';
import 'package:smart_khata/features/dashboard/presentation/home_page.dart';
import 'package:smart_khata/features/ledger/domain/entry_type.dart';
import 'package:smart_khata/features/ledger/domain/ledger.dart';
import 'package:smart_khata/features/ledger/presentation/entry_form_bloc.dart';
import 'package:smart_khata/features/ledger/presentation/entry_form_page.dart';
import 'package:smart_khata/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:smart_khata/features/onboarding/presentation/pages/language_selection_page.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_use_cases.dart';
import 'package:smart_khata/features/parties/presentation/bloc/parties_list_cubit.dart';
import 'package:smart_khata/features/parties/presentation/bloc/party_detail_cubit.dart';
import 'package:smart_khata/features/parties/presentation/bloc/party_form_bloc.dart';
import 'package:smart_khata/features/parties/presentation/pages/parties_page.dart';
import 'package:smart_khata/features/parties/presentation/pages/party_detail_page.dart';
import 'package:smart_khata/features/parties/presentation/pages/party_form_page.dart';
import 'package:smart_khata/features/settings/presentation/more_cubit.dart';
import 'package:smart_khata/features/settings/presentation/pages/more_page.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';
import 'package:smart_khata/features/shop/domain/shop_use_cases.dart';
import 'package:smart_khata/features/shop/presentation/bloc/shop_form_bloc.dart';
import 'package:smart_khata/features/shop/presentation/pages/setup_complete_page.dart';
import 'package:smart_khata/features/shop/presentation/pages/shop_setup_page.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

/// Every new screen renders without overflow in English and Telugu, at
/// normal text and at 2x text on a 320dp-wide phone.
void main() {
  const shop = Shop(
    id: 's-1',
    profile: ShopProfile(name: 'Test Kirana', phone: '9876543210'),
    timeZone: 'Asia/Kolkata',
  );

  final screens = <String, Widget Function()>{
    'language': () => BlocProvider(
      create: (_) => LocaleCubit(
        settings: InMemorySettingsRepository(),
        initialLocale: AppLocales.english,
      ),
      child: const LanguageSelectionPage(),
    ),
    'shop setup': () {
      final shops = FakeShopRepository();
      return BlocProvider(
        create: (_) => ShopFormBloc.setup(
          shops: shops,
          setUpShop: SetUpShop(shops),
          localeCode: 'en',
        )..add(const ShopFormStarted()),
        child: const ShopSetupPage(),
      );
    },
    'setup complete': () => BlocProvider(
      create: (_) => OnboardingCubit(
        settings: InMemorySettingsRepository(),
        isComplete: false,
      ),
      child: const SetupCompletePage(),
    ),
    'home': () => BlocProvider(
      create: (_) => HomeCubit(FakeDashboardRepository(Ok(dashboardFixture()))),
      child: const HomePage(),
    ),
    'home, first run': () => BlocProvider(
      create: (_) =>
          HomeCubit(FakeDashboardRepository(Ok(dashboardFixture(empty: true)))),
      child: const HomePage(),
    ),
    'parties': () => BlocProvider(
      create: (_) =>
          PartiesListCubit(FakePartyRepository(items: fixtureCustomers)),
      child: const PartiesPage(),
    ),
    'party detail': () {
      final repo = FakePartyRepository(details: ravi);
      return BlocProvider(
        create: (_) => PartyDetailCubit(repo, ravi.id),
        child: PartyDetailPage(
          postOpeningBalance: PostOpeningBalance(repo),
          newOperationId: () => 'op-1',
          ledger: FakeLedgerRepository(lines: fixtureLedger),
        ),
      );
    },
    'credit form, choosing a customer': () {
      final parties = FakePartyRepository(items: fixtureCustomers);
      return BlocProvider(
        create: (_) => EntryFormBloc(
          type: EntryType.customerCredit,
          parties: parties,
          postEntry: PostEntry(FakeLedgerRepository()),
          clock: FakeClock(),
          operationId: 'op-1',
        )..add(const EntryFormStarted()),
        child: const EntryFormPage(),
      );
    },
    'payment form for a customer': () {
      final parties = FakePartyRepository(details: ravi);
      return BlocProvider(
        create: (_) => EntryFormBloc(
          type: EntryType.customerPayment,
          parties: parties,
          postEntry: PostEntry(FakeLedgerRepository()),
          clock: FakeClock(),
          operationId: 'op-1',
          partyId: ravi.id,
        )..add(const EntryFormStarted()),
        child: const EntryFormPage(),
      );
    },
    'party form': () {
      final repo = FakePartyRepository();
      return BlocProvider(
        create: (_) => PartyFormBloc(parties: repo, saveParty: SaveParty(repo)),
        child: const PartyFormPage(),
      );
    },
    'more': () => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LocaleCubit(
            settings: InMemorySettingsRepository(),
            initialLocale: AppLocales.english,
          ),
        ),
        BlocProvider(
          create: (_) => MoreCubit(
            shops: FakeShopRepository(shop: shop),
            reset: FakeDataResetRepository(),
          ),
        ),
      ],
      child: MorePage(onAppReset: () {}),
    ),
  };

  for (final MapEntry(key: name, value: build) in screens.entries) {
    for (final locale in AppLocales.supported) {
      for (final (scale, narrow) in [(1.0, false), (2.0, true)]) {
        testWidgets('$name renders (${locale.languageCode}, x$scale)', (
          tester,
        ) async {
          await tester.pumpApp(
            build(),
            locale: locale,
            textScale: scale,
            narrow: narrow,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  group('content', () {
    final en = l10nFor(AppLocales.english);

    testWidgets('home shows both sides separately, never netted', (
      tester,
    ) async {
      await tester.pumpApp(screens['home']!());
      expect(find.text('Test Kirana'), findsOneWidget);
      expect(find.text('₹1,300'), findsOneWidget);
      expect(find.text('₹1,400'), findsOneWidget);
      // Each side is named in words, in its own tile.
      expect(find.text(en.homeCustomersOweYou), findsOneWidget);
      expect(find.text(en.homeYouOweSuppliers), findsOneWidget);
      expect(find.text(en.homeAdvanceNote('₹200')), findsOneWidget);
      // Not the two added together.
      expect(find.text('₹2,700'), findsNothing);
    });

    testWidgets('home failure offers a retry', (tester) async {
      await tester.pumpApp(
        BlocProvider(
          create: (_) =>
              HomeCubit(FakeDashboardRepository(const Err(DatabaseFailure()))),
          child: const HomePage(),
        ),
      );
      expect(find.text(en.errorLoadFailed), findsOneWidget);
      expect(find.text(en.actionRetry), findsOneWidget);
    });

    testWidgets('an advance is labelled as an advance, not as owed', (
      tester,
    ) async {
      await tester.pumpApp(screens['parties']!());
      expect(find.text(en.balanceCustomerAdvance), findsOneWidget);
      expect(find.text('₹200'), findsOneWidget);
    });

    testWidgets('parties list failure offers a retry', (tester) async {
      await tester.pumpApp(
        BlocProvider(
          create: (_) => PartiesListCubit(
            FakePartyRepository(listFailure: const DatabaseFailure()),
          ),
          child: const PartiesPage(),
        ),
      );
      expect(find.text(en.errorLoadFailed), findsOneWidget);
    });

    testWidgets('a dual-role party switches between separate balances', (
      tester,
    ) async {
      await tester.pumpApp(screens['party detail']!());
      expect(find.text('₹1,300'), findsOneWidget);
      expect(find.text(en.openingBalanceRecorded), findsOneWidget);

      await tester.tap(find.text(en.roleSupplier).first);
      await tester.pumpAndSettle();
      expect(find.text(en.balanceSettled), findsOneWidget);
      expect(find.text(en.openingBalanceAction), findsOneWidget);
    });

    testWidgets('an archived party explains why it takes no entries', (
      tester,
    ) async {
      final archived = PartyDetails(
        id: ravi.id,
        name: ravi.name,
        status: PartyStatus.archived,
        accounts: ravi.accounts,
      );
      final repo = FakePartyRepository(details: archived);
      await tester.pumpApp(
        BlocProvider(
          create: (_) => PartyDetailCubit(repo, ravi.id),
          child: PartyDetailPage(
            postOpeningBalance: PostOpeningBalance(repo),
            newOperationId: () => 'op-1',
            ledger: FakeLedgerRepository(),
          ),
        ),
      );
      await tester.tap(find.text(en.actionGiveCredit));
      await tester.pumpAndSettle();
      expect(find.text(en.errorPartyArchived), findsOneWidget);
    });

    testWidgets('entries show their effect and the running balance', (
      tester,
    ) async {
      await tester.pumpApp(screens['party detail']!());
      await tester.scrollUntilVisible(
        find.text('Rice and dal'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('+₹500'), findsOneWidget);
      expect(find.text('−₹1,000'), findsOneWidget);
      expect(find.text(en.ledgerBalanceAfter('₹1,300')), findsOneWidget);
      expect(find.textContaining(en.methodUpi), findsOneWidget);
    });

    testWidgets('a payment above the dues explains the advance', (
      tester,
    ) async {
      await tester.pumpApp(screens['payment form for a customer']!());
      // Ravi owes ₹1,300 in the fixture; ₹1,500 leaves ₹200 extra.
      await tester.enterText(find.byType(TextFormField).first, '1500');
      await tester.pumpAndSettle();
      expect(find.text(en.entryExcessAdvance('₹200')), findsOneWidget);
      expect(find.text(en.balanceCustomerAdvance), findsOneWidget);
    });

    testWidgets('the opening balance sheet reviews before saving', (
      tester,
    ) async {
      await tester.pumpApp(screens['party detail']!());
      await tester.tap(find.text(en.roleSupplier).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.openingBalanceAction));
      await tester.pumpAndSettle();

      expect(find.text(en.reviewTitle), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '500');
      await tester.pumpAndSettle();
      // After saving the shop would owe the supplier ₹500.
      expect(find.text(en.balanceYouOweSupplier), findsWidgets);
      expect(find.text('₹500'), findsWidgets);
    });
  });
}
