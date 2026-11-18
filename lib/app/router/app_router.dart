import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/di/injection.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/app/router/app_shell.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/widgets/feature_not_ready_page.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/features/dashboard/domain/dashboard.dart';
import 'package:smart_khata/features/dashboard/presentation/home_cubit.dart';
import 'package:smart_khata/features/dashboard/presentation/home_page.dart';
import 'package:smart_khata/features/gallery/widget_gallery_page.dart';
import 'package:smart_khata/features/ledger/domain/entry_type.dart';
import 'package:smart_khata/features/ledger/domain/ledger.dart';
import 'package:smart_khata/features/ledger/presentation/entry_form_bloc.dart';
import 'package:smart_khata/features/ledger/presentation/entry_form_page.dart';
import 'package:smart_khata/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:smart_khata/features/onboarding/presentation/pages/language_selection_page.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';
import 'package:smart_khata/features/parties/domain/party_use_cases.dart';
import 'package:smart_khata/features/parties/presentation/bloc/parties_list_cubit.dart';
import 'package:smart_khata/features/parties/presentation/bloc/party_detail_cubit.dart';
import 'package:smart_khata/features/parties/presentation/bloc/party_form_bloc.dart';
import 'package:smart_khata/features/parties/presentation/pages/parties_page.dart';
import 'package:smart_khata/features/parties/presentation/pages/party_detail_page.dart';
import 'package:smart_khata/features/parties/presentation/pages/party_form_page.dart';
import 'package:smart_khata/features/settings/domain/data_reset_repository.dart';
import 'package:smart_khata/features/settings/presentation/more_cubit.dart';
import 'package:smart_khata/features/settings/presentation/pages/more_page.dart';
import 'package:smart_khata/features/shop/domain/shop_repository.dart';
import 'package:smart_khata/features/shop/domain/shop_use_cases.dart';
import 'package:smart_khata/features/shop/presentation/bloc/shop_form_bloc.dart';
import 'package:smart_khata/features/shop/presentation/pages/setup_complete_page.dart';
import 'package:smart_khata/features/shop/presentation/pages/shop_profile_page.dart';
import 'package:smart_khata/features/shop/presentation/pages/shop_setup_page.dart';

/// Builds the app's router. All routes are declared here, and each route
/// creates the BLoC its screen needs (closed when the route is popped).
GoRouter createAppRouter({
  required OnboardingCubit onboarding,
  required VoidCallback onAppReset,
}) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: _StreamListenable(onboarding.stream),
    redirect: (context, state) => AppRoutes.redirect(
      onboardingComplete: onboarding.state,
      location: state.matchedLocation,
    ),
    routes: [
      GoRoute(
        path: AppRoutes.onboardingLanguage,
        builder: (context, state) => const LanguageSelectionPage(),
      ),
      GoRoute(
        path: AppRoutes.onboardingShop,
        builder: (context, state) => BlocProvider(
          create: (context) => ShopFormBloc.setup(
            shops: getIt<ShopRepository>(),
            setUpShop: getIt<SetUpShop>(),
            localeCode: context.read<LocaleCubit>().state.languageCode,
          )..add(const ShopFormStarted()),
          child: const ShopSetupPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingDone,
        builder: (context, state) => const SetupCompletePage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => BlocProvider(
                  create: (_) => HomeCubit(getIt<DashboardRepository>()),
                  child: const HomePage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.parties,
                builder: (context, state) {
                  final role = AppRoutes.roleFrom(state.uri.queryParameters);
                  return BlocProvider(
                    // A link to a specific tab starts a fresh list.
                    key: ValueKey(role),
                    create: (_) => role == null
                        ? PartiesListCubit(getIt<PartyRepository>())
                        : PartiesListCubit(
                            getIt<PartyRepository>(),
                            role: role,
                          ),
                    child: const PartiesPage(),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reports,
                builder: (context, state) => FeatureNotReadyPage(
                  title: context.l10n.navReports,
                  heading: context.l10n.reportsComingTitle,
                  body: context.l10n.reportsComingBody,
                  icon: Icons.insights_outlined,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.more,
                builder: (context, state) => BlocProvider(
                  create: (_) => MoreCubit(
                    shops: getIt<ShopRepository>(),
                    reset: getIt<DataResetRepository>(),
                  ),
                  child: MorePage(onAppReset: onAppReset),
                ),
              ),
            ],
          ),
        ],
      ),
      // Full-screen pages above the shell.
      GoRoute(
        path: AppRoutes.partyNew,
        builder: (context, state) => BlocProvider(
          create: (_) => PartyFormBloc(
            parties: getIt<PartyRepository>(),
            saveParty: getIt<SaveParty>(),
            initialRole: AppRoutes.roleFrom(state.uri.queryParameters),
          ),
          child: PartyFormPage(
            returnPickedParty:
                state.uri.queryParameters[AppRoutes.pickParam] == '1',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.entryPattern,
        builder: (context, state) {
          final type =
              EntryType.fromCode(state.pathParameters['type']) ??
              EntryType.customerCredit;
          final partyId = state.uri.queryParameters['party'];
          return BlocProvider(
            create: (_) => EntryFormBloc(
              type: type,
              parties: getIt<PartyRepository>(),
              postEntry: getIt<PostEntry>(),
              clock: getIt<Clock>(),
              // Created once, when the form opens (FR-PAY-006).
              operationId: getIt<IdGenerator>().newId(),
              partyId: partyId,
            )..add(const EntryFormStarted()),
            child: const EntryFormPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.partyDetailPattern,
        builder: (context, state) => BlocProvider(
          create: (_) => PartyDetailCubit(
            getIt<PartyRepository>(),
            state.pathParameters['id']!,
          ),
          child: PartyDetailPage(
            postOpeningBalance: getIt<PostOpeningBalance>(),
            newOperationId: getIt<IdGenerator>().newId,
            ledger: getIt<LedgerRepository>(),
          ),
        ),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => BlocProvider(
              create: (_) => PartyFormBloc(
                parties: getIt<PartyRepository>(),
                saveParty: getIt<SaveParty>(),
                partyId: state.pathParameters['id'],
              )..add(const PartyFormStarted()),
              child: const PartyFormPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.shopProfile,
        builder: (context, state) => BlocProvider(
          create: (_) => ShopFormBloc.edit(
            shops: getIt<ShopRepository>(),
            updateShopProfile: getIt<UpdateShopProfile>(),
          )..add(const ShopFormStarted()),
          child: const ShopProfilePage(),
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
