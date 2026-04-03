import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../local/dao/dashboard_dao.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDao dao;
  DashboardRepositoryImpl(this.dao);

  @override
  Future<DashboardSummary> getSummary() => dao.getSummary();
}
