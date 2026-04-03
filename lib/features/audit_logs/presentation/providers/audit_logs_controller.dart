import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../../../domain/entities/audit_log.dart';
import '../../../../domain/usecases/audit_logs/audit_log_usecases.dart';

final auditLogsSearchProvider = StateProvider<String>((ref) => '');

final auditLogsControllerProvider =
    AsyncNotifierProvider<AuditLogsController, List<AuditLog>>(AuditLogsController.new);

class AuditLogsController extends AsyncNotifier<List<AuditLog>> {
  late final GetAuditLogsUseCase _get;

  @override
  Future<List<AuditLog>> build() async {
    _get = GetAuditLogsUseCase(ref.read(auditLogRepositoryProvider));
    return _get(search: ref.watch(auditLogsSearchProvider));
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _get(search: ref.read(auditLogsSearchProvider)));
  }
}
