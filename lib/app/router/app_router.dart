import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/di/injection.dart';
import 'package:smart_khata/app/router/app_messenger.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/app/router/app_shell.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/widgets/feature_not_ready_page.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/features/gallery/widget_gallery_page.dart';
import 'package:smart_khata/features/ledger/domain/ledger_repository.dart';
import 'package:smart_khata/features/ledger/domain/ledger_use_cases.dart';
import 'package:smart_khata/features/ledger/presentation/cubit/charge_form_cubit.dart';
import 'package:smart_khata/features/ledger/presentation/cubit/ledger_cubits.dart';
import 'package:smart_khata/features/ledger/presentation/pages/charge_form_page.dart';
import 'package:smart_khata/features/ledger/presentation/pages/ledger_page.dart';
import 'package:smart_khata/features/ledger/presentation/pages/reverse_transaction_page.dart';
import 'package:smart_khata/features/ledger/presentation/pages/transaction_detail_page.dart';
import 'package:smart_khata/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:smart_khata/features/onboarding/presentation/cubit/shop_setup_cubit.dart';
import 'package:smart_khata/features/onboarding/presentation/pages/language_selection_page.dart';
import 'package:smart_khata/features/onboarding/presentation/pages/setup_complete_page.dart';
import 'package:smart_khata/features/onboarding/presentation/pages/shop_setup_page.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';
import 'package:smart_khata/features/parties/domain/party_use_cases.dart';
import 'package:smart_khata/features/parties/presentation/cubit/opening_balance_cubit.dart';
import 'package:smart_khata/features/parties/presentation/cubit/parties_list_cubit.dart';
import 'package:smart_khata/features/parties/presentation/cubit/party_detail_cubit.dart';
import 'package:smart_khata/features/parties/presentation/cubit/party_form_cubit.dart';
import 'package:smart_khata/features/parties/presentation/pages/opening_balance_page.dart';
import 'package:smart_khata/features/parties/presentation/pages/parties_page.dart';
import 'package:smart_khata/features/parties/presentation/pages/party_detail_page.dart';
import 'package:smart_khata/features/parties/presentation/pages/party_form_page.dart';
import 'package:smart_khata/features/parties/presentation/pages/party_picker_page.dart';
import 'package:smart_khata/features/settings/presentation/pages/more_page.dart';
import 'package:smart_khata/features/shop/domain/create_shop.dart';
import 'package:smart_khata/features/shop/domain/shop_repository.dart';

