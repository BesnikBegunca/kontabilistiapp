import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/shell/presentation/pages/app_shell_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/firma/presentation/pages/firma_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/customers/presentation/pages/customer_balances_page.dart';
import '../../features/suppliers/presentation/pages/suppliers_page.dart';
import '../../features/suppliers/presentation/pages/supplier_balances_page.dart';
import '../../features/items/presentation/pages/items_page.dart';
import '../../features/outgoing_invoices/presentation/pages/outgoing_invoices_page.dart';
import '../../features/incoming_invoices/presentation/pages/incoming_invoices_page.dart';
import '../../features/cash/presentation/pages/cash_page.dart';
import '../../features/bank/presentation/pages/bank_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/backup/presentation/pages/backup_restore_page.dart';
import '../../features/users/presentation/pages/users_page.dart';
import '../../features/payments/presentation/pages/payments_page.dart';
import '../../features/audit_logs/presentation/pages/audit_logs_page.dart';

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
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => AppShellPage(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
          GoRoute(path: '/firma', builder: (_, __) => const FirmaPage()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
          GoRoute(path: '/users', builder: (_, __) => const UsersPage()),
          GoRoute(path: '/customers', builder: (_, __) => const CustomersPage()),
          GoRoute(path: '/customer-balances', builder: (_, __) => const CustomerBalancesPage()),
          GoRoute(path: '/suppliers', builder: (_, __) => const SuppliersPage()),
          GoRoute(path: '/supplier-balances', builder: (_, __) => const SupplierBalancesPage()),
          GoRoute(path: '/items', builder: (_, __) => const ItemsPage()),
          GoRoute(path: '/outgoing-invoices', builder: (_, __) => const OutgoingInvoicesPage()),
          GoRoute(path: '/incoming-invoices', builder: (_, __) => const IncomingInvoicesPage()),
          GoRoute(path: '/payments', builder: (_, __) => const PaymentsPage()),
          GoRoute(path: '/cash', builder: (_, __) => const CashPage()),
          GoRoute(path: '/bank', builder: (_, __) => const BankPage()),
          GoRoute(path: '/expenses', builder: (_, __) => const ExpensesPage()),
          GoRoute(path: '/reports', builder: (_, __) => const ReportsPage()),
          GoRoute(path: '/audit-logs', builder: (_, __) => const AuditLogsPage()),
          GoRoute(path: '/backup', builder: (_, __) => const BackupRestorePage()),
        ],
      ),
    ],
  );
});
