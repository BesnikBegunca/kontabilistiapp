import '../../domain/entities/cash_transaction_entity.dart';
import '../../domain/repositories/cash_repository.dart';
import '../local/dao/audit_log_dao.dart';
import '../local/dao/cash_dao.dart';

class CashRepositoryImpl implements CashRepository {
  final CashDao dao;
  final AuditLogDao audit;

  CashRepositoryImpl({required this.dao, required this.audit});

  @override
  Future<List<CashTransactionEntity>> getTransactions({String search = ''}) => dao.getTransactions(search: search);

  @override
  Future<void> saveTransaction(CashTransactionEntity transaction) async {
    await dao.saveTransaction(transaction);
    await audit.log(
      action: transaction.id == null ? 'create' : 'update',
      entityName: 'cash_transactions',
      recordId: '${transaction.id ?? 'new'}',
      details: transaction.description,
    );
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await dao.deleteTransaction(id);
    await audit.log(action: 'delete', entityName: 'cash_transactions', recordId: '$id');
  }

  @override
  Future<double> getBalance() => dao.getBalance();
}
