import '../database/app_database.dart';

class AuditLogDao {
  Future<void> log({
    required String action,
    required String entityName,
    required String recordId,
    String? details,
  }) async {
    final db = await AppDatabase.instance;
    await db.insert('audit_logs', {
      'action': action,
      'entity_name': entityName,
      'record_id': recordId,
      'details': details,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
