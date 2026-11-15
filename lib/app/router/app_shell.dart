import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/quick_add_sheet.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';

/// The frame around the four tabs: Home, Parties, Reports and More, with
/// the Quick Add action in the middle of the bar (UI spec 2).
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  /// Position of Quick Add in the bar. It opens a sheet; it is not a tab.
  static const int _quickAddIndex = 2;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final branch = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: branch < _quickAddIndex ? branch : branch + 1,
        onDestinationSelected: (index) async {
          if (index == _quickAddIndex) {
            await showQuickAddSheet(context);
            return;
          }
          final target = index < _quickAddIndex ? index : index - 1;
          // Tapping the current tab again returns to that tab's first page.
          navigationShell.goBranch(target, initialLocation: target == branch);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: l10n.navParties,
          ),
          NavigationDestination(
            icon: const Icon(Icons.add_circle, size: 36),
            label: l10n.navQuickAdd,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.navReports,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu),
            label: l10n.navMore,
          ),
        ],
      ),
    );
  }
}
