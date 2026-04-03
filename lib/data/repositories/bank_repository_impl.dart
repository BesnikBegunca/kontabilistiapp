import '../../domain/entities/bank_entities.dart';
import '../../domain/repositories/bank_repository.dart';
import '../local/dao/audit_log_dao.dart';
import '../local/dao/bank_dao.dart';

class BankRepositoryImpl implements BankRepository {
  final BankDao dao;
  final AuditLogDao audit;

  BankRepositoryImpl({required this.dao, required this.audit});

  @override
  Future<List<BankAccountEntity>> getAccounts() => dao.getAccounts();

  @override
  Future<void> saveAccount(BankAccountEntity account) async {
    await dao.saveAccount(account);
    await audit.log(action: account.id == null ? 'create' : 'update', entityName: 'bank_accounts', recordId: '${account.id ?? 'new'}');
  }

  @override
  Future<void> deleteAccount(int id) async {
    await dao.deleteAccount(id);
    await audit.log(action: 'delete', entityName: 'bank_accounts', recordId: '$id');
  }

  @override
  Future<List<BankTransactionEntity>> getTransactions({String search = ''}) => dao.getTransactions(search: search);

  @override
  Future<void> saveTransaction(BankTransactionEntity transaction) async {
    await dao.saveTransaction(transaction);
    await audit.log(action: transaction.id == null ? 'create' : 'update', entityName: 'bank_transactions', recordId: '${transaction.id ?? 'new'}');
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await dao.deleteTransaction(id);
    await audit.log(action: 'delete', entityName: 'bank_transactions', recordId: '$id');
  }

  @override
  Future<double> getBalance() => dao.getBalance();
}
