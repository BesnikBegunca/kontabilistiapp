import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../../../domain/entities/expense_entity.dart';
import '../../../../domain/usecases/expenses/expense_usecases.dart';

final expensesSearchProvider = StateProvider<String>((ref) => '');

final expensesControllerProvider =
    AsyncNotifierProvider<ExpensesController, List<ExpenseEntity>>(ExpensesController.new);
final expenseCategoriesProvider = FutureProvider<List<ExpenseCategoryEntity>>((ref) async {
  return GetExpenseCategoriesUseCase(ref.read(expenseRepositoryProvider))();
});

class ExpensesController extends AsyncNotifier<List<ExpenseEntity>> {
  late final GetExpensesUseCase _get;
  late final SaveExpenseUseCase _save;
  late final DeleteExpenseUseCase _delete;

  @override
  Future<List<ExpenseEntity>> build() async {
    _get = GetExpensesUseCase(ref.read(expenseRepositoryProvider));
    _save = SaveExpenseUseCase(ref.read(expenseRepositoryProvider));
    _delete = DeleteExpenseUseCase(ref.read(expenseRepositoryProvider));
    return _get(search: ref.watch(expensesSearchProvider));
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _get(search: ref.read(expensesSearchProvider)));
    ref.invalidate(expenseCategoriesProvider);
  }

  Future<void> save(ExpenseEntity expense) async {
    await _save(expense);
    await reload();
  }

  Future<void> remove(int id) async {
    await _delete(id);
    await reload();
  }

  Future<void> saveCategory(ExpenseCategoryEntity category) async {
    await SaveExpenseCategoryUseCase(ref.read(expenseRepositoryProvider))(category);
    await reload();
  }
}
