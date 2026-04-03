import '../../../domain/entities/document_numbering_settings.dart';
import '../database/app_database.dart';

class DocumentNumberingDao {
  Future<DocumentNumberingSettings> getSettings() async {
    final db = await AppDatabase.instance;
    final rows = await db.query('settings', limit: 1);
    final row = rows.first;
    final backupFolderPath = row['backup_folder_path'] as String?;
    final parsed = _parseComposite(backupFolderPath);

    return DocumentNumberingSettings(
      outgoingInvoicePrefix: parsed['outgoingPrefix'] ?? 'INV',
      nextOutgoingInvoiceNumber: int.tryParse(parsed['outgoingNext'] ?? '1') ?? 1,
      incomingInvoicePrefix: parsed['incomingPrefix'] ?? 'BILL',
      nextIncomingInvoiceNumber: int.tryParse(parsed['incomingNext'] ?? '1') ?? 1,
    );
  }

  Future<void> saveSettings(DocumentNumberingSettings settings) async {
    final db = await AppDatabase.instance;
    final rows = await db.query('settings', limit: 1);
    final row = rows.first;
    final current = _parseComposite(row['backup_folder_path'] as String?);
    current['outgoingPrefix'] = settings.outgoingInvoicePrefix;
    current['outgoingNext'] = settings.nextOutgoingInvoiceNumber.toString();
    current['incomingPrefix'] = settings.incomingInvoicePrefix;
    current['incomingNext'] = settings.nextIncomingInvoiceNumber.toString();

    await db.update(
      'settings',
      {
        'backup_folder_path': _compose(current),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

  Future<String> generateNextOutgoingInvoiceNumber() async {
    final settings = await getSettings();
    final number = '${settings.outgoingInvoicePrefix}-${settings.nextOutgoingInvoiceNumber.toString().padLeft(5, '0')}';
    await saveSettings(
      DocumentNumberingSettings(
        outgoingInvoicePrefix: settings.outgoingInvoicePrefix,
        nextOutgoingInvoiceNumber: settings.nextOutgoingInvoiceNumber + 1,
        incomingInvoicePrefix: settings.incomingInvoicePrefix,
        nextIncomingInvoiceNumber: settings.nextIncomingInvoiceNumber,
      ),
    );
    return number;
  }

  Future<String> generateNextIncomingInvoiceNumber() async {
    final settings = await getSettings();
    final number = '${settings.incomingInvoicePrefix}-${settings.nextIncomingInvoiceNumber.toString().padLeft(5, '0')}';
    await saveSettings(
      DocumentNumberingSettings(
        outgoingInvoicePrefix: settings.outgoingInvoicePrefix,
        nextOutgoingInvoiceNumber: settings.nextOutgoingInvoiceNumber,
        incomingInvoicePrefix: settings.incomingInvoicePrefix,
        nextIncomingInvoiceNumber: settings.nextIncomingInvoiceNumber + 1,
      ),
    );
    return number;
  }

  Map<String, String> _parseComposite(String? value) {
    final map = <String, String>{};
    if (value == null || value.isEmpty) return map;
    for (final part in value.split('|')) {
      final idx = part.indexOf('=');
      if (idx == -1) continue;
      map[part.substring(0, idx)] = part.substring(idx + 1);
    }
    return map;
  }

  String _compose(Map<String, String> map) => map.entries.map((e) => '${e.key}=${e.value}').join('|');
}
