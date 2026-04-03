import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> login(String username, String password);
  Future<void> logout();
  Future<AppUser?> currentUser();
}
