import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/formatters.dart';
import '../../../../domain/entities/bank_entities.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../shared/widgets/empty_placeholder.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/search_toolbar.dart';
import '../../../../shared/widgets/section_card.dart';
import '../providers/bank_controller.dart';

class BankPage extends ConsumerStatefulWidget {
  const BankPage({super.key});

  @override
  ConsumerState<BankPage> createState() => _BankPageState();
}

class _BankPageState extends ConsumerState<BankPage> {
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final accountsState = ref.watch(bankAccountsControllerProvider);
    final txState = ref.watch(bankTransactionsControllerProvider);
    final balance = ref.watch(bankBalanceProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1180;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Bank',
              subtitle: 'Manage bank accounts and movement history with running balance.',
            ),
            const SizedBox(height: 20),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SearchToolbar(
                      hintText: 'Search bank transactions...',
                      controller: _searchCtrl,
                      onSearchChanged: () {
                        ref.read(bankSearchProvider.notifier).state = _searchCtrl.text.trim();
                        ref.invalidate(bankTransactionsControllerProvider);
                      },
                      onAdd: () => _openTransactionEditor(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _openAccountEditor(context),
                    icon: const Icon(Icons.account_balance),
                    label: const Text('Add account'),
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
                            const Text('Bank Balance', style: TextStyle(color: Colors.black54)),
                            const SizedBox(height: 6),
                            Text(
                              Formatters.money(v),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('$e'),
                      ),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  SearchToolbar(
                    hintText: 'Search bank transactions...',
                    controller: _searchCtrl,
                    onSearchChanged: () {
                      ref.read(bankSearchProvider.notifier).state = _searchCtrl.text.trim();
                      ref.invalidate(bankTransactionsControllerProvider);
                    },
                    onAdd: () => _openTransactionEditor(context),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openAccountEditor(context),
                          icon: const Icon(Icons.account_balance),
                          label: const Text('Add account'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SectionCard(
                    padding: const EdgeInsets.all(16),
                    child: balance.when(
                      data: (v) => Row(
                        children: [
                          const Expanded(
                            child: Text('Bank Balance', style: TextStyle(color: Colors.black54)),
                          ),
                          Text(
                            Formatters.money(v),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('$e'),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Expanded(
              child: wide
                  ? Row(
                      children: [
                        SizedBox(
                          width: 360,
                          child: _accountsPanel(accountsState),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: _transactionsPanel(txState)),
                      ],
                    )
                  : ListView(
                      children: [
                        SizedBox(height: 320, child: _accountsPanel(accountsState)),
                        const SizedBox(height: 16),
                        SizedBox(height: 420, child: _transactionsPanel(txState)),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _accountsPanel(AsyncValue<List<BankAccountEntity>> accountsState) {
    return SectionCard(
      child: accountsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (accounts) {
          if (accounts.isEmpty) {
            return const EmptyPlaceholder(
              title: 'No bank accounts',
              subtitle: 'Create at least one bank account.',
            );
          }
          return ListView.separated(
            itemCount: accounts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final a = accounts[index];
              return ListTile(
                title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${a.bankName ?? '-'} • ${a.currency}'),
                trailing: SizedBox(
                  width: 110,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => _openAccountEditor(context, existing: a),
                        icon: const Icon(Icons.edit_rounded),
                      ),
                      IconButton(
                        onPressed: a.id == null
                            ? null
                            : () => ref.read(bankAccountsControllerProvider.notifier).remove(a.id!),
                        icon: const Icon(Icons.delete_rounded),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _transactionsPanel(AsyncValue<List<BankTransactionEntity>> txState) {
    return SectionCard(
      child: txState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (rows) {
          if (rows.isEmpty) {
            return const EmptyPlaceholder(
              title: 'No bank transactions',
              subtitle: 'Add deposits, transfers and withdrawals.',
            );
          }
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final t = rows[index];
              return ListTile(
                title: Text(
                  t.description ?? t.referenceNo ?? 'Bank transaction',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${Formatters.date(t.transactionDate)} • ${t.direction.name} • Account #${t.bankAccountId}',
                ),
                trailing: SizedBox(
                  width: 170,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          Formatters.money(t.amount),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _openTransactionEditor(context, existing: t),
                        icon: const Icon(Icons.edit_rounded),
                      ),
                      IconButton(
                        onPressed: t.id == null
                            ? null
                            : () => ref.read(bankTransactionsControllerProvider.notifier).remove(t.id!),
                        icon: const Icon(Icons.delete_rounded),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openAccountEditor(BuildContext context, {BankAccountEntity? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final ibanCtrl = TextEditingController(text: existing?.iban ?? '');
    final bankNameCtrl = TextEditingController(text: existing?.bankName ?? '');
    final currencyCtrl = TextEditingController(text: existing?.currency ?? 'EUR');
    final openingCtrl = TextEditingController(text: existing?.openingBalance.toString() ?? '0');
    bool isActive = existing?.isActive ?? true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(existing == null ? 'Add bank account' : 'Edit bank account'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 12),
                TextField(controller: bankNameCtrl, decoration: const InputDecoration(labelText: 'Bank name')),
                const SizedBox(height: 12),
                TextField(controller: ibanCtrl, decoration: const InputDecoration(labelText: 'IBAN')),
                const SizedBox(height: 12),
                TextField(controller: currencyCtrl, decoration: const InputDecoration(labelText: 'Currency')),
                const SizedBox(height: 12),
                TextField(controller: openingCtrl, decoration: const InputDecoration(labelText: 'Opening balance')),
                SwitchListTile(
                  value: isActive,
                  onChanged: (v) => setLocal(() => isActive = v),
                  title: const Text('Active account'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final now = DateTime.now();
                final entity = BankAccountEntity(
                  id: existing?.id,
                  name: nameCtrl.text.trim(),
                  iban: ibanCtrl.text.trim().isEmpty ? null : ibanCtrl.text.trim(),
                  bankName: bankNameCtrl.text.trim().isEmpty ? null : bankNameCtrl.text.trim(),
                  currency: currencyCtrl.text.trim(),
                  openingBalance: double.tryParse(openingCtrl.text.trim()) ?? 0,
                  isActive: isActive,
                  createdAt: existing?.createdAt ?? now,
                  updatedAt: now,
                );
                await ref.read(bankAccountsControllerProvider.notifier).save(entity);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openTransactionEditor(BuildContext context, {BankTransactionEntity? existing}) async {
    final accounts = ref.read(bankAccountsControllerProvider).valueOrNull ?? [];
    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a bank account first.')),
      );
      return;
    }

    int selectedAccountId = existing?.bankAccountId ?? accounts.first.id!;
    final refCtrl = TextEditingController(text: existing?.referenceNo ?? '');
    final amountCtrl = TextEditingController(text: existing?.amount.toString() ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    TransactionDirection direction = existing?.direction ?? TransactionDirection.incoming;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(existing == null ? 'Add bank transaction' : 'Edit bank transaction'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: selectedAccountId,
                  items: accounts
                      .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                      .toList(),
                  onChanged: (v) => setLocal(() => selectedAccountId = v ?? selectedAccountId),
                  decoration: const InputDecoration(labelText: 'Bank account'),
                ),
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
                TextField(controller: refCtrl, decoration: const InputDecoration(labelText: 'Reference no')),
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
                final entity = BankTransactionEntity(
                  id: existing?.id,
                  bankAccountId: selectedAccountId,
                  referenceNo: refCtrl.text.trim().isEmpty ? null : refCtrl.text.trim(),
                  direction: direction,
                  amount: double.tryParse(amountCtrl.text.trim()) ?? 0,
                  description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                  transactionDate: existing?.transactionDate ?? now,
                  createdAt: existing?.createdAt ?? now,
                  updatedAt: now,
                );
                await ref.read(bankTransactionsControllerProvider.notifier).save(entity);
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
