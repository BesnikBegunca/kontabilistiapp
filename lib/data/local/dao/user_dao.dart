import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/enums.dart';
import '../database/app_database.dart';

class UserDao {
  Future<Database> get _db async => AppDatabase.instance;

  Future<AppUser?> findByUsername(String username) async {
    final db = await _db;
    final rows = await db.query('users', where: 'username = ?', whereArgs: [username], limit: 1);
    if (rows.isEmpty) return null;
    return _map(rows.first);
  }

  AppUser _map(Map<String, Object?> row) {
    return AppUser(
      id: row['id'] as int?,
      username: row['username'] as String,
      passwordHash: row['password_hash'] as String,
      fullName: row['full_name'] as String,
      role: UserRole.values.firstWhere((e) => e.name == row['role_code']),
      isActive: (row['is_active'] as int) == 1,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}
