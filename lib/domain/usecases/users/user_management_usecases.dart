import '../../entities/app_user.dart';
import '../../entities/enums.dart';
import '../../repositories/user_management_repository.dart';

class GetUsersUseCase {
  final UserManagementRepository repository;
  GetUsersUseCase(this.repository);
  Future<List<AppUser>> call({String search = ''}) => repository.getUsers(search: search);
}

class SaveUserUseCase {
  final UserManagementRepository repository;
  SaveUserUseCase(this.repository);

  Future<void> call({
    int? id,
    required String username,
    required String fullName,
    required UserRole role,
    required bool isActive,
    String? plainPassword,
  }) => repository.saveUser(
        id: id,
        username: username,
        fullName: fullName,
        role: role,
        isActive: isActive,
        plainPassword: plainPassword,
      );
}

class DeleteUserUseCase {
  final UserManagementRepository repository;
  DeleteUserUseCase(this.repository);
  Future<void> call(int id) => repository.deleteUser(id);
}
