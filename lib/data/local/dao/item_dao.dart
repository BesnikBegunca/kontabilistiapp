import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../domain/entities/item_entity.dart';
import '../database/app_database.dart';

class ItemDao {
  Future<Database> get _db async => AppDatabase.instance;

  Future<List<ItemEntity>> getItems({String search = ''}) async {
    final db = await _db;
    final rows = await db.query(
      'items',
      where: search.trim().isEmpty ? null : '(name LIKE ? OR code LIKE ? OR description LIKE ?)',
      whereArgs: search.trim().isEmpty ? null : ['%$search%', '%$search%', '%$search%'],
      orderBy: 'name ASC',
    );
    return rows.map(_map).toList();
  }

  Future<List<ItemEntity>> getActiveItems({String search = ''}) async {
    final db = await _db;
    final rows = await db.query(
      'items',
      where: search.trim().isEmpty
          ? 'is_active = 1'
          : 'is_active = 1 AND (name LIKE ? OR code LIKE ? OR description LIKE ?)',
      whereArgs: search.trim().isEmpty ? null : ['%$search%', '%$search%', '%$search%'],
      orderBy: 'name ASC',
    );
    return rows.map(_map).toList();
  }

  Future<void> saveItem(ItemEntity item) async {
    final db = await _db;
    final payload = {
      'code': item.code,
      'name': item.name,
      'description': item.description,
      'unit': item.unit,
      'price': item.price,
      'vat_rate': item.vatRate,
      'is_service': item.isService ? 1 : 0,
      'is_active': item.isActive ? 1 : 0,
      'created_at': item.createdAt.toIso8601String(),
      'updated_at': item.updatedAt.toIso8601String(),
    };
    if (item.id == null) {
      await db.insert('items', payload);
    } else {
      await db.update('items', payload, where: 'id = ?', whereArgs: [item.id]);
    }
  }

  Future<void> deleteItem(int id) async {
    final db = await _db;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  ItemEntity _map(Map<String, Object?> row) {
    return ItemEntity(
      id: row['id'] as int?,
      code: row['code'] as String?,
      name: row['name'] as String,
      description: row['description'] as String?,
      unit: row['unit'] as String,
      price: (row['price'] as num).toDouble(),
      vatRate: (row['vat_rate'] as num).toDouble(),
      isService: (row['is_service'] as int) == 1,
      isActive: (row['is_active'] as int) == 1,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}
