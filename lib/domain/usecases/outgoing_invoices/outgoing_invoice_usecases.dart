import '../../entities/enums.dart';
import '../../entities/outgoing_invoice.dart';
import '../../repositories/outgoing_invoice_repository.dart';

class GetOutgoingInvoicesUseCase {
  final OutgoingInvoiceRepository repository;
  GetOutgoingInvoicesUseCase(this.repository);
  Future<List<OutgoingInvoiceEntity>> call({String search = ''}) => repository.getInvoices(search: search);
}

class SaveOutgoingInvoiceUseCase {
  final OutgoingInvoiceRepository repository;
  SaveOutgoingInvoiceUseCase(this.repository);
  Future<void> call(OutgoingInvoiceEntity invoice) => repository.saveInvoice(invoice);
}

class DeleteOutgoingInvoiceUseCase {
  final OutgoingInvoiceRepository repository;
  DeleteOutgoingInvoiceUseCase(this.repository);
  Future<void> call(int id) => repository.deleteInvoice(id);
}

class RegisterOutgoingInvoicePaymentUseCase {
  final OutgoingInvoiceRepository repository;
  RegisterOutgoingInvoicePaymentUseCase(this.repository);
  Future<void> call({
    required int invoiceId,
    required double amount,
    required PaymentMethod method,
    String? notes,
  }) => repository.registerPayment(
        invoiceId: invoiceId,
        amount: amount,
        method: method,
        notes: notes,
      );
}
