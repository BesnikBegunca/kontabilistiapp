import '../entities/app_user.dart';
import '../entities/enums.dart';

abstract class UserManagementRepository {
  Future<List<AppUser>> getUsers({String search = ''});
  Future<void> saveUser({
    int? id,
    required String username,
    required String fullName,
    required UserRole role,
    required bool isActive,
    String? plainPassword,
  });
  Future<void> deleteUser(int id);
}
