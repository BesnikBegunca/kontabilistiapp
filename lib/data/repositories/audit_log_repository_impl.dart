import '../../domain/entities/audit_log.dart';
import '../../domain/repositories/audit_log_repository.dart';
import '../local/dao/audit_log_reader_dao.dart';

class AuditLogRepositoryImpl implements AuditLogRepository {
  final AuditLogReaderDao dao;
  AuditLogRepositoryImpl(this.dao);

  @override
  Future<List<AuditLog>> getLogs({String search = ''}) => dao.getLogs(search: search);
}
