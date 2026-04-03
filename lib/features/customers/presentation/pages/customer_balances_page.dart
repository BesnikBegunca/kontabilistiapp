import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/formatters.dart';
import '../../../../core/services/csv_export_service.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/section_card.dart';
import '../providers/customer_summaries_controller.dart';

class CustomerBalancesPage extends ConsumerStatefulWidget {
  const CustomerBalancesPage({super.key});

  @override
  ConsumerState<CustomerBalancesPage> createState() => _PageState();
}

class _PageState extends ConsumerState<CustomerBalancesPage> {
  final _searchCtrl = TextEditingController();
  final _csv = CsvExportService();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerSummariesControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(title: 'Customer Balances', subtitle: 'See customer totals, paid amounts and remaining balances.'),
        const SizedBox(height: 20),
        Row(
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => ref.read(customerSummarySearchProvider.notifier).state = _searchCtrl.text.trim(),
                decoration: const InputDecoration(hintText: 'Search...', prefixIcon: Icon(Icons.search_rounded)),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => _export(state.valueOrNull ?? []),
              icon: const Icon(Icons.download_rounded),
              label: const Text('Export CSV'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SectionCard(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (rows) => ListView.separated(
                itemCount: rows.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final row = rows[index];
                  return ListTile(
                    title: Text(row.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text('${row.invoiceCount} invoices • ${row.city ?? '-'}'),
                    trailing: SizedBox(
                      width: 360,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _small('Total', Formatters.money(row.totalInvoices)),
                          const SizedBox(width: 10),
                          _small('Paid', Formatters.money(row.paidAmount)),
                          const SizedBox(width: 10),
                          _small('Remain', Formatters.money(row.remainingAmount)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _small(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }

  Future<void> _export(List<dynamic> rows) async {
    final path = await _csv.export(
      suggestedName: 'customer_balances.csv',
      headers: ['name', 'city', 'phone', 'email', 'invoice_count', 'total', 'paid', 'remaining'],
      rows: rows.map<List<String>>((r) => [
        '${r.name}',
        '${r.city ?? ''}',
        '${r.phone ?? ''}',
        '${r.email ?? ''}',
        '${r.invoiceCount}',
        '${r.totalInvoices}',
        '${r.paidAmount}',
        '${r.remainingAmount}',
      ]).toList(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(path == null ? 'Export cancelled.' : 'CSV exported: $path')),
    );
  }
}
