import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../domain/entities/outgoing_invoice.dart';
import '../../../../domain/usecases/outgoing_invoices/outgoing_invoice_usecases.dart';

final outgoingInvoicesSearchProvider = StateProvider<String>((ref) => '');

final outgoingInvoicesControllerProvider =
    AsyncNotifierProvider<OutgoingInvoicesController, List<OutgoingInvoiceEntity>>(
  OutgoingInvoicesController.new,
);

class OutgoingInvoicesController extends AsyncNotifier<List<OutgoingInvoiceEntity>> {
  late final GetOutgoingInvoicesUseCase _get;
  late final SaveOutgoingInvoiceUseCase _save;
  late final DeleteOutgoingInvoiceUseCase _delete;
  late final RegisterOutgoingInvoicePaymentUseCase _payment;

  @override
  Future<List<OutgoingInvoiceEntity>> build() async {
    _get = GetOutgoingInvoicesUseCase(ref.read(outgoingInvoiceRepositoryProvider));
    _save = SaveOutgoingInvoiceUseCase(ref.read(outgoingInvoiceRepositoryProvider));
    _delete = DeleteOutgoingInvoiceUseCase(ref.read(outgoingInvoiceRepositoryProvider));
    _payment = RegisterOutgoingInvoicePaymentUseCase(ref.read(outgoingInvoiceRepositoryProvider));
    return _get(search: ref.watch(outgoingInvoicesSearchProvider));
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _get(search: ref.read(outgoingInvoicesSearchProvider)));
  }

  Future<void> save(OutgoingInvoiceEntity invoice) async {
    await _save(invoice);
    await reload();
  }

  Future<void> remove(int id) async {
    await _delete(id);
    await reload();
  }

  Future<void> registerPayment({
    required int invoiceId,
    required double amount,
    required PaymentMethod method,
    String? notes,
  }) async {
    await _payment(
      invoiceId: invoiceId,
      amount: amount,
      method: method,
      notes: notes,
    );
    await reload();
  }
}
