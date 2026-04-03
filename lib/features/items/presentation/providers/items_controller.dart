import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../../../domain/entities/item_entity.dart';
import '../../../../domain/usecases/item/item_usecases.dart';

final itemsSearchProvider = StateProvider<String>((ref) => '');

final itemsControllerProvider =
    AsyncNotifierProvider<ItemsController, List<ItemEntity>>(ItemsController.new);

class ItemsController extends AsyncNotifier<List<ItemEntity>> {
  late final GetItemsUseCase _get;
  late final SaveItemUseCase _save;
  late final DeleteItemUseCase _delete;

  @override
  Future<List<ItemEntity>> build() async {
    _get = GetItemsUseCase(ref.read(itemRepositoryProvider));
    _save = SaveItemUseCase(ref.read(itemRepositoryProvider));
    _delete = DeleteItemUseCase(ref.read(itemRepositoryProvider));
    return _get(search: ref.watch(itemsSearchProvider));
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _get(search: ref.read(itemsSearchProvider)));
  }

  Future<void> save(ItemEntity item) async {
    await _save(item);
    await reload();
  }

  Future<void> remove(int id) async {
    await _delete(id);
    await reload();
  }
}
