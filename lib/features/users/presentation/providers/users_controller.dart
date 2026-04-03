import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../../../domain/entities/app_user.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../domain/usecases/users/user_management_usecases.dart';

final usersSearchProvider = StateProvider<String>((ref) => '');

final usersControllerProvider =
    AsyncNotifierProvider<UsersController, List<AppUser>>(UsersController.new);

class UsersController extends AsyncNotifier<List<AppUser>> {
  late final GetUsersUseCase _get;
  late final SaveUserUseCase _save;
  late final DeleteUserUseCase _delete;

  @override
  Future<List<AppUser>> build() async {
    _get = GetUsersUseCase(ref.read(userManagementRepositoryProvider));
    _save = SaveUserUseCase(ref.read(userManagementRepositoryProvider));
    _delete = DeleteUserUseCase(ref.read(userManagementRepositoryProvider));
    return _get(search: ref.watch(usersSearchProvider));
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _get(search: ref.read(usersSearchProvider)));
  }

  Future<void> save({
    int? id,
    required String username,
    required String fullName,
    required UserRole role,
    required bool isActive,
    String? plainPassword,
  }) async {
    await _save(
      id: id,
      username: username,
      fullName: fullName,
      role: role,
      isActive: isActive,
      plainPassword: plainPassword,
    );
    await reload();
  }

  Future<void> remove(int id) async {
    await _delete(id);
    await reload();
  }
}
