import '../entities/enums.dart';
import '../entities/incoming_invoice.dart';

abstract class IncomingInvoiceRepository {
  Future<List<IncomingInvoiceEntity>> getInvoices({String search = ''});
  Future<void> saveInvoice(IncomingInvoiceEntity invoice);
  Future<void> deleteInvoice(int id);
  Future<void> registerPayment({
    required int invoiceId,
    required double amount,
    required PaymentMethod method,
    String? notes,
  });
}
