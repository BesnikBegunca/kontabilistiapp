import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../../../domain/entities/cash_transaction_entity.dart';
import '../../../../domain/usecases/cash/cash_usecases.dart';

final cashSearchProvider = StateProvider<String>((ref) => '');

final cashTransactionsControllerProvider =
    AsyncNotifierProvider<CashTransactionsController, List<CashTransactionEntity>>(CashTransactionsController.new);

final cashBalanceProvider = FutureProvider<double>((ref) async {
  return GetCashBalanceUseCase(ref.read(cashRepositoryProvider))();
});

class CashTransactionsController extends AsyncNotifier<List<CashTransactionEntity>> {
  late final GetCashTransactionsUseCase _get;
  late final SaveCashTransactionUseCase _save;
  late final DeleteCashTransactionUseCase _delete;

  @override
  Future<List<CashTransactionEntity>> build() async {
    _get = GetCashTransactionsUseCase(ref.read(cashRepositoryProvider));
    _save = SaveCashTransactionUseCase(ref.read(cashRepositoryProvider));
    _delete = DeleteCashTransactionUseCase(ref.read(cashRepositoryProvider));
    return _get(search: ref.watch(cashSearchProvider));
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _get(search: ref.read(cashSearchProvider)));
    ref.invalidate(cashBalanceProvider);
  }

  Future<void> save(CashTransactionEntity transaction) async {
    await _save(transaction);
    await reload();
  }

  Future<void> remove(int id) async {
    await _delete(id);
    await reload();
  }
}
