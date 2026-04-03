import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../domain/entities/app_settings.dart';
import '../database/app_database.dart';

class SettingsDao {
  Future<Database> get _db async => AppDatabase.instance;

  Future<AppSettings> getSingle() async {
    final db = await _db;
    final rows = await db.query('settings', limit: 1);
    final row = rows.first;
    return _map(row);
  }

  Future<void> update(AppSettings settings) async {
    final db = await _db;
    await db.update(
      'settings',
      {
        'invoice_prefix': settings.invoicePrefix,
        'next_invoice_number': settings.nextInvoiceNumber,
        'currency': settings.currency,
        'default_vat_rate': settings.defaultVatRate,
        'backup_folder_path': settings.backupFolderPath,
        'theme_mode': settings.themeMode,
        'updated_at': settings.updatedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [settings.id ?? 1],
    );
  }

  AppSettings _map(Map<String, Object?> row) {
    return AppSettings(
      id: row['id'] as int?,
      invoicePrefix: row['invoice_prefix'] as String,
      nextInvoiceNumber: row['next_invoice_number'] as int,
      currency: row['currency'] as String,
      defaultVatRate: (row['default_vat_rate'] as num).toDouble(),
      backupFolderPath: row['backup_folder_path'] as String?,
      themeMode: row['theme_mode'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}
