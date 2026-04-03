import '../../entities/dashboard_summary.dart';
import '../../repositories/dashboard_repository.dart';

class GetDashboardSummaryUseCase {
  final DashboardRepository repository;
  GetDashboardSummaryUseCase(this.repository);

  Future<DashboardSummary> call() => repository.getSummary();
}
