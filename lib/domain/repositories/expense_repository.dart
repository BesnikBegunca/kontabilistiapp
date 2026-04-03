import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseCategoryEntity>> getCategories();
  Future<void> saveCategory(ExpenseCategoryEntity category);

  Future<List<ExpenseEntity>> getExpenses({String search = ''});
  Future<void> saveExpense(ExpenseEntity expense);
  Future<void> deleteExpense(int id);

  Future<double> getTotalExpensesThisMonth();
}
