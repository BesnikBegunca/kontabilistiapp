import '../../entities/audit_log.dart';
import '../../repositories/audit_log_repository.dart';

class GetAuditLogsUseCase {
  final AuditLogRepository repository;
  GetAuditLogsUseCase(this.repository);

  Future<List<AuditLog>> call({String search = ''}) => repository.getLogs(search: search);
}
