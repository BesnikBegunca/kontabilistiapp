import '../../domain/entities/party_summary.dart';
import '../../domain/repositories/party_summary_repository.dart';
import '../local/dao/party_summary_dao.dart';

class PartySummaryRepositoryImpl implements PartySummaryRepository {
  final PartySummaryDao dao;
  PartySummaryRepositoryImpl(this.dao);

  @override
  Future<List<PartySummary>> getCustomerSummaries({String search = ''}) => dao.getCustomerSummaries(search: search);

  @override
  Future<List<PartySummary>> getSupplierSummaries({String search = ''}) => dao.getSupplierSummaries(search: search);
}
