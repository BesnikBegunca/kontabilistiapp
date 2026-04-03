import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../../../domain/entities/app_user.dart';
import '../../../../domain/usecases/auth/login_usecase.dart';
import '../../../../domain/usecases/auth/logout_usecase.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);

class AuthController extends AsyncNotifier<AppUser?> {
  late final LoginUseCase _login;
  late final LogoutUseCase _logout;

  @override
  Future<AppUser?> build() async {
    _login = LoginUseCase(ref.read(authRepositoryProvider));
    _logout = LogoutUseCase(ref.read(authRepositoryProvider));
    return ref.read(authRepositoryProvider).currentUser();
  }

  Future<bool> login(String username, String password) async {
    state = const AsyncLoading();
    final user = await _login(username, password);
    state = AsyncData(user);
    return user != null;
  }

  Future<void> logout() async {
    await _logout();
    state = const AsyncData(null);
  }
}
