import 'package:equatable/equatable.dart';

class AuditLog extends Equatable {
  final int? id;
  final String action;
  final String entityName;
  final String recordId;
  final String? details;
  final DateTime createdAt;

  const AuditLog({
    this.id,
    required this.action,
    required this.entityName,
    required this.recordId,
    this.details,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, action, entityName, recordId, details, createdAt];
}