/// Builds the app's router. All routes are declared here, and each route
/// creates the cubit its page needs, so the cubit lives exactly as long as
/// the page.
GoRouter createAppRouter({required OnboardingCubit onboarding}) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    observers: [AppMessenger.observer],
    refreshListenable: _StreamListenable(onboarding.stream),
    redirect: (context, state) => AppRoutes.redirect(
      onboardingComplete: onboarding.state,
      location: state.matchedLocation,
    ),
    routes: [
      // ---- Onboarding ----------------------------------------------------
      GoRoute(
        path: AppRoutes.onboardingLanguage,
        builder: (context, state) => const LanguageSelectionPage(),
      ),
      GoRoute(
        path: AppRoutes.onboardingShop,
        builder: (context, state) => BlocProvider(
          create: (_) {
            final cubit = ShopSetupCubit(
              createShop: getIt<CreateShop>(),
              shops: getIt<ShopRepository>(),
            );
            unawaited(cubit.resumeIfShopExists());
            return cubit;
          },
          child: const ShopSetupPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingComplete,
        builder: (context, state) => const SetupCompletePage(),
      ),

      // ---- Tabs ----------------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) =>
                    FeatureNotReadyPage(title: context.l10n.navHome),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.parties,
                builder: (context, state) => BlocProvider(
                  create: (_) =>
                      PartiesListCubit(repository: getIt<PartyRepository>()),
                  child: const PartiesPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reports,
                builder: (context, state) =>
                    FeatureNotReadyPage(title: context.l10n.navReports),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.more,
                builder: (context, state) => const MorePage(),
              ),
            ],
          ),
        ],
      ),

      // ---- Parties (above the shell) -------------------------------------
      // '/party/new' is declared before '/party/:partyId' so that "new" is
      // never read as a party ID.
      GoRoute(
        path: AppRoutes.partyNewPattern,
        builder: (context, state) => BlocProvider(
          create: (_) => _partyFormCubit(
            initialRole: AppRoutes.roleFromQuery(
              state.uri.queryParameters[AppRoutes.roleParam],
            ),
          ),
          child: PartyFormPage(
            returnOnSave: state.uri.queryParameters.containsKey(
              AppRoutes.returnOnSaveParam,
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.partyDetailPattern,
        builder: (context, state) => BlocProvider(
          create: (_) => PartyDetailCubit(
            repository: getIt<PartyRepository>(),
            partyId: state.pathParameters['partyId']!,
            initialRole: AppRoutes.roleFromQuery(
              state.uri.queryParameters[AppRoutes.roleParam],
            ),
          ),
          child: const PartyDetailPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.partyEditPattern,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              _partyFormCubit(partyId: state.pathParameters['partyId']),
          child: const PartyFormPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.partyOpeningBalancePattern,
        builder: (context, state) {
          final today = _today();
          return BlocProvider(
            create: (_) => OpeningBalanceCubit(
              repository: getIt<PartyRepository>(),
              recordOpeningBalance: getIt<RecordOpeningBalance>(),
              partyId: state.pathParameters['partyId']!,
              accountId: state.pathParameters['accountId']!,
              // One ID for the life of the form: a retry cannot post twice.
              operationId: getIt<IdGenerator>().newId(),
              today: today,
            ),
            child: OpeningBalancePage(today: today),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.partyPickPattern,
        builder: (context, state) {
          final role =
              AppRoutes.roleFromQuery(state.pathParameters['role']) ??
              PartyRole.customer;
          return BlocProvider(
            create: (_) => PartiesListCubit(
              repository: getIt<PartyRepository>(),
              initialRole: role,
            ),
            child: PartyPickerPage(role: role),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.partyLedgerPattern,
        builder: (context, state) => BlocProvider(
          create: (_) => LedgerCubit(
            ledger: getIt<LedgerRepository>(),
            parties: getIt<PartyRepository>(),
            partyId: state.pathParameters['partyId']!,
            accountId: state.pathParameters['accountId']!,
          ),
          child: const LedgerPage(),
        ),
      ),

      // ---- Ledger entries --------------------------------------------------
      GoRoute(
        path: AppRoutes.chargePattern,
        builder: (context, state) {
          final today = _today();
          return BlocProvider(
            create: (_) => ChargeFormCubit(
              parties: getIt<PartyRepository>(),
              recordCharge: getIt<RecordCharge>(),
              role:
                  AppRoutes.roleFromQuery(state.pathParameters['role']) ??
                  PartyRole.customer,
              // One ID for the life of the form: a retry cannot post twice.
              operationId: getIt<IdGenerator>().newId(),
              today: today,
              partyId: state.uri.queryParameters[AppRoutes.partyIdParam],
            ),
            child: ChargeFormPage(today: today),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.transactionPattern,
        builder: (context, state) => BlocProvider(
          create: (_) => TransactionDetailCubit(
            ledger: getIt<LedgerRepository>(),
            transactionId: state.pathParameters['transactionId']!,
          ),
          child: const TransactionDetailPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.transactionReversePattern,
        builder: (context, state) => BlocProvider(
          create: (_) => ReverseTransactionCubit(
            ledger: getIt<LedgerRepository>(),
            reverse: getIt<ReverseTransaction>(),
            transactionId: state.pathParameters['transactionId']!,
            operationId: getIt<IdGenerator>().newId(),
          ),
          child: const ReverseTransactionPage(),
        ),
      ),

      if (kDebugMode)
        GoRoute(
          path: AppRoutes.gallery,
          builder: (context, state) => const WidgetGalleryPage(),
        ),
    ],
  );
}

/// The business date of the shop right now.
BusinessDate _today() => BusinessDate.fromInstant(
  getIt<Clock>().nowUtc(),
  ShopTimeZone.resolve(null),
);

PartyFormCubit _partyFormCubit({String? partyId, PartyRole? initialRole}) =>
    PartyFormCubit(
      repository: getIt<PartyRepository>(),
      saveParty: getIt<SaveParty>(),
      findDuplicates: getIt<FindDuplicateParties>(),
      partyId: partyId,
      initialRole: initialRole ?? PartyRole.customer,
    );

/// Lets the router re-run its redirect whenever a cubit emits.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
