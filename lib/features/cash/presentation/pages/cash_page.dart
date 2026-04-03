import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/formatters.dart';
import '../../../../domain/entities/cash_transaction_entity.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../shared/widgets/empty_placeholder.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/search_toolbar.dart';
import '../../../../shared/widgets/section_card.dart';
import '../providers/cash_controller.dart';

class CashPage extends ConsumerStatefulWidget {
  const CashPage({super.key});

  @override
  ConsumerState<CashPage> createState() => _CashPageState();
}

class _CashPageState extends ConsumerState<CashPage> {
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashTransactionsControllerProvider);
    final balance = ref.watch(cashBalanceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Cash',
          subtitle: 'Manage manual cash entries and see the running cash position.',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SearchToolbar(
                hintText: 'Search cash transactions...',
                controller: _searchCtrl,
                onSearchChanged: () {
                  ref.read(cashSearchProvider.notifier).state = _searchCtrl.text.trim();
                  ref.invalidate(cashTransactionsControllerProvider);
                },
                onAdd: () => _openEditor(context),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 260,
              child: SectionCard(
                padding: const EdgeInsets.all(16),
                child: balance.when(
                  data: (v) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cash Balance', style: TextStyle(color: Colors.black54)),
                      const SizedBox(height: 6),
                      Text(Formatters.money(v), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('$e'),
                ),
              ),
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
                  return const EmptyPlaceholder(title: 'No cash transactions', subtitle: 'Add incoming and outgoing cash movements.');
                }
                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final t = rows[index];
                    return ListTile(
                      title: Text(t.description ?? t.referenceNo ?? 'Cash transaction', style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${Formatters.date(t.transactionDate)} • ${t.direction.name}'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          Text(Formatters.money(t.amount)),
                          IconButton(onPressed: () => _openEditor(context, existing: t), icon: const Icon(Icons.edit_rounded)),
                          IconButton(onPressed: t.id == null ? null : () => ref.read(cashTransactionsControllerProvider.notifier).remove(t.id!), icon: const Icon(Icons.delete_rounded)),
                        ],
                      ),
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

  Future<void> _openEditor(BuildContext context, {CashTransactionEntity? existing}) async {
    final refCtrl = TextEditingController(text: existing?.referenceNo ?? '');
    final amountCtrl = TextEditingController(text: existing?.amount.toString() ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    TransactionDirection direction = existing?.direction ?? TransactionDirection.incoming;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(existing == null ? 'Add cash transaction' : 'Edit cash transaction'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: refCtrl, decoration: const InputDecoration(labelText: 'Reference no')),
                const SizedBox(height: 12),
                DropdownButtonFormField<TransactionDirection>(
                  initialValue: direction,
                  items: const [
                    DropdownMenuItem(value: TransactionDirection.incoming, child: Text('Incoming')),
                    DropdownMenuItem(value: TransactionDirection.outgoing, child: Text('Outgoing')),
                  ],
                  onChanged: (v) => setLocal(() => direction = v ?? TransactionDirection.incoming),
                  decoration: const InputDecoration(labelText: 'Direction'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final now = DateTime.now();
                final entity = CashTransactionEntity(
                  id: existing?.id,
                  referenceNo: refCtrl.text.trim().isEmpty ? null : refCtrl.text.trim(),
                  direction: direction,
                  amount: double.tryParse(amountCtrl.text.trim()) ?? 0,
                  description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                  transactionDate: existing?.transactionDate ?? now,
                  createdAt: existing?.createdAt ?? now,
                  updatedAt: now,
                );
                await ref.read(cashTransactionsControllerProvider.notifier).save(entity);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
