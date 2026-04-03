import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/formatters.dart';
import '../../../../shared/widgets/metric_bar_chart.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../providers/dashboard_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SectionCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 52),
                const SizedBox(height: 12),
                Text(
                  'Dashboard failed to load',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text('$e', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.read(dashboardControllerProvider.notifier).reload(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (summary) {
        final stats = <_DashStat>[
          _DashStat('Total Sales This Month', Formatters.money(summary.totalSalesThisMonth), Icons.trending_up_rounded),
          _DashStat('Total Purchases', Formatters.money(summary.totalPurchasesThisMonth), Icons.shopping_cart_checkout_rounded),
          _DashStat('Total Expenses', Formatters.money(summary.totalExpensesThisMonth), Icons.money_off_rounded),
          _DashStat('Cash Balance', Formatters.money(summary.cashBalance), Icons.point_of_sale_rounded),
          _DashStat('Bank Balance', Formatters.money(summary.bankBalance), Icons.account_balance_rounded),
          _DashStat('Overdue Outgoing', '${summary.overdueOutgoingInvoices}', Icons.warning_amber_rounded),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width >= 1500 ? 3 : width >= 1000 ? 2 : 1;
            final lowerSideBySide = width >= 1200;

            final topGrid = GridView.builder(
              shrinkWrap: true,
              itemCount: stats.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: width >= 1200 ? 2.5 : 2.1,
              ),
              itemBuilder: (context, index) {
                final stat = stats[index];
                return StatCard(title: stat.title, value: stat.value, icon: stat.icon);
              },
            );

            final chart = MetricBarChart(
              title: 'Financial Activity',
              subtitle: 'Quick visual comparison of core monthly metrics.',
              items: [
                MetricBarItem(label: 'Sales', value: summary.totalSalesThisMonth, displayValue: Formatters.money(summary.totalSalesThisMonth)),
                MetricBarItem(label: 'Purchases', value: summary.totalPurchasesThisMonth, displayValue: Formatters.money(summary.totalPurchasesThisMonth)),
                MetricBarItem(label: 'Expenses', value: summary.totalExpensesThisMonth, displayValue: Formatters.money(summary.totalExpensesThisMonth)),
                MetricBarItem(label: 'Cash', value: summary.cashBalance.abs(), displayValue: Formatters.money(summary.cashBalance)),
                MetricBarItem(label: 'Bank', value: summary.bankBalance.abs(), displayValue: Formatters.money(summary.bankBalance)),
              ],
            );

            final panel = _ReceivablesPayablesPanel(summary: summary);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(
                  title: 'Dashboard',
                  subtitle: 'Live premium business overview powered directly by SQLite accounting data.',
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      topGrid,
                      const SizedBox(height: 20),
                      if (lowerSideBySide)
                        SizedBox(
                          height: 430,
                          child: Row(
                            children: [
                              Expanded(child: chart),
                              const SizedBox(width: 16),
                              Expanded(child: panel),
                            ],
                          ),
                        )
                      else ...[
                        chart,
                        const SizedBox(height: 16),
                        panel,
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ReceivablesPayablesPanel extends StatelessWidget {
  final dynamic summary;
  const _ReceivablesPayablesPanel({required this.summary});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Receivables & Payables', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Operational debt exposure and overdue activity at a glance.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
            const SizedBox(height: 20),
            _Line(label: 'Unpaid outgoing invoices', value: Formatters.money(summary.unpaidOutgoingInvoices)),
            _Line(label: 'Unpaid incoming invoices', value: Formatters.money(summary.unpaidIncomingInvoices)),
            _Line(label: 'Overdue outgoing invoices', value: '${summary.overdueOutgoingInvoices}'),
            _Line(label: 'Overdue incoming invoices', value: '${summary.overdueIncomingInvoices}'),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F9FF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE8EEF8)),
              ),
              child: const Text(
                'Tip: use Payments, Cash and Bank pages together for a cleaner audit trail.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  const _Line({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _DashStat {
  final String title;
  final String value;
  final IconData icon;
  _DashStat(this.title, this.value, this.icon);
}
