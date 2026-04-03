import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../../../domain/entities/party_summary.dart';
import '../../../../domain/usecases/party_summary/party_summary_usecases.dart';

final supplierSummarySearchProvider = StateProvider<String>((ref) => '');

final supplierSummariesControllerProvider =
    AsyncNotifierProvider<SupplierSummariesController, List<PartySummary>>(SupplierSummariesController.new);

class SupplierSummariesController extends AsyncNotifier<List<PartySummary>> {
  late final GetSupplierSummariesUseCase _get;

  @override
  Future<List<PartySummary>> build() async {
    _get = GetSupplierSummariesUseCase(ref.read(partySummaryRepositoryProvider));
    return _get(search: ref.watch(supplierSummarySearchProvider));
  }
}
