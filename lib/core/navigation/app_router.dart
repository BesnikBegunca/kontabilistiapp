import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/shell/presentation/pages/app_shell_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/firma/presentation/pages/firma_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/shared/presentation/pages/placeholder_module_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final onLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !onLogin) return '/login';
      if (isLoggedIn && onLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShellPage(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardPage(),
          ),
          GoRoute(
            path: '/firma',
            builder: (_, __) => const FirmaPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsPage(),
          ),
          GoRoute(
            path: '/users',
            builder: (_, __) => const PlaceholderModulePage(title: 'Users'),
          ),
          GoRoute(
            path: '/customers',
            builder: (_, __) => const PlaceholderModulePage(title: 'Customers'),
          ),
          GoRoute(
            path: '/suppliers',
            builder: (_, __) => const PlaceholderModulePage(title: 'Suppliers'),
          ),
          GoRoute(
            path: '/items',
            builder: (_, __) => const PlaceholderModulePage(title: 'Items'),
          ),
          GoRoute(
            path: '/outgoing-invoices',
            builder: (_, __) => const PlaceholderModulePage(title: 'Outgoing Invoices'),
          ),
          GoRoute(
            path: '/incoming-invoices',
            builder: (_, __) => const PlaceholderModulePage(title: 'Incoming Invoices'),
          ),
          GoRoute(
            path: '/payments',
            builder: (_, __) => const PlaceholderModulePage(title: 'Payments'),
          ),
          GoRoute(
            path: '/cash',
            builder: (_, __) => const PlaceholderModulePage(title: 'Cash'),
          ),
          GoRoute(
            path: '/bank',
            builder: (_, __) => const PlaceholderModulePage(title: 'Bank'),
          ),
          GoRoute(
            path: '/expenses',
            builder: (_, __) => const PlaceholderModulePage(title: 'Expenses'),
          ),
          GoRoute(
            path: '/reports',
            builder: (_, __) => const PlaceholderModulePage(title: 'Reports'),
          ),
          GoRoute(
            path: '/backup',
            builder: (_, __) => const PlaceholderModulePage(title: 'Backup & Restore'),
          ),
        ],
      ),
    ],
  );
});
