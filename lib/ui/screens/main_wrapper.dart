import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finval/app/theme/colors.dart';
import 'package:finval/providers/settings_provider.dart';
import 'package:finval/data/models/app_modules.dart';

class MainWrapper extends ConsumerWidget {
  final Widget child;
  const MainWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(appModulesProvider);
    final currentPath = GoRouterState.of(context).uri.path;

    // Build nav destinations dynamically based on enabled modules
    final destinations = _buildDestinations(modules);
    final selectedIndex = _selectedIndex(currentPath, modules);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex.clamp(0, destinations.length - 1),
        onDestinationSelected: (index) =>
            _onTap(index, context, modules),
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: destinations,
      ),
    );
  }

  // Ordered list of all possible destinations with their module gates
  static List<_NavItem> _allItems(AppModules m) => [
        const _NavItem(
          path: '/',
          label: 'Home',
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          alwaysVisible: true,
        ),
        _NavItem(
          path: '/transactions',
          label: 'Ledger',
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          enabled: m.transactions,
        ),
        _NavItem(
          path: '/emi',
          label: 'EMI',
          icon: Icons.account_balance_outlined,
          activeIcon: Icons.account_balance,
          enabled: m.emi,
        ),
        _NavItem(
          path: '/subscriptions',
          label: 'Subs',
          icon: Icons.subscriptions_outlined,
          activeIcon: Icons.subscriptions,
          enabled: m.subscriptions,
        ),
        _NavItem(
          path: '/debts',
          label: 'Debts',
          icon: Icons.people_outline,
          activeIcon: Icons.people,
          enabled: m.debts,
        ),
        _NavItem(
          path: '/analytics',
          label: 'Stats',
          icon: Icons.bar_chart_outlined,
          activeIcon: Icons.bar_chart,
          enabled: m.analytics,
        ),
      ];

  List<NavigationDestination> _buildDestinations(AppModules modules) {
    return _allItems(modules)
        .where((item) => item.visible)
        .map((item) => NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.activeIcon, color: AppColors.primary),
              label: item.label,
            ))
        .toList();
  }

  int _selectedIndex(String path, AppModules modules) {
    final visibleItems =
        _allItems(modules).where((item) => item.visible).toList();
    final idx = visibleItems.indexWhere((item) => item.path == path);
    return idx < 0 ? 0 : idx;
  }

  void _onTap(int index, BuildContext context, AppModules modules) {
    final visibleItems =
        _allItems(modules).where((item) => item.visible).toList();
    if (index < visibleItems.length) {
      context.go(visibleItems[index].path);
    }
  }
}

class _NavItem {
  final String path;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool enabled;
  final bool alwaysVisible;

  const _NavItem({
    required this.path,
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.enabled = true,
    this.alwaysVisible = false,
  });

  bool get visible => alwaysVisible || enabled;
}
