import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../domain/entities/incoming_invoice.dart';
import '../../../../domain/usecases/incoming_invoices/incoming_invoice_usecases.dart';

final incomingInvoicesSearchProvider = StateProvider<String>((ref) => '');

final incomingInvoicesControllerProvider =
    AsyncNotifierProvider<IncomingInvoicesController, List<IncomingInvoiceEntity>>(
  IncomingInvoicesController.new,
);

class IncomingInvoicesController extends AsyncNotifier<List<IncomingInvoiceEntity>> {
  late final GetIncomingInvoicesUseCase _get;
  late final SaveIncomingInvoiceUseCase _save;
  late final DeleteIncomingInvoiceUseCase _delete;
  late final RegisterIncomingInvoicePaymentUseCase _payment;

  @override
  Future<List<IncomingInvoiceEntity>> build() async {
    _get = GetIncomingInvoicesUseCase(ref.read(incomingInvoiceRepositoryProvider));
    _save = SaveIncomingInvoiceUseCase(ref.read(incomingInvoiceRepositoryProvider));
    _delete = DeleteIncomingInvoiceUseCase(ref.read(incomingInvoiceRepositoryProvider));
    _payment = RegisterIncomingInvoicePaymentUseCase(ref.read(incomingInvoiceRepositoryProvider));
    return _get(search: ref.watch(incomingInvoicesSearchProvider));
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _get(search: ref.read(incomingInvoicesSearchProvider)));
  }

  Future<void> save(IncomingInvoiceEntity invoice) async {
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
    await _payment(invoiceId: invoiceId, amount: amount, method: method, notes: notes);
    await reload();
  }
}
