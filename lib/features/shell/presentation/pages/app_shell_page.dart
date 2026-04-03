import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../core/constants/app_constants.dart';

class AppShellPage extends ConsumerWidget {
  final Widget child;
  const AppShellPage({super.key, required this.child});

  static const _items = [
    _NavItem('Dashboard', Icons.dashboard_rounded, '/dashboard'),
    _NavItem('Firma', Icons.apartment_rounded, '/firma'),
    _NavItem('Users', Icons.people_alt_rounded, '/users'),
    _NavItem('Customers', Icons.groups_rounded, '/customers'),
    _NavItem('Customer Balances', Icons.stacked_bar_chart_rounded, '/customer-balances'),
    _NavItem('Suppliers', Icons.local_shipping_rounded, '/suppliers'),
    _NavItem('Supplier Balances', Icons.bar_chart_rounded, '/supplier-balances'),
    _NavItem('Items', Icons.inventory_2_rounded, '/items'),
    _NavItem('Outgoing Invoices', Icons.receipt_long_rounded, '/outgoing-invoices'),
    _NavItem('Incoming Invoices', Icons.request_quote_rounded, '/incoming-invoices'),
    _NavItem('Payments', Icons.payments_rounded, '/payments'),
    _NavItem('Cash', Icons.point_of_sale_rounded, '/cash'),
    _NavItem('Bank', Icons.account_balance_rounded, '/bank'),
    _NavItem('Expenses', Icons.money_off_csred_rounded, '/expenses'),
    _NavItem('Reports', Icons.assessment_rounded, '/reports'),
    _NavItem('Audit Logs', Icons.history_rounded, '/audit-logs'),
    _NavItem('Settings', Icons.settings_rounded, '/settings'),
    _NavItem('Backup', Icons.backup_rounded, '/backup'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: AppConstants.sidebarWidth,
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(color: Color(0xFF0E1C3D)),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.08),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(.08)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Accounting', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                      SizedBox(height: 6),
                      Text('Desktop Suite', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final isActive = GoRouterState.of(context).matchedLocation == item.route;
                      final viewerLockedRoutes = ['/users', '/settings', '/backup', '/audit-logs'];
                      final isViewerLocked = user?.role == UserRole.viewer && viewerLockedRoutes.contains(item.route);
                      return Opacity(
                        opacity: isViewerLocked ? 0.45 : 1,
                        child: ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          tileColor: isActive ? Colors.white.withOpacity(.14) : Colors.transparent,
                          leading: Icon(item.icon, color: Colors.white),
                          title: Text(item.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          onTap: isViewerLocked ? null : () => context.go(item.route),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.08), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const CircleAvatar(child: Icon(Icons.person)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.fullName ?? 'Guest', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(user?.role.name ?? '-', style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await ref.read(authControllerProvider.notifier).logout();
                          if (context.mounted) context.go('/login');
                        },
                        icon: const Icon(Icons.logout_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 78,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE9EEF7)))),
                  child: Row(
                    children: [
                      const Expanded(child: Text('Professional desktop accounting workspace', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                      FilledButton.icon(onPressed: () => context.go('/settings'), icon: const Icon(Icons.tune_rounded), label: const Text('System settings')),
                    ],
                  ),
                ),
                Expanded(child: Padding(padding: const EdgeInsets.all(24), child: child)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  const _NavItem(this.label, this.icon, this.route);
}
