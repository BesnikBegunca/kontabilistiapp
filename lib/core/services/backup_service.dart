import 'dart:io';
import 'package:file_selector/file_selector.dart';
import '../../data/local/database/app_database.dart';

class BackupService {
  Future<String?> createBackup() async {
    final dbPath = await AppDatabase.databasePath();
    final sourceFile = File(dbPath);
    if (!await sourceFile.exists()) return null;

    final location = await getSaveLocation(
      suggestedName: 'accounting_backup_${DateTime.now().millisecondsSinceEpoch}.db',
      acceptedTypeGroups: [
        const XTypeGroup(label: 'Database', extensions: ['db', 'sqlite']),
      ],
    );

    if (location == null) return null;
    final copied = await sourceFile.copy(location.path);
    return copied.path;
  }

  Future<bool> restoreBackup() async {
    final file = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(label: 'Database', extensions: ['db', 'sqlite']),
      ],
    );
    if (file == null) return false;

    final selected = File(file.path);
    if (!await selected.exists()) return false;
    if (await selected.length() < 2048) return false;

    try {
      final bytes = await selected.openRead(0, 64).fold<List<int>>([], (a, b) => a..addAll(b));
      final text = String.fromCharCodes(bytes);
      final probablySqlite = text.contains('SQLite format 3') || file.path.endsWith('.db') || file.path.endsWith('.sqlite');
      if (!probablySqlite) return false;
    } catch (_) {
      return false;
    }

    return AppDatabase.replaceDatabaseFrom(file.path);
  }
}
