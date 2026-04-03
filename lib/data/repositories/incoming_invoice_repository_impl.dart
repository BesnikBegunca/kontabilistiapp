import '../../domain/entities/enums.dart';
import '../../domain/entities/incoming_invoice.dart';
import '../../domain/repositories/incoming_invoice_repository.dart';
import '../local/dao/audit_log_dao.dart';
import '../local/dao/incoming_invoice_dao.dart';

class IncomingInvoiceRepositoryImpl implements IncomingInvoiceRepository {
  final IncomingInvoiceDao dao;
  final AuditLogDao audit;

  IncomingInvoiceRepositoryImpl({required this.dao, required this.audit});

  @override
  Future<List<IncomingInvoiceEntity>> getInvoices({String search = ''}) => dao.getInvoices(search: search);

  @override
  Future<void> saveInvoice(IncomingInvoiceEntity invoice) async {
    await dao.saveInvoice(invoice);
    await audit.log(
      action: invoice.id == null ? 'create' : 'update',
      entityName: 'incoming_invoices',
      recordId: invoice.invoiceNumber,
      details: 'Incoming invoice saved',
    );
  }

  @override
  Future<void> deleteInvoice(int id) async {
    await dao.deleteInvoice(id);
    await audit.log(action: 'delete', entityName: 'incoming_invoices', recordId: '$id');
  }

  @override
  Future<void> registerPayment({
    required int invoiceId,
    required double amount,
    required PaymentMethod method,
    String? notes,
  }) async {
    await dao.registerPayment(invoiceId: invoiceId, amount: amount, method: method, notes: notes);
    await audit.log(
      action: 'payment',
      entityName: 'incoming_invoices',
      recordId: '$invoiceId',
      details: 'Payment registered amount=$amount method=${method.name}',
    );
  }
}
