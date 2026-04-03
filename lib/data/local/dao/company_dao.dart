import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../domain/entities/company.dart';
import '../database/app_database.dart';

class CompanyDao {
  Future<Database> get _db async => AppDatabase.instance;

  Future<Company?> getSingle() async {
    final db = await _db;
    final rows = await db.query('company', limit: 1);
    if (rows.isEmpty) return null;
    return _map(rows.first);
  }

  Future<void> upsert(Company company) async {
    final db = await _db;
    final existing = await getSingle();
    final payload = {
      'name': company.name,
      'business_number': company.businessNumber,
      'vat_number': company.vatNumber,
      'address': company.address,
      'city': company.city,
      'country': company.country,
      'phone': company.phone,
      'email': company.email,
      'website': company.website,
      'bank_account': company.bankAccount,
      'notes': company.notes,
      'created_at': existing?.createdAt.toIso8601String() ?? company.createdAt.toIso8601String(),
      'updated_at': company.updatedAt.toIso8601String(),
    };

    if (existing == null) {
      await db.insert('company', payload);
    } else {
      await db.update('company', payload, where: 'id = ?', whereArgs: [existing.id]);
    }
  }

  Company _map(Map<String, Object?> row) {
    return Company(
      id: row['id'] as int?,
      name: row['name'] as String,
      businessNumber: row['business_number'] as String?,
      vatNumber: row['vat_number'] as String?,
      address: row['address'] as String?,
      city: row['city'] as String?,
      country: row['country'] as String?,
      phone: row['phone'] as String?,
      email: row['email'] as String?,
      website: row['website'] as String?,
      bankAccount: row['bank_account'] as String?,
      notes: row['notes'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}
