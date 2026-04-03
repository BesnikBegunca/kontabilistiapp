import '../entities/audit_log.dart';

abstract class AuditLogRepository {
  Future<List<AuditLog>> getLogs({String search = ''});
}
