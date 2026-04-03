import 'package:equatable/equatable.dart';
import 'enums.dart';

class AppUser extends Equatable {
  final int? id;
  final String username;
  final String passwordHash;
  final String fullName;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, username, passwordHash, fullName, role, isActive, createdAt, updatedAt];
}
