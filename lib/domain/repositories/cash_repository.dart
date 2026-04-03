import '../entities/cash_transaction_entity.dart';

abstract class CashRepository {
  Future<List<CashTransactionEntity>> getTransactions({String search = ''});
  Future<void> saveTransaction(CashTransactionEntity transaction);
  Future<void> deleteTransaction(int id);
  Future<double> getBalance();
}
