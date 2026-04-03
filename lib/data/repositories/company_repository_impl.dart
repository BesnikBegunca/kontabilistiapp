import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';
import '../local/dao/audit_log_dao.dart';
import '../local/dao/company_dao.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyDao dao;
  final AuditLogDao auditLogDao;

  CompanyRepositoryImpl({
    required this.dao,
    required this.auditLogDao,
  });

  @override
  Future<Company?> getCompany() => dao.getSingle();

  @override
  Future<void> upsertCompany(Company company) async {
    final existing = await dao.getSingle();
    await dao.upsert(company);
    await auditLogDao.log(
      action: existing == null ? 'create' : 'update',
      entityName: 'company',
      recordId: '${existing?.id ?? 1}',
      details: 'Company profile saved: ${company.name}',
    );
  }
}
