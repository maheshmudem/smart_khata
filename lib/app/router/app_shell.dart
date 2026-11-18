import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/quick_add_sheet.dart';
import 'package:smart_khata/core/theme/app_colors.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';

/// The frame around the four tabs: Home, Parties, Reports and More, with
/// the Quick Add action raised in the middle of the bar (UI spec 2).
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  /// Position of Quick Add in the bar. It opens a sheet; it is not a tab.
  static const int _quickAddIndex = 2;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final branch = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
          boxShadow: theme.brightness == Brightness.light
              ? const [
                  BoxShadow(
                    color: Color(0x140B2A1E),
                    blurRadius: 24,
                    offset: Offset(0, -6),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
          child: NavigationBar(
            selectedIndex: branch < _quickAddIndex ? branch : branch + 1,
            onDestinationSelected: (index) async {
              if (index == _quickAddIndex) {
                await showQuickAddSheet(context);
                return;
              }
              final target = index < _quickAddIndex ? index : index - 1;
              // Tapping the current tab again returns to its first page.
              navigationShell.goBranch(
                target,
                initialLocation: target == branch,
              );
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: l10n.navHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.people_outline_rounded),
                selectedIcon: const Icon(Icons.people_rounded),
                label: l10n.navParties,
              ),
              NavigationDestination(
                icon: const _QuickAddButton(),
                label: l10n.navQuickAdd,
              ),
              NavigationDestination(
                icon: const Icon(Icons.insights_outlined),
                selectedIcon: const Icon(Icons.insights_rounded),
                label: l10n.navReports,
              ),
              NavigationDestination(
                icon: const Icon(Icons.grid_view_outlined),
                selectedIcon: const Icon(Icons.grid_view_rounded),
                label: l10n.navMore,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The raised gradient "+" in the middle of the bar.
class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton();

  @override
  Widget build(BuildContext context) {
    // The same 56×32 footprint as a selected tab's pill, so its label lines
    // up with the others.
    return Container(
      width: AppSizes.circleAction,
      height: AppSpacing.xxl,
      decoration: const BoxDecoration(
        gradient: AppGradients.action,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
        boxShadow: AppShadows.raised,
      ),
      child: const Icon(Icons.add_rounded, color: AppGradients.onGradient),
    );
  }
}
