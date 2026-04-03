import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/audit_log_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/bank_repository.dart';
import '../../domain/repositories/cash_repository.dart';
import '../../domain/repositories/company_repository.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/repositories/document_numbering_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/incoming_invoice_repository.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/repositories/outgoing_invoice_repository.dart';
import '../../domain/repositories/party_repository.dart';
import '../../domain/repositories/party_summary_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/user_management_repository.dart';
import '../local/dao/audit_log_dao.dart';
import '../local/dao/audit_log_reader_dao.dart';
import '../local/dao/bank_dao.dart';
import '../local/dao/cash_dao.dart';
import '../local/dao/company_dao.dart';
import '../local/dao/dashboard_dao.dart';
import '../local/dao/document_numbering_dao.dart';
import '../local/dao/expense_dao.dart';
import '../local/dao/incoming_invoice_dao.dart';
import '../local/dao/item_dao.dart';
import '../local/dao/outgoing_invoice_dao.dart';
import '../local/dao/party_dao.dart';
import '../local/dao/party_summary_dao.dart';
import '../local/dao/payment_dao.dart';
import '../local/dao/settings_dao.dart';
import '../local/dao/user_dao.dart';
import '../local/dao/user_management_dao.dart';
import '../repositories/audit_log_repository_impl.dart';
import '../repositories/auth_repository_impl.dart';
import '../repositories/bank_repository_impl.dart';
import '../repositories/cash_repository_impl.dart';
import '../repositories/company_repository_impl.dart';
import '../repositories/dashboard_repository_impl.dart';
import '../repositories/document_numbering_repository_impl.dart';
import '../repositories/expense_repository_impl.dart';
import '../repositories/incoming_invoice_repository_impl.dart';
import '../repositories/item_repository_impl.dart';
import '../repositories/outgoing_invoice_repository_impl.dart';
import '../repositories/party_repository_impl.dart';
import '../repositories/party_summary_repository_impl.dart';
import '../repositories/payment_repository_impl.dart';
import '../repositories/settings_repository_impl.dart';
import '../repositories/user_management_repository_impl.dart';

final auditLogDaoProvider = Provider((ref) => AuditLogDao());
final auditLogReaderDaoProvider = Provider((ref) => AuditLogReaderDao());
final companyDaoProvider = Provider((ref) => CompanyDao());
final settingsDaoProvider = Provider((ref) => SettingsDao());
final userDaoProvider = Provider((ref) => UserDao());
final userManagementDaoProvider = Provider((ref) => UserManagementDao());
final partyDaoProvider = Provider((ref) => PartyDao());
final partySummaryDaoProvider = Provider((ref) => PartySummaryDao());
final itemDaoProvider = Provider((ref) => ItemDao());
final outgoingInvoiceDaoProvider = Provider((ref) => OutgoingInvoiceDao());
final incomingInvoiceDaoProvider = Provider((ref) => IncomingInvoiceDao());
final cashDaoProvider = Provider((ref) => CashDao());
final bankDaoProvider = Provider((ref) => BankDao());
final expenseDaoProvider = Provider((ref) => ExpenseDao());
final dashboardDaoProvider = Provider((ref) => DashboardDao());
final paymentDaoProvider = Provider((ref) => PaymentDao());
final documentNumberingDaoProvider = Provider((ref) => DocumentNumberingDao());

final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  return CompanyRepositoryImpl(
    dao: ref.read(companyDaoProvider),
    auditLogDao: ref.read(auditLogDaoProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(userDaoProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(
    dao: ref.read(settingsDaoProvider),
    auditLogDao: ref.read(auditLogDaoProvider),
  );
});

final partyRepositoryProvider = Provider<PartyRepository>((ref) {
  return PartyRepositoryImpl(
    dao: ref.read(partyDaoProvider),
    audit: ref.read(auditLogDaoProvider),
  );
});

final partySummaryRepositoryProvider = Provider<PartySummaryRepository>((ref) {
  return PartySummaryRepositoryImpl(ref.read(partySummaryDaoProvider));
});

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepositoryImpl(
    dao: ref.read(itemDaoProvider),
    audit: ref.read(auditLogDaoProvider),
  );
});

final outgoingInvoiceRepositoryProvider = Provider<OutgoingInvoiceRepository>((ref) {
  return OutgoingInvoiceRepositoryImpl(
    dao: ref.read(outgoingInvoiceDaoProvider),
    audit: ref.read(auditLogDaoProvider),
  );
});

final incomingInvoiceRepositoryProvider = Provider<IncomingInvoiceRepository>((ref) {
  return IncomingInvoiceRepositoryImpl(
    dao: ref.read(incomingInvoiceDaoProvider),
    audit: ref.read(auditLogDaoProvider),
  );
});

final cashRepositoryProvider = Provider<CashRepository>((ref) {
  return CashRepositoryImpl(
    dao: ref.read(cashDaoProvider),
    audit: ref.read(auditLogDaoProvider),
  );
});

final bankRepositoryProvider = Provider<BankRepository>((ref) {
  return BankRepositoryImpl(
    dao: ref.read(bankDaoProvider),
    audit: ref.read(auditLogDaoProvider),
  );
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(
    dao: ref.read(expenseDaoProvider),
    audit: ref.read(auditLogDaoProvider),
  );
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.read(dashboardDaoProvider));
});

final userManagementRepositoryProvider = Provider<UserManagementRepository>((ref) {
  return UserManagementRepositoryImpl(
    dao: ref.read(userManagementDaoProvider),
    audit: ref.read(auditLogDaoProvider),
  );
});

final auditLogRepositoryProvider = Provider<AuditLogRepository>((ref) {
  return AuditLogRepositoryImpl(ref.read(auditLogReaderDaoProvider));
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(ref.read(paymentDaoProvider));
});

final documentNumberingRepositoryProvider = Provider<DocumentNumberingRepository>((ref) {
  return DocumentNumberingRepositoryImpl(ref.read(documentNumberingDaoProvider));
});
