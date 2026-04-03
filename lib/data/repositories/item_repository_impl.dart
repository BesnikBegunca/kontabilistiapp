import '../../domain/entities/item_entity.dart';
import '../../domain/repositories/item_repository.dart';
import '../local/dao/audit_log_dao.dart';
import '../local/dao/item_dao.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemDao dao;
  final AuditLogDao audit;

  ItemRepositoryImpl({required this.dao, required this.audit});

  @override
  Future<List<ItemEntity>> getItems({String search = ''}) => dao.getItems(search: search);

  @override
  Future<List<ItemEntity>> getActiveItems({String search = ''}) => dao.getActiveItems(search: search);

  @override
  Future<void> saveItem(ItemEntity item) async {
    await dao.saveItem(item);
    await audit.log(
      action: item.id == null ? 'create' : 'update',
      entityName: 'items',
      recordId: '${item.id ?? 'new'}',
      details: 'Item saved: ${item.name}',
    );
  }

  @override
  Future<void> deleteItem(int id) async {
    await dao.deleteItem(id);
    await audit.log(action: 'delete', entityName: 'items', recordId: '$id');
  }
}
