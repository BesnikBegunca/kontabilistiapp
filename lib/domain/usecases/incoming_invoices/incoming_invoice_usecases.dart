import '../../entities/enums.dart';
import '../../entities/incoming_invoice.dart';
import '../../repositories/incoming_invoice_repository.dart';

class GetIncomingInvoicesUseCase {
  final IncomingInvoiceRepository repository;
  GetIncomingInvoicesUseCase(this.repository);
  Future<List<IncomingInvoiceEntity>> call({String search = ''}) => repository.getInvoices(search: search);
}

class SaveIncomingInvoiceUseCase {
  final IncomingInvoiceRepository repository;
  SaveIncomingInvoiceUseCase(this.repository);
  Future<void> call(IncomingInvoiceEntity invoice) => repository.saveInvoice(invoice);
}

class DeleteIncomingInvoiceUseCase {
  final IncomingInvoiceRepository repository;
  DeleteIncomingInvoiceUseCase(this.repository);
  Future<void> call(int id) => repository.deleteInvoice(id);
}

class RegisterIncomingInvoicePaymentUseCase {
  final IncomingInvoiceRepository repository;
  RegisterIncomingInvoicePaymentUseCase(this.repository);
  Future<void> call({
    required int invoiceId,
    required double amount,
    required PaymentMethod method,
    String? notes,
  }) =>
      repository.registerPayment(invoiceId: invoiceId, amount: amount, method: method, notes: notes);
}
