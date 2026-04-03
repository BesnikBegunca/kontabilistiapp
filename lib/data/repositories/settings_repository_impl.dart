import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../local/dao/audit_log_dao.dart';
import '../local/dao/settings_dao.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDao dao;
  final AuditLogDao auditLogDao;

  SettingsRepositoryImpl({
    required this.dao,
    required this.auditLogDao,
  });

  @override
  Future<AppSettings> getSettings() => dao.getSingle();

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await dao.update(settings);
    await auditLogDao.log(
      action: 'update',
      entityName: 'settings',
      recordId: '${settings.id ?? 1}',
      details: 'Settings updated',
    );
  }
}
