import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../domain/entities/party.dart';
import '../database/app_database.dart';

class PartyDao {
  Future<Database> get _db async => AppDatabase.instance;

  Future<List<Party>> getCustomers({String search = ''}) async {
    final db = await _db;
    final rows = await db.query(
      'customers',
      where: search.trim().isEmpty ? null : '(name LIKE ? OR business_number LIKE ? OR email LIKE ?)',
      whereArgs: search.trim().isEmpty ? null : ['%$search%', '%$search%', '%$search%'],
      orderBy: 'name ASC',
    );
    return rows.map(_map).toList();
  }

  Future<List<Party>> getSuppliers({String search = ''}) async {
    final db = await _db;
    final rows = await db.query(
      'suppliers',
      where: search.trim().isEmpty ? null : '(name LIKE ? OR business_number LIKE ? OR email LIKE ?)',
      whereArgs: search.trim().isEmpty ? null : ['%$search%', '%$search%', '%$search%'],
      orderBy: 'name ASC',
    );
    return rows.map(_map).toList();
  }

  Future<void> saveCustomer(Party party) async {
    final db = await _db;
    final payload = _payload(party);
    if (party.id == null) {
      await db.insert('customers', payload);
    } else {
      await db.update('customers', payload, where: 'id = ?', whereArgs: [party.id]);
    }
  }

  Future<void> saveSupplier(Party party) async {
    final db = await _db;
    final payload = _payload(party);
    if (party.id == null) {
      await db.insert('suppliers', payload);
    } else {
      await db.update('suppliers', payload, where: 'id = ?', whereArgs: [party.id]);
    }
  }

  Future<void> deleteCustomer(int id) async {
    final db = await _db;
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteSupplier(int id) async {
    final db = await _db;
    await db.delete('suppliers', where: 'id = ?', whereArgs: [id]);
  }

  Map<String, Object?> _payload(Party party) => {
        'name': party.name,
        'business_number': party.businessNumber,
        'vat_number': party.vatNumber,
        'address': party.address,
        'city': party.city,
        'phone': party.phone,
        'email': party.email,
        'is_active': party.isActive ? 1 : 0,
        'created_at': party.createdAt.toIso8601String(),
        'updated_at': party.updatedAt.toIso8601String(),
      };

  Party _map(Map<String, Object?> row) {
    return Party(
      id: row['id'] as int?,
      name: row['name'] as String,
      businessNumber: row['business_number'] as String?,
      vatNumber: row['vat_number'] as String?,
      address: row['address'] as String?,
      city: row['city'] as String?,
      phone: row['phone'] as String?,
      email: row['email'] as String?,
      isActive: (row['is_active'] as int) == 1,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}
