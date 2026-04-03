import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/formatters.dart';
import '../../../../core/services/invoice_pdf_service.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../domain/entities/item_entity.dart';
import '../../../../domain/entities/outgoing_invoice.dart';
import '../../../../domain/entities/party.dart';
import '../../../../domain/usecases/company/get_company_usecase.dart';
import '../../../../domain/usecases/document_numbering/document_numbering_usecases.dart';
import '../../../../domain/usecases/document_numbering/document_numbering_usecases.dart';
import '../../../../domain/usecases/item/item_usecases.dart';
import '../../../../domain/usecases/party/party_usecases.dart';
import '../../../../shared/widgets/empty_placeholder.dart';
import '../../../../shared/widgets/info_tile.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/search_toolbar.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../providers/outgoing_invoice_filters.dart';
import '../providers/outgoing_invoices_controller.dart';

class OutgoingInvoicesPage extends ConsumerStatefulWidget {
  const OutgoingInvoicesPage({super.key});

  @override
  ConsumerState<OutgoingInvoicesPage> createState() => _OutgoingInvoicesPageState();
}

class _OutgoingInvoicesPageState extends ConsumerState<OutgoingInvoicesPage> {
  final _searchCtrl = TextEditingController();
  final _pdf = InvoicePdfService();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(outgoingInvoicesControllerProvider);
    final statusFilter = ref.watch(outgoingInvoiceStatusFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Outgoing Invoices',
          subtitle: 'Issue invoices, calculate VAT automatically, and register payments safely.',
        ),
        const SizedBox(height: 20),
        SearchToolbar(
          hintText: 'Search invoices...',
          controller: _searchCtrl,
          onSearchChanged: () {
            ref.read(outgoingInvoicesSearchProvider.notifier).state = _searchCtrl.text.trim();
            ref.invalidate(outgoingInvoicesControllerProvider);
          },
          onAdd: () => _openCreateDialog(context),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            _filterChip('All', 'all', statusFilter),
            _filterChip('Issued', 'issued', statusFilter),
            _filterChip('Partially paid', 'partiallyPaid', statusFilter),
            _filterChip('Paid', 'paid', statusFilter),
            _filterChip('Draft', 'draft', statusFilter),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SectionCard(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (rows) {
                final filtered = statusFilter == 'all' ? rows : rows.where((e) => e.status.name == statusFilter).toList();
                if (filtered.isEmpty) {
                  return const EmptyPlaceholder(title: 'No outgoing invoices yet', subtitle: 'Create the first invoice and start tracking receivables.');
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isOverdue = item.dueDate.isBefore(DateTime.now()) && (item.status.name == 'issued' || item.status.name == 'partiallyPaid');
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FBFF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isOverdue ? const Color(0xFFFFB3B3) : const Color(0xFFE7EDF7)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _openDetails(item),
                              borderRadius: BorderRadius.circular(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(.10),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(Icons.receipt_long_rounded, color: Theme.of(context).colorScheme.primary),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                        const SizedBox(height: 6),
                                        Text('${Formatters.date(item.issueDate)} • Due ${Formatters.date(item.dueDate)}', style: const TextStyle(color: Colors.black54)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          StatusBadge(label: item.status.name),
                          const SizedBox(width: 14),
                          SizedBox(
                            width: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(Formatters.money(item.total), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('Remaining ${Formatters.money(item.remainingAmount)}', textAlign: TextAlign.right, style: const TextStyle(color: Colors.black54, fontSize: 12.5)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Wrap(
                            spacing: 6,
                            children: [
                              IconButton(tooltip: 'Details', onPressed: () => _openDetails(item), icon: const Icon(Icons.visibility_rounded)),
                              IconButton(tooltip: 'Payment', onPressed: item.id == null ? null : () => _openPaymentDialog(item), icon: const Icon(Icons.payments_rounded)),
                              IconButton(tooltip: 'PDF', onPressed: () => _printInvoice(item), icon: const Icon(Icons.picture_as_pdf_rounded)),
                              IconButton(tooltip: 'Duplicate', onPressed: () => _duplicateInvoice(item), icon: const Icon(Icons.copy_rounded)),
                              IconButton(tooltip: 'Delete', onPressed: item.id == null ? null : () => ref.read(outgoingInvoicesControllerProvider.notifier).remove(item.id!), icon: const Icon(Icons.delete_rounded)),
                            ],
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

  Widget _filterChip(String label, String value, String selected) {
    return ChoiceChip(
      label: Text(label),
      selected: selected == value,
      onSelected: (_) => ref.read(outgoingInvoiceStatusFilterProvider.notifier).state = value,
    );
  }

  Future<void> _openDetails(OutgoingInvoiceEntity item) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invoice ${item.invoiceNumber}'),
        content: SizedBox(
          width: 860,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: InfoTile(label: 'Issue Date', value: Formatters.date(item.issueDate))),
                  const SizedBox(width: 10),
                  Expanded(child: InfoTile(label: 'Due Date', value: Formatters.date(item.dueDate))),
                  const SizedBox(width: 10),
                  Expanded(child: InfoTile(label: 'Status', value: item.status.name)),
                  const SizedBox(width: 10),
                  Expanded(child: InfoTile(label: 'Paid', value: Formatters.money(item.paidAmount))),
                ],
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: item.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final line = item.items[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(line.itemNameSnapshot, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${line.quantity} ${line.unitSnapshot} • VAT ${line.vatRateSnapshot.toStringAsFixed(0)}%'),
                      trailing: Text(Formatters.money(line.lineTotal), style: const TextStyle(fontWeight: FontWeight.w700)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 260,
                  child: Column(
                    children: [
                      _moneyRow('Subtotal', item.subtotal),
                      _moneyRow('VAT', item.vatTotal),
                      _moneyRow('Total', item.total, bold: true),
                      _moneyRow('Remaining', item.remainingAmount, bold: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(onPressed: () => _printInvoice(item), icon: const Icon(Icons.picture_as_pdf_rounded), label: const Text('Print PDF')),
        ],
      ),
    );
  }

  Widget _moneyRow(String label, double value, {bool bold = false}) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(Formatters.money(value), style: style),
        ],
      ),
    );
  }

  Future<void> _printInvoice(OutgoingInvoiceEntity item) async {
    final company = await GetCompanyUseCase(ref.read(companyRepositoryProvider))();
    final lines = item.items.map((e) => InvoicePdfLine(
      name: e.itemNameSnapshot,
      unit: e.unitSnapshot,
      quantity: e.quantity,
      price: e.priceSnapshot,
      vatRate: e.vatRateSnapshot,
      total: e.lineTotal,
    )).toList();

    await _pdf.previewInvoice(
      companyName: company?.name ?? 'Your Company',
      companyAddress: [company?.address, company?.city, company?.country].whereType<String>().where((e) => e.trim().isNotEmpty).join(', '),
      customerName: 'Customer #${item.customerId}',
      invoiceNumber: item.invoiceNumber,
      issueDate: item.issueDate,
      dueDate: item.dueDate,
      lines: lines,
      subtotal: item.subtotal,
      vatTotal: item.vatTotal,
      total: item.total,
      notes: item.notes,
    );
  }


  Future<void> _duplicateInvoice(OutgoingInvoiceEntity invoice) async {
    final generatedNo = await GenerateNextOutgoingInvoiceNumberUseCase(ref.read(documentNumberingRepositoryProvider))();
    final now = DateTime.now();
    final duplicated = invoice.copyWith(
      id: null,
      invoiceNumber: generatedNo,
      issueDate: now,
      dueDate: now.add(const Duration(days: 15)),
      paidAmount: 0,
      status: InvoiceStatus.issued,
      createdAt: now,
      updatedAt: now,
    );
    await ref.read(outgoingInvoicesControllerProvider.notifier).save(duplicated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invoice duplicated as $generatedNo')),
    );
  }

  Future<void> _openPaymentDialog(OutgoingInvoiceEntity invoice) async {
    final amountCtrl = TextEditingController();
    PaymentMethod method = PaymentMethod.cash;
    final noteCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text('Register payment • ${invoice.invoiceNumber}'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Remaining: ${Formatters.money(invoice.remainingAmount)}'),
                const SizedBox(height: 12),
                TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 12),
                DropdownButtonFormField<PaymentMethod>(
                  initialValue: method,
                  items: const [
                    DropdownMenuItem(value: PaymentMethod.cash, child: Text('Cash')),
                    DropdownMenuItem(value: PaymentMethod.bank, child: Text('Bank')),
                  ],
                  onChanged: (v) => setLocal(() => method = v ?? PaymentMethod.cash),
                  decoration: const InputDecoration(labelText: 'Method'),
                ),
                const SizedBox(height: 12),
                TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Notes')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await ref.read(outgoingInvoicesControllerProvider.notifier).registerPayment(
                  invoiceId: invoice.id!,
                  amount: double.tryParse(amountCtrl.text.trim()) ?? 0,
                  method: method,
                  notes: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save payment'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreateDialog(BuildContext context) async {
    final customerUseCase = GetCustomersUseCase(ref.read(partyRepositoryProvider));
    final itemUseCase = GetActiveItemsUseCase(ref.read(itemRepositoryProvider));
    final customers = await customerUseCase();
    final items = await itemUseCase();

    if (!mounted) return;
    if (customers.isEmpty || items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create at least one customer and one active item first.')));
      return;
    }

    Party? selectedCustomer = customers.first;
    final generatedNo = await GenerateNextOutgoingInvoiceNumberUseCase(ref.read(documentNumberingRepositoryProvider))();
    final invoiceNoCtrl = TextEditingController(text: generatedNo);
    final notesCtrl = TextEditingController();
    DateTime issueDate = DateTime.now();
    DateTime dueDate = DateTime.now().add(const Duration(days: 15));
    final selectedLines = <_DraftLine>[];
    final availableItems = items;
    final formKey = GlobalKey<FormState>();

    double subtotal() => selectedLines.fold(0, (p, e) => p + e.subtotal);
    double vatTotal() => selectedLines.fold(0, (p, e) => p + e.vat);
    double total() => selectedLines.fold(0, (p, e) => p + e.total);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Create outgoing invoice'),
          content: SizedBox(
            width: 860,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 260,
                          child: TextFormField(
                            controller: invoiceNoCtrl,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            decoration: const InputDecoration(labelText: 'Invoice number'),
                          ),
                        ),
                        SizedBox(
                          width: 260,
                          child: DropdownButtonFormField<Party>(
                            initialValue: selectedCustomer,
                            items: customers.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                            onChanged: (v) => setLocal(() => selectedCustomer = v),
                            decoration: const InputDecoration(labelText: 'Customer'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            ItemEntity? selectedItem = availableItems.first;
                            final qtyCtrl = TextEditingController(text: '1');
                            await showDialog(
                              context: context,
                              builder: (context) => StatefulBuilder(
                                builder: (context, setItemState) => AlertDialog(
                                  title: const Text('Add invoice item'),
                                  content: SizedBox(
                                    width: 400,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        DropdownButtonFormField<ItemEntity>(
                                          initialValue: selectedItem,
                                          items: availableItems.map((e) => DropdownMenuItem(value: e, child: Text('${e.name} • ${Formatters.money(e.price)}'))).toList(),
                                          onChanged: (v) => setItemState(() => selectedItem = v),
                                          decoration: const InputDecoration(labelText: 'Item'),
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                    ElevatedButton(
                                      onPressed: () {
                                        final item = selectedItem!;
                                        final qty = double.tryParse(qtyCtrl.text.trim()) ?? 1;
                                        final lineSubtotal = item.price * qty;
                                        final lineVat = lineSubtotal * (item.vatRate / 100);
                                        selectedLines.add(_DraftLine(
                                          itemId: item.id,
                                          name: item.name,
                                          unit: item.unit,
                                          price: item.price,
                                          vatRate: item.vatRate,
                                          quantity: qty,
                                          subtotal: lineSubtotal,
                                          vat: lineVat,
                                          total: lineSubtotal + lineVat,
                                        ));
                                        Navigator.pop(context);
                                        setLocal(() {});
                                      },
                                      child: const Text('Add'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add line'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (selectedLines.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text('No invoice items yet'),
                      ),
                    ...selectedLines.asMap().entries.map((entry) {
                      final i = entry.key;
                      final line = entry.value;
                      return Card(
                        child: ListTile(
                          title: Text('${line.name} • ${line.quantity} ${line.unit}'),
                          subtitle: Text('VAT ${line.vatRate.toStringAsFixed(0)}%'),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              Text(Formatters.money(line.total)),
                              IconButton(onPressed: () { selectedLines.removeAt(i); setLocal(() {}); }, icon: const Icon(Icons.close)),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    TextFormField(controller: notesCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes')),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Subtotal: ${Formatters.money(subtotal())}'),
                          Text('VAT: ${Formatters.money(vatTotal())}'),
                          Text('Total: ${Formatters.money(total())}', style: const TextStyle(fontWeight: FontWeight.w800)),
                        ],
                      ),
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
                if (!formKey.currentState!.validate() || selectedLines.isEmpty || selectedCustomer == null) return;
                final now = DateTime.now();
                final invoice = OutgoingInvoiceEntity(
                  invoiceNumber: invoiceNoCtrl.text.trim(),
                  customerId: selectedCustomer!.id!,
                  issueDate: issueDate,
                  dueDate: dueDate,
                  status: InvoiceStatus.issued,
                  subtotal: subtotal(),
                  vatTotal: vatTotal(),
                  total: total(),
                  paidAmount: 0,
                  notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                  createdAt: now,
                  updatedAt: now,
                  items: selectedLines.map((e) => OutgoingInvoiceItemEntity(
                    itemId: e.itemId,
                    itemNameSnapshot: e.name,
                    unitSnapshot: e.unit,
                    priceSnapshot: e.price,
                    vatRateSnapshot: e.vatRate,
                    quantity: e.quantity,
                    lineSubtotal: e.subtotal,
                    lineVat: e.vat,
                    lineTotal: e.total,
                  )).toList(),
                );
                await ref.read(outgoingInvoicesControllerProvider.notifier).save(invoice);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Create invoice'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftLine {
  final int? itemId;
  final String name;
  final String unit;
  final double price;
  final double vatRate;
  final double quantity;
  final double subtotal;
  final double vat;
  final double total;

  _DraftLine({
    required this.itemId,
    required this.name,
    required this.unit,
    required this.price,
    required this.vatRate,
    required this.quantity,
    required this.subtotal,
    required this.vat,
    required this.total,
  });
}
