import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/expense_entity.dart';
import '../database/app_database.dart';

class ExpenseDao {
  Future<Database> get _db async => AppDatabase.instance;

  Future<List<ExpenseCategoryEntity>> getCategories() async {
    final db = await _db;
    final rows = await db.query('expense_categories', orderBy: 'name ASC');
    return rows.map((row) => ExpenseCategoryEntity(
      id: row['id'] as int?,
      name: row['name'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    )).toList();
  }

  Future<void> saveCategory(ExpenseCategoryEntity category) async {
    final db = await _db;
    final payload = {
      'name': category.name,
      'created_at': category.createdAt.toIso8601String(),
      'updated_at': category.updatedAt.toIso8601String(),
    };
    if (category.id == null) {
      await db.insert('expense_categories', payload);
    } else {
      await db.update('expense_categories', payload, where: 'id = ?', whereArgs: [category.id]);
    }
  }

  Future<List<ExpenseEntity>> getExpenses({String search = ''}) async {
    final db = await _db;
    final rows = await db.query(
      'expenses',
      where: search.trim().isEmpty ? null : 'description LIKE ?',
      whereArgs: search.trim().isEmpty ? null : ['%$search%'],
      orderBy: 'expense_date DESC, id DESC',
    );
    return rows.map((row) => ExpenseEntity(
      id: row['id'] as int?,
      categoryId: row['category_id'] as int?,
      expenseType: ExpenseType.values.firstWhere((e) => e.name == row['expense_type']),
      amount: (row['amount'] as num).toDouble(),
      expenseDate: DateTime.parse(row['expense_date'] as String),
      description: row['description'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    )).toList();
  }

  Future<void> saveExpense(ExpenseEntity expense) async {
    final db = await _db;
    final payload = {
      'category_id': expense.categoryId,
      'expense_type': expense.expenseType.name,
      'amount': expense.amount,
      'expense_date': expense.expenseDate.toIso8601String(),
      'description': expense.description,
      'created_at': expense.createdAt.toIso8601String(),
      'updated_at': expense.updatedAt.toIso8601String(),
    };
    if (expense.id == null) {
      await db.insert('expenses', payload);
    } else {
      await db.update('expenses', payload, where: 'id = ?', whereArgs: [expense.id]);
    }
  }

  Future<void> deleteExpense(int id) async {
    final db = await _db;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalExpensesThisMonth() async {
    final db = await _db;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1).toIso8601String();
    final end = DateTime(now.year, now.month + 1, 1).toIso8601String();

    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(amount),0) AS total FROM expenses WHERE expense_date >= ? AND expense_date < ?',
      [start, end],
    );
    return (rows.first['total'] as num?)?.toDouble() ?? 0;
  }
}
