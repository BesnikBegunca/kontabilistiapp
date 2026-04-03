import '../../entities/item_entity.dart';
import '../../repositories/item_repository.dart';

class GetItemsUseCase {
  final ItemRepository repository;
  GetItemsUseCase(this.repository);
  Future<List<ItemEntity>> call({String search = ''}) => repository.getItems(search: search);
}

class GetActiveItemsUseCase {
  final ItemRepository repository;
  GetActiveItemsUseCase(this.repository);
  Future<List<ItemEntity>> call({String search = ''}) => repository.getActiveItems(search: search);
}

class SaveItemUseCase {
  final ItemRepository repository;
  SaveItemUseCase(this.repository);
  Future<void> call(ItemEntity item) => repository.saveItem(item);
}

class DeleteItemUseCase {
  final ItemRepository repository;
  DeleteItemUseCase(this.repository);
  Future<void> call(int id) => repository.deleteItem(id);
}
