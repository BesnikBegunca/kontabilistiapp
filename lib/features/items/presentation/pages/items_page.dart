import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/formatters.dart';
import '../../../../domain/entities/item_entity.dart';
import '../../../../shared/widgets/empty_placeholder.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/search_toolbar.dart';
import '../../../../shared/widgets/section_card.dart';
import '../providers/items_controller.dart';

class ItemsPage extends ConsumerStatefulWidget {
  const ItemsPage({super.key});

  @override
  ConsumerState<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends ConsumerState<ItemsPage> {
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itemsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Items & Services',
          subtitle: 'Create reusable products/services with VAT and active status control.',
        ),
        const SizedBox(height: 20),
        SearchToolbar(
          hintText: 'Search items...',
          controller: _searchCtrl,
          onSearchChanged: () {
            ref.read(itemsSearchProvider.notifier).state = _searchCtrl.text.trim();
            ref.invalidate(itemsControllerProvider);
          },
          onAdd: () => _openEditor(context),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SectionCard(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (rows) {
                if (rows.isEmpty) {
                  return const EmptyPlaceholder(
                    title: 'No items yet',
                    subtitle: 'Add items or services to start building invoices.',
                  );
                }
                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = rows[index];
                    return ListTile(
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${item.unit} • ${item.vatRate.toStringAsFixed(0)}% VAT • ${item.isService ? 'Service' : 'Item'}'),
                      trailing: Wrap(
                        spacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(Formatters.money(item.price), style: const TextStyle(fontWeight: FontWeight.w700)),
                          Icon(item.isActive ? Icons.check_circle : Icons.block, color: item.isActive ? Colors.green : Colors.red),
                          IconButton(onPressed: () => _openEditor(context, existing: item), icon: const Icon(Icons.edit_rounded)),
                          IconButton(onPressed: () => _delete(item), icon: const Icon(Icons.delete_rounded)),
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

  Future<void> _delete(ItemEntity item) async {
    if (item.id == null) return;
    await ref.read(itemsControllerProvider.notifier).remove(item.id!);
  }

  Future<void> _openEditor(BuildContext context, {ItemEntity? existing}) async {
    final codeCtrl = TextEditingController(text: existing?.code ?? '');
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final unitCtrl = TextEditingController(text: existing?.unit ?? 'pcs');
    final priceCtrl = TextEditingController(text: existing?.price.toString() ?? '0');
    final vatCtrl = TextEditingController(text: existing?.vatRate.toString() ?? '18');
    bool isService = existing?.isService ?? false;
    bool isActive = existing?.isActive ?? true;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setLocal) {
          return AlertDialog(
            title: Text(existing == null ? 'Add item/service' : 'Edit item/service'),
            content: SizedBox(
              width: 560,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _field(codeCtrl, 'Code'),
                      _field(nameCtrl, 'Name', required: true),
                      _field(unitCtrl, 'Unit', required: true),
                      _field(priceCtrl, 'Price', number: true, required: true),
                      _field(vatCtrl, 'VAT rate', number: true, required: true),
                      SizedBox(
                        width: 240,
                        child: TextFormField(
                          controller: descCtrl,
                          decoration: const InputDecoration(labelText: 'Description'),
                        ),
                      ),
                      SwitchListTile(
                        value: isService,
                        onChanged: (v) => setLocal(() => isService = v),
                        title: const Text('Service'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        value: isActive,
                        onChanged: (v) => setLocal(() => isActive = v),
                        title: const Text('Active'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final now = DateTime.now();
                  final item = ItemEntity(
                    id: existing?.id,
                    code: codeCtrl.text.trim().isEmpty ? null : codeCtrl.text.trim(),
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                    unit: unitCtrl.text.trim(),
                    price: double.tryParse(priceCtrl.text.trim()) ?? 0,
                    vatRate: double.tryParse(vatCtrl.text.trim()) ?? 18,
                    isService: isService,
                    isActive: isActive,
                    createdAt: existing?.createdAt ?? now,
                    updatedAt: now,
                  );
                  await ref.read(itemsControllerProvider.notifier).save(item);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _field(TextEditingController controller, String label, {bool number = false, bool required = false}) {
    return SizedBox(
      width: 240,
      child: TextFormField(
        controller: controller,
        keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
