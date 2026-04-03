import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../../../domain/entities/bank_entities.dart';
import '../../../../domain/usecases/bank/bank_usecases.dart';

final bankSearchProvider = StateProvider<String>((ref) => '');

final bankAccountsControllerProvider =
    AsyncNotifierProvider<BankAccountsController, List<BankAccountEntity>>(BankAccountsController.new);
final bankTransactionsControllerProvider =
    AsyncNotifierProvider<BankTransactionsController, List<BankTransactionEntity>>(BankTransactionsController.new);
final bankBalanceProvider = FutureProvider<double>((ref) async {
  return GetBankBalanceUseCase(ref.read(bankRepositoryProvider))();
});

class BankAccountsController extends AsyncNotifier<List<BankAccountEntity>> {
  late final GetBankAccountsUseCase _get;
  late final SaveBankAccountUseCase _save;
  late final DeleteBankAccountUseCase _delete;

  @override
  Future<List<BankAccountEntity>> build() async {
    _get = GetBankAccountsUseCase(ref.read(bankRepositoryProvider));
    _save = SaveBankAccountUseCase(ref.read(bankRepositoryProvider));
    _delete = DeleteBankAccountUseCase(ref.read(bankRepositoryProvider));
    return _get();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _get());
    ref.invalidate(bankBalanceProvider);
  }

  Future<void> save(BankAccountEntity account) async {
    await _save(account);
    await reload();
  }

  Future<void> remove(int id) async {
    await _delete(id);
    await reload();
  }
}

class BankTransactionsController extends AsyncNotifier<List<BankTransactionEntity>> {
  late final GetBankTransactionsUseCase _get;
  late final SaveBankTransactionUseCase _save;
  late final DeleteBankTransactionUseCase _delete;

  @override
  Future<List<BankTransactionEntity>> build() async {
    _get = GetBankTransactionsUseCase(ref.read(bankRepositoryProvider));
    _save = SaveBankTransactionUseCase(ref.read(bankRepositoryProvider));
    _delete = DeleteBankTransactionUseCase(ref.read(bankRepositoryProvider));
    return _get(search: ref.watch(bankSearchProvider));
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _get(search: ref.read(bankSearchProvider)));
    ref.invalidate(bankBalanceProvider);
  }

  Future<void> save(BankTransactionEntity transaction) async {
    await _save(transaction);
    await reload();
  }

  Future<void> remove(int id) async {
    await _delete(id);
    await reload();
  }
}
