import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/company_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../local/dao/audit_log_dao.dart';
import '../local/dao/company_dao.dart';
import '../local/dao/settings_dao.dart';
import '../local/dao/user_dao.dart';
import '../repositories/auth_repository_impl.dart';
import '../repositories/company_repository_impl.dart';
import '../repositories/settings_repository_impl.dart';

final auditLogDaoProvider = Provider((ref) => AuditLogDao());
final companyDaoProvider = Provider((ref) => CompanyDao());
final settingsDaoProvider = Provider((ref) => SettingsDao());
final userDaoProvider = Provider((ref) => UserDao());

final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  return CompanyRepositoryImpl(
    dao: ref.read(companyDaoProvider),
    auditLogDao: ref.read(auditLogDaoProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(userDaoProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(
    dao: ref.read(settingsDaoProvider),
    auditLogDao: ref.read(auditLogDaoProvider),
  );
});
