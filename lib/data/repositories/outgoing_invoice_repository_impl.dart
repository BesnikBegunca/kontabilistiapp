import '../../domain/entities/enums.dart';
import '../../domain/entities/outgoing_invoice.dart';
import '../../domain/repositories/outgoing_invoice_repository.dart';
import '../local/dao/audit_log_dao.dart';
import '../local/dao/outgoing_invoice_dao.dart';

class OutgoingInvoiceRepositoryImpl implements OutgoingInvoiceRepository {
  final OutgoingInvoiceDao dao;
  final AuditLogDao audit;

  OutgoingInvoiceRepositoryImpl({required this.dao, required this.audit});

  @override
  Future<List<OutgoingInvoiceEntity>> getInvoices({String search = ''}) => dao.getInvoices(search: search);

  @override
  Future<void> saveInvoice(OutgoingInvoiceEntity invoice) async {
    await dao.saveInvoice(invoice);
    await audit.log(
      action: invoice.id == null ? 'create' : 'update',
      entityName: 'outgoing_invoices',
      recordId: invoice.invoiceNumber,
      details: 'Outgoing invoice saved',
    );
  }

  @override
  Future<void> deleteInvoice(int id) async {
    await dao.deleteInvoice(id);
    await audit.log(action: 'delete', entityName: 'outgoing_invoices', recordId: '$id');
  }

  @override
  Future<void> registerPayment({
    required int invoiceId,
    required double amount,
    required PaymentMethod method,
    String? notes,
  }) async {
    await dao.registerPayment(
      invoiceId: invoiceId,
      amount: amount,
      method: method,
      notes: notes,
    );
    await audit.log(
      action: 'payment',
      entityName: 'outgoing_invoices',
      recordId: '$invoiceId',
      details: 'Payment registered amount=$amount method=${method.name}',
    );
  }
}
