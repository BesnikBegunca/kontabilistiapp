import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../../../domain/entities/party.dart';
import '../../../../domain/usecases/party/party_usecases.dart';

final suppliersSearchProvider = StateProvider<String>((ref) => '');

final suppliersControllerProvider =
    AsyncNotifierProvider<SuppliersController, List<Party>>(SuppliersController.new);

class SuppliersController extends AsyncNotifier<List<Party>> {
  late final GetSuppliersUseCase _get;
  late final SaveSupplierUseCase _save;
  late final DeleteSupplierUseCase _delete;

  @override
  Future<List<Party>> build() async {
    _get = GetSuppliersUseCase(ref.read(partyRepositoryProvider));
    _save = SaveSupplierUseCase(ref.read(partyRepositoryProvider));
    _delete = DeleteSupplierUseCase(ref.read(partyRepositoryProvider));
    return _get(search: ref.watch(suppliersSearchProvider));
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _get(search: ref.read(suppliersSearchProvider)));
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
