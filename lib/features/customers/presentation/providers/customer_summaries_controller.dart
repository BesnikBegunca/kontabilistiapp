import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../../../domain/entities/party_summary.dart';
import '../../../../domain/usecases/party_summary/party_summary_usecases.dart';

final customerSummarySearchProvider = StateProvider<String>((ref) => '');

final customerSummariesControllerProvider =
    AsyncNotifierProvider<CustomerSummariesController, List<PartySummary>>(CustomerSummariesController.new);

class CustomerSummariesController extends AsyncNotifier<List<PartySummary>> {
  late final GetCustomerSummariesUseCase _get;

  @override
  Future<List<PartySummary>> build() async {
    _get = GetCustomerSummariesUseCase(ref.read(partySummaryRepositoryProvider));
    return _get(search: ref.watch(customerSummarySearchProvider));
  }
}
