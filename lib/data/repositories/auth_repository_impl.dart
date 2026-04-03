import '../../core/security/password_hasher.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../local/dao/user_dao.dart';

class AuthRepositoryImpl implements AuthRepository {
  final UserDao userDao;
  AppUser? _currentUser;

  AuthRepositoryImpl(this.userDao);

  @override
  Future<AppUser?> login(String username, String password) async {
    final user = await userDao.findByUsername(username);
    if (user == null || !user.isActive) return null;
    if (!PasswordHasher.verify(password, user.passwordHash)) return null;
    _currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<AppUser?> currentUser() async => _currentUser;
}
