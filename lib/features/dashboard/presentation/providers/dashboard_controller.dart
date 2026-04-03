import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../../../domain/entities/dashboard_summary.dart';
import '../../../../domain/usecases/dashboard/get_dashboard_summary_usecase.dart';

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardSummary>(DashboardController.new);

class DashboardController extends AsyncNotifier<DashboardSummary> {
  late final GetDashboardSummaryUseCase _useCase;

  @override
  Future<DashboardSummary> build() async {
    _useCase = GetDashboardSummaryUseCase(ref.read(dashboardRepositoryProvider));
    return _useCase();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _useCase());
  }
}
