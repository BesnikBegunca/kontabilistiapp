import '../entities/party_summary.dart';

abstract class PartySummaryRepository {
  Future<List<PartySummary>> getCustomerSummaries({String search = ''});
  Future<List<PartySummary>> getSupplierSummaries({String search = ''});
}
