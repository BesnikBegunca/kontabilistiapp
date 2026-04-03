import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/party.dart';
import '../../../../shared/widgets/empty_placeholder.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/search_toolbar.dart';
import '../../../../shared/widgets/section_card.dart';
import '../providers/customers_controller.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customersControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Customers',
          subtitle: 'Manage customers, search fast, and use them in outgoing invoices.',
        ),
        const SizedBox(height: 20),
        SearchToolbar(
          hintText: 'Search customers...',
          controller: _searchCtrl,
          onSearchChanged: () {
            ref.read(customersSearchProvider.notifier).state = _searchCtrl.text.trim();
            ref.invalidate(customersControllerProvider);
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
                    title: 'No customers yet',
                    subtitle: 'Add your first customer to start issuing invoices.',
                  );
                }
                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = rows[index];
                    return ListTile(
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text([
                        item.city,
                        item.phone,
                        item.email,
                      ].where((e) => e != null && e.isNotEmpty).join(' • ')),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            onPressed: () => _openEditor(context, existing: item),
                            icon: const Icon(Icons.edit_rounded),
                          ),
                          IconButton(
                            onPressed: () => _delete(item),
                            icon: const Icon(Icons.delete_rounded),
                          ),
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

  Future<void> _delete(Party item) async {
    if (item.id == null) return;
    await ref.read(customersControllerProvider.notifier).remove(item.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.name} deleted')),
    );
  }

  Future<void> _openEditor(BuildContext context, {Party? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final businessCtrl = TextEditingController(text: existing?.businessNumber ?? '');
    final vatCtrl = TextEditingController(text: existing?.vatNumber ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    final cityCtrl = TextEditingController(text: existing?.city ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    bool isActive = existing?.isActive ?? true;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(existing == null ? 'Add customer' : 'Edit customer'),
              content: SizedBox(
                width: 520,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _field(nameCtrl, 'Name', required: true),
                        _field(businessCtrl, 'Business number'),
                        _field(vatCtrl, 'VAT number'),
                        _field(addressCtrl, 'Address'),
                        _field(cityCtrl, 'City'),
                        _field(phoneCtrl, 'Phone'),
                        _field(emailCtrl, 'Email'),
                        SwitchListTile(
                          value: isActive,
                          onChanged: (v) => setLocal(() => isActive = v),
                          title: const Text('Active customer'),
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
                    final party = Party(
                      id: existing?.id,
                      name: nameCtrl.text.trim(),
                      businessNumber: businessCtrl.text.trim().isEmpty ? null : businessCtrl.text.trim(),
                      vatNumber: vatCtrl.text.trim().isEmpty ? null : vatCtrl.text.trim(),
                      address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
                      city: cityCtrl.text.trim().isEmpty ? null : cityCtrl.text.trim(),
                      phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                      email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                      isActive: isActive,
                      createdAt: existing?.createdAt ?? now,
                      updatedAt: now,
                    );
                    await ref.read(customersControllerProvider.notifier).save(party);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _field(TextEditingController controller, String label, {bool required = false}) {
    return SizedBox(
      width: 240,
      child: TextFormField(
        controller: controller,
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
