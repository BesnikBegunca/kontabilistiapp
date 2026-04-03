import '../../entities/expense_entity.dart';
import '../../repositories/expense_repository.dart';

class GetExpenseCategoriesUseCase {
  final ExpenseRepository repository;
  GetExpenseCategoriesUseCase(this.repository);
  Future<List<ExpenseCategoryEntity>> call() => repository.getCategories();
}

class SaveExpenseCategoryUseCase {
  final ExpenseRepository repository;
  SaveExpenseCategoryUseCase(this.repository);
  Future<void> call(ExpenseCategoryEntity category) => repository.saveCategory(category);
}

class GetExpensesUseCase {
  final ExpenseRepository repository;
  GetExpensesUseCase(this.repository);
  Future<List<ExpenseEntity>> call({String search = ''}) => repository.getExpenses(search: search);
}

class SaveExpenseUseCase {
  final ExpenseRepository repository;
  SaveExpenseUseCase(this.repository);
  Future<void> call(ExpenseEntity expense) => repository.saveExpense(expense);
}

class DeleteExpenseUseCase {
  final ExpenseRepository repository;
  DeleteExpenseUseCase(this.repository);
  Future<void> call(int id) => repository.deleteExpense(id);
}
