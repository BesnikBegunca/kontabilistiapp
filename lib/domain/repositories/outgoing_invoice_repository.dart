import '../entities/outgoing_invoice.dart';
import '../entities/enums.dart';

abstract class OutgoingInvoiceRepository {
  Future<List<OutgoingInvoiceEntity>> getInvoices({String search = ''});
  Future<void> saveInvoice(OutgoingInvoiceEntity invoice);
  Future<void> deleteInvoice(int id);
  Future<void> registerPayment({
    required int invoiceId,
    required double amount,
    required PaymentMethod method,
    String? notes,
  });
}
