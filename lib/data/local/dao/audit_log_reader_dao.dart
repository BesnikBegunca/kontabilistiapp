import '../../../domain/entities/audit_log.dart';
import '../database/app_database.dart';

class AuditLogReaderDao {
  Future<List<AuditLog>> getLogs({String search = ''}) async {
    final db = await AppDatabase.instance;
    final rows = await db.query(
      'audit_logs',
      where: search.trim().isEmpty ? null : '(action LIKE ? OR entity_name LIKE ? OR record_id LIKE ? OR details LIKE ?)',
      whereArgs: search.trim().isEmpty ? null : ['%$search%', '%$search%', '%$search%', '%$search%'],
      orderBy: 'created_at DESC, id DESC',
    );

    return rows.map((row) => AuditLog(
      id: row['id'] as int?,
      action: row['action'] as String,
      entityName: row['entity_name'] as String,
      recordId: row['record_id'] as String,
      details: row['details'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
    )).toList();
  }
}
