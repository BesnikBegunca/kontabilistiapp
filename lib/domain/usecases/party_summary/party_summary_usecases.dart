import '../../entities/party_summary.dart';
import '../../repositories/party_summary_repository.dart';

class GetCustomerSummariesUseCase {
  final PartySummaryRepository repository;
  GetCustomerSummariesUseCase(this.repository);
  Future<List<PartySummary>> call({String search = ''}) => repository.getCustomerSummaries(search: search);
}

class GetSupplierSummariesUseCase {
  final PartySummaryRepository repository;
  GetSupplierSummariesUseCase(this.repository);
  Future<List<PartySummary>> call({String search = ''}) => repository.getSupplierSummaries(search: search);
}
