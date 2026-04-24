import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/screens/dashboard/dashboard_screen.dart';
import '../ui/screens/transactions/transactions_screen.dart';
import '../ui/screens/emi/emi_screen.dart';
import '../ui/screens/subscriptions/subscriptions_screen.dart';
import '../ui/screens/debts/debts_screen.dart';
import '../ui/screens/analytics/analytics_screen.dart';
import '../ui/screens/settings/settings_screen.dart';
import '../ui/screens/main_wrapper.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        navigatorKey: GlobalKey<NavigatorState>(),
        builder: (context, state, child) => MainWrapper(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsScreen(),
          ),
          GoRoute(
            path: '/emi',
            builder: (context, state) => const EMIScreen(),
          ),
          GoRoute(
            path: '/subscriptions',
            builder: (context, state) => const SubscriptionsScreen(),
          ),
          GoRoute(
            path: '/debts',
            builder: (context, state) => const DebtsScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
