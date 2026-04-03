import '../entities/item_entity.dart';

abstract class ItemRepository {
  Future<List<ItemEntity>> getItems({String search = ''});
  Future<List<ItemEntity>> getActiveItems({String search = ''});
  Future<void> saveItem(ItemEntity item);
  Future<void> deleteItem(int id);
}
