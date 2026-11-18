import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/features/onboarding/presentation/widgets/onboarding_header.dart';
import 'package:smart_khata/features/shop/presentation/widgets/shop_form_view.dart';

/// WF-002: shop setup. The `ShopFormBloc` is provided by the route.
class ShopSetupPage extends StatelessWidget {
  const ShopSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(),
      body: ShopFormView(
        submitLabel: l10n.actionContinue,
        showOpeningCash: true,
        header: OnboardingHeader(
          step: 2,
          icon: Icons.storefront_rounded,
          title: l10n.shopSetupTitle,
          subtitle: l10n.shopSetupSubtitle,
        ),
        // Success is reported only after the shop row has committed.
        onSaved: () => context.go(AppRoutes.onboardingDone),
      ),
    );
  }
}
