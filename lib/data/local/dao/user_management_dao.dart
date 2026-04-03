import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../core/security/password_hasher.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/enums.dart';
import '../database/app_database.dart';

class UserManagementDao {
  Future<Database> get _db async => AppDatabase.instance;

  Future<List<AppUser>> getUsers({String search = ''}) async {
    final db = await _db;
    final rows = await db.query(
      'users',
      where: search.trim().isEmpty ? null : '(username LIKE ? OR full_name LIKE ? OR role_code LIKE ?)',
      whereArgs: search.trim().isEmpty ? null : ['%$search%', '%$search%', '%$search%'],
      orderBy: 'full_name ASC',
    );
    return rows.map(_map).toList();
  }

  Future<void> saveUser({
    int? id,
    required String username,
    required String fullName,
    required UserRole role,
    required bool isActive,
    String? plainPassword,
  }) async {
    final db = await _db;
    final rows = id == null ? <Map<String, Object?>>[] : await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    final existing = rows.isEmpty ? null : rows.first;
    final now = DateTime.now().toIso8601String();

    final payload = <String, Object?>{
      'username': username,
      'full_name': fullName,
      'role_code': role.name,
      'is_active': isActive ? 1 : 0,
      'created_at': existing?['created_at'] ?? now,
      'updated_at': now,
    };

    if (plainPassword != null && plainPassword.trim().isNotEmpty) {
      payload['password_hash'] = PasswordHasher.hash(plainPassword.trim());
    } else if (existing != null) {
      payload['password_hash'] = existing['password_hash'];
    }

    if (id == null) {
      await db.insert('users', payload);
    } else {
      await db.update('users', payload, where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> deleteUser(int id) async {
    final db = await _db;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
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
