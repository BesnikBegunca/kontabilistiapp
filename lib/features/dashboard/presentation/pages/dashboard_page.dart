import 'package:flutter/material.dart';
import '../../../../core/helpers/formatters.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/stat_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Total Sales This Month', Formatters.money(0), Icons.trending_up_rounded),
      ('Total Purchases', Formatters.money(0), Icons.shopping_cart_checkout_rounded),
      ('Total Expenses', Formatters.money(0), Icons.money_off_rounded),
      ('Cash Balance', Formatters.money(0), Icons.point_of_sale_rounded),
      ('Bank Balance', Formatters.money(0), Icons.account_balance_rounded),
      ('Overdue Invoices', '0', Icons.warning_amber_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Dashboard',
          subtitle: 'Premium overview of business accounting activity.',
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          itemCount: stats.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.3,
          ),
          itemBuilder: (context, index) {
            final stat = stats[index];
            return StatCard(
              title: stat.$1,
              value: stat.$2,
              icon: stat.$3 as IconData,
            );
          },
        ),
        const SizedBox(height: 20),
        const Expanded(
          child: Row(
            children: [
              Expanded(
                child: SectionCard(
                  child: _InfoPanel(
                    title: 'Unpaid outgoing invoices',
                    subtitle: 'Invoice aging and unpaid receivables will appear here in the next step.',
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: SectionCard(
                  child: _InfoPanel(
                    title: 'Unpaid incoming invoices',
                    subtitle: 'Payables, supplier balances and reminders will appear here in the next step.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  const _InfoPanel({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
      ],
    );
  }
}
