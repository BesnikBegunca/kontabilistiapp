import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../local/dao/audit_log_dao.dart';
import '../local/dao/expense_dao.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseDao dao;
  final AuditLogDao audit;

  ExpenseRepositoryImpl({required this.dao, required this.audit});

  @override
  Future<List<ExpenseCategoryEntity>> getCategories() => dao.getCategories();

  @override
  Future<void> saveCategory(ExpenseCategoryEntity category) async {
    await dao.saveCategory(category);
    await audit.log(action: category.id == null ? 'create' : 'update', entityName: 'expense_categories', recordId: '${category.id ?? 'new'}');
  }

  @override
  Future<List<ExpenseEntity>> getExpenses({String search = ''}) => dao.getExpenses(search: search);

  @override
  Future<void> saveExpense(ExpenseEntity expense) async {
    await dao.saveExpense(expense);
    await audit.log(action: expense.id == null ? 'create' : 'update', entityName: 'expenses', recordId: '${expense.id ?? 'new'}');
  }

  @override
  Future<void> deleteExpense(int id) async {
    await dao.deleteExpense(id);
    await audit.log(action: 'delete', entityName: 'expenses', recordId: '$id');
  }

  @override
  Future<double> getTotalExpensesThisMonth() => dao.getTotalExpensesThisMonth();
}
