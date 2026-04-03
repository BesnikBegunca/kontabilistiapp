import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/formatters.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../domain/entities/expense_entity.dart';
import '../../../../shared/widgets/empty_placeholder.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/search_toolbar.dart';
import '../../../../shared/widgets/section_card.dart';
import '../providers/expenses_controller.dart';

class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({super.key});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expensesControllerProvider);
    final categories = ref.watch(expenseCategoriesProvider).valueOrNull ?? <ExpenseCategoryEntity>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Expenses',
          subtitle: 'Record business expenses by category and expense type.',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SearchToolbar(
                hintText: 'Search expenses...',
                controller: _searchCtrl,
                onSearchChanged: () {
                  ref.read(expensesSearchProvider.notifier).state = _searchCtrl.text.trim();
                  ref.invalidate(expensesControllerProvider);
                },
                onAdd: () => _openExpenseEditor(context, categories),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _openCategoryEditor(context),
              icon: const Icon(Icons.category_rounded),
              label: const Text('Add category'),
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
                  return const EmptyPlaceholder(title: 'No expenses yet', subtitle: 'Add your first operating expense.');
                }
                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final expense = rows[index];
                    String catName = '-';
                    for (final c in categories) {
                      if (c.id == expense.categoryId) {
                        catName = c.name;
                        break;
                      }
                    }
                    return ListTile(
                      title: Text(expense.description ?? 'Expense', style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${Formatters.date(expense.expenseDate)} • ${expense.expenseType.name} • $catName'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          Text(Formatters.money(expense.amount)),
                          IconButton(onPressed: () => _openExpenseEditor(context, categories, existing: expense), icon: const Icon(Icons.edit_rounded)),
                          IconButton(onPressed: expense.id == null ? null : () => ref.read(expensesControllerProvider.notifier).remove(expense.id!), icon: const Icon(Icons.delete_rounded)),
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

  Future<void> _openCategoryEditor(BuildContext context) async {
    final nameCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add expense category'),
        content: SizedBox(
          width: 360,
          child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Category name')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final now = DateTime.now();
              await ref.read(expensesControllerProvider.notifier).saveCategory(
                ExpenseCategoryEntity(name: nameCtrl.text.trim(), createdAt: now, updatedAt: now),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _openExpenseEditor(BuildContext context, List<ExpenseCategoryEntity> categories, {ExpenseEntity? existing}) async {
    int? selectedCategoryId = existing?.categoryId ?? (categories.isNotEmpty ? categories.first.id : null);
    ExpenseType type = existing?.expenseType ?? ExpenseType.operating;
    final amountCtrl = TextEditingController(text: existing?.amount.toString() ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(existing == null ? 'Add expense' : 'Edit expense'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (categories.isNotEmpty)
                  DropdownButtonFormField<int?>(
                    initialValue: selectedCategoryId,
                    items: categories.map((e) => DropdownMenuItem<int?>(value: e.id, child: Text(e.name))).toList(),
                    onChanged: (v) => setLocal(() => selectedCategoryId = v),
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                if (categories.isNotEmpty) const SizedBox(height: 12),
                DropdownButtonFormField<ExpenseType>(
                  initialValue: type,
                  items: ExpenseType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                  onChanged: (v) => setLocal(() => type = v ?? ExpenseType.operating),
                  decoration: const InputDecoration(labelText: 'Expense type'),
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
                final entity = ExpenseEntity(
                  id: existing?.id,
                  categoryId: selectedCategoryId,
                  expenseType: type,
                  amount: double.tryParse(amountCtrl.text.trim()) ?? 0,
                  expenseDate: existing?.expenseDate ?? now,
                  description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                  createdAt: existing?.createdAt ?? now,
                  updatedAt: now,
                );
                await ref.read(expensesControllerProvider.notifier).save(entity);
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
