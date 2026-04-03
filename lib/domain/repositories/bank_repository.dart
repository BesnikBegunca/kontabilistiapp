import '../entities/bank_entities.dart';

abstract class BankRepository {
  Future<List<BankAccountEntity>> getAccounts();
  Future<void> saveAccount(BankAccountEntity account);
  Future<void> deleteAccount(int id);

  Future<List<BankTransactionEntity>> getTransactions({String search = ''});
  Future<void> saveTransaction(BankTransactionEntity transaction);
  Future<void> deleteTransaction(int id);

  Future<double> getBalance();
}
