import '../../domain/entities/app_user.dart';
import '../../domain/entities/enums.dart';
import '../../domain/repositories/user_management_repository.dart';
import '../local/dao/audit_log_dao.dart';
import '../local/dao/user_management_dao.dart';

class UserManagementRepositoryImpl implements UserManagementRepository {
  final UserManagementDao dao;
  final AuditLogDao audit;

  UserManagementRepositoryImpl({required this.dao, required this.audit});

  @override
  Future<List<AppUser>> getUsers({String search = ''}) => dao.getUsers(search: search);

  @override
  Future<void> saveUser({
    int? id,
    required String username,
    required String fullName,
    required UserRole role,
    required bool isActive,
    String? plainPassword,
  }) async {
    await dao.saveUser(
      id: id,
      username: username,
      fullName: fullName,
      role: role,
      isActive: isActive,
      plainPassword: plainPassword,
    );
    await audit.log(
      action: id == null ? 'create' : 'update',
      entityName: 'users',
      recordId: '${id ?? username}',
      details: 'User saved: $username',
    );
  }

  @override
  Future<void> deleteUser(int id) async {
    await dao.deleteUser(id);
    await audit.log(action: 'delete', entityName: 'users', recordId: '$id');
  }
}
