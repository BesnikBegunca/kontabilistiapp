import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/formatters.dart';
import '../../../../core/services/csv_export_service.dart';
import '../../../../shared/widgets/empty_placeholder.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/search_toolbar.dart';
import '../../../../shared/widgets/section_card.dart';
import '../providers/payments_controller.dart';

class PaymentsPage extends ConsumerStatefulWidget {
  const PaymentsPage({super.key});

  @override
  ConsumerState<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends ConsumerState<PaymentsPage> {
  final _searchCtrl = TextEditingController();
  final _csv = CsvExportService();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Payments',
          subtitle: 'Unified payment history from outgoing and incoming invoices.',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SearchToolbar(
                hintText: 'Search payments...',
                controller: _searchCtrl,
                onSearchChanged: () {
                  ref.read(paymentsSearchProvider.notifier).state = _searchCtrl.text.trim();
                  ref.invalidate(paymentsControllerProvider);
                },
                onAdd: () {},
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
              data: (rows) {
                if (rows.isEmpty) {
                  return const EmptyPlaceholder(title: 'No payments', subtitle: 'Registered invoice payments will appear here.');
                }
                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = rows[index];
                    return ListTile(
                      title: Text('${p.invoiceType.toUpperCase()} invoice #${p.invoiceId}', style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('${Formatters.date(p.paymentDate)} • ${p.paymentMethod.name}${p.notes == null ? '' : ' • ${p.notes}'}'),
                      trailing: Text(Formatters.money(p.amount), style: const TextStyle(fontWeight: FontWeight.w700)),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _export(List<dynamic> rows) async {
    final path = await _csv.export(
      suggestedName: 'payments_export.csv',
      headers: ['invoice_type', 'invoice_id', 'payment_date', 'amount', 'method', 'notes'],
      rows: rows.map<List<String>>((p) => [
        '${p.invoiceType}',
        '${p.invoiceId}',
        '${p.paymentDate}',
        '${p.amount}',
        '${p.paymentMethod.name}',
        '${p.notes ?? ''}',
      ]).toList(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(path == null ? 'Export cancelled.' : 'CSV exported: $path')),
    );
  }
}
