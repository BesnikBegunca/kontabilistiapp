import 'package:flutter/material.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/section_card.dart';

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key});

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  final _service = BackupService();
  bool _busy = false;

  Future<void> _backup() async {
    setState(() => _busy = true);
    final path = await _service.createBackup();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(path == null ? 'Backup cancelled or failed.' : 'Backup created: $path')),
    );
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    final ok = await _service.restoreBackup();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Database restored successfully. Restart app recommended.' : 'Restore failed. File may be invalid or too small.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Backup & Restore',
          subtitle: 'Protect your local accounting data with validated file-based backups.',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create Backup', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    const Text('Copy the SQLite database to a selected safe location.'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _busy ? null : _backup,
                      icon: const Icon(Icons.save_rounded),
                      label: Text(_busy ? 'Working...' : 'Create backup'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Restore Backup', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    const Text('Selected file is validated before replacing the current local database.'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _busy ? null : _restore,
                      icon: const Icon(Icons.restore_rounded),
                      label: Text(_busy ? 'Working...' : 'Restore backup'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
