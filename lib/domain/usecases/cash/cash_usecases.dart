import '../../entities/cash_transaction_entity.dart';
import '../../repositories/cash_repository.dart';

class GetCashTransactionsUseCase {
  final CashRepository repository;
  GetCashTransactionsUseCase(this.repository);
  Future<List<CashTransactionEntity>> call({String search = ''}) => repository.getTransactions(search: search);
}

class SaveCashTransactionUseCase {
  final CashRepository repository;
  SaveCashTransactionUseCase(this.repository);
  Future<void> call(CashTransactionEntity transaction) => repository.saveTransaction(transaction);
}

class DeleteCashTransactionUseCase {
  final CashRepository repository;
  DeleteCashTransactionUseCase(this.repository);
  Future<void> call(int id) => repository.deleteTransaction(id);
}

class GetCashBalanceUseCase {
  final CashRepository repository;
  GetCashBalanceUseCase(this.repository);
  Future<double> call() => repository.getBalance();
}
