import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/app/router/app_shell.dart';
import 'package:smart_khata/core/widgets/feature_not_ready_page.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/features/gallery/widget_gallery_page.dart';
import 'package:smart_khata/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:smart_khata/features/onboarding/presentation/pages/language_selection_page.dart';
import 'package:smart_khata/features/settings/presentation/pages/more_page.dart';

/// Builds the app's router. All routes are declared here.
GoRouter createAppRouter({required OnboardingCubit onboarding}) {
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
                builder: (context, state) =>
                    FeatureNotReadyPage(title: context.l10n.navParties),
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
