import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../../../domain/entities/party.dart';
import '../../../../domain/usecases/party/party_usecases.dart';

final customersSearchProvider = StateProvider<String>((ref) => '');

final customersControllerProvider =
    AsyncNotifierProvider<CustomersController, List<Party>>(CustomersController.new);

class CustomersController extends AsyncNotifier<List<Party>> {
  late final GetCustomersUseCase _get;
  late final SaveCustomerUseCase _save;
  late final DeleteCustomerUseCase _delete;

  @override
  Future<List<Party>> build() async {
    _get = GetCustomersUseCase(ref.read(partyRepositoryProvider));
    _save = SaveCustomerUseCase(ref.read(partyRepositoryProvider));
    _delete = DeleteCustomerUseCase(ref.read(partyRepositoryProvider));
    return _get(search: ref.watch(customersSearchProvider));
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _get(search: ref.read(customersSearchProvider)));
  }

  Future<void> save(Party party) async {
    await _save(party);
    await reload();
  }

  Future<void> remove(int id) async {
    await _delete(id);
    await reload();
  }
}
