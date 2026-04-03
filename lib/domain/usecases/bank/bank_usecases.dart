import '../../entities/bank_entities.dart';
import '../../repositories/bank_repository.dart';

class GetBankAccountsUseCase {
  final BankRepository repository;
  GetBankAccountsUseCase(this.repository);
  Future<List<BankAccountEntity>> call() => repository.getAccounts();
}

class SaveBankAccountUseCase {
  final BankRepository repository;
  SaveBankAccountUseCase(this.repository);
  Future<void> call(BankAccountEntity account) => repository.saveAccount(account);
}

class DeleteBankAccountUseCase {
  final BankRepository repository;
  DeleteBankAccountUseCase(this.repository);
  Future<void> call(int id) => repository.deleteAccount(id);
}

class GetBankTransactionsUseCase {
  final BankRepository repository;
  GetBankTransactionsUseCase(this.repository);
  Future<List<BankTransactionEntity>> call({String search = ''}) => repository.getTransactions(search: search);
}

class SaveBankTransactionUseCase {
  final BankRepository repository;
  SaveBankTransactionUseCase(this.repository);
  Future<void> call(BankTransactionEntity transaction) => repository.saveTransaction(transaction);
}

class DeleteBankTransactionUseCase {
  final BankRepository repository;
  DeleteBankTransactionUseCase(this.repository);
  Future<void> call(int id) => repository.deleteTransaction(id);
}

class GetBankBalanceUseCase {
  final BankRepository repository;
  GetBankBalanceUseCase(this.repository);
  Future<double> call() => repository.getBalance();
}
