import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/formatters.dart';
import '../../../../core/services/csv_export_service.dart';
import '../../../../shared/widgets/empty_placeholder.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/search_toolbar.dart';
import '../../../../shared/widgets/section_card.dart';
import '../providers/audit_logs_controller.dart';

class AuditLogsPage extends ConsumerStatefulWidget {
  const AuditLogsPage({super.key});

  @override
  ConsumerState<AuditLogsPage> createState() => _AuditLogsPageState();
}

class _AuditLogsPageState extends ConsumerState<AuditLogsPage> {
  final _searchCtrl = TextEditingController();
  final _csv = CsvExportService();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(auditLogsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Audit Logs',
          subtitle: 'Review create, update, delete and payment events across the system.',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SearchToolbar(
                hintText: 'Search audit logs...',
                controller: _searchCtrl,
                onSearchChanged: () {
                  ref.read(auditLogsSearchProvider.notifier).state = _searchCtrl.text.trim();
                  ref.invalidate(auditLogsControllerProvider);
                },
                onAdd: () {},
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => _export(state.valueOrNull ?? []),
              icon: const Icon(Icons.download_rounded),
              label: const Text('Export CSV'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SectionCard(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (rows) {
                if (rows.isEmpty) {
                  return const EmptyPlaceholder(title: 'No audit logs', subtitle: 'System actions will appear here automatically.');
                }
                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final log = rows[index];
                    return ListTile(
                      title: Text('${log.action.toUpperCase()} • ${log.entityName}', style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('${Formatters.date(log.createdAt)} • Record ${log.recordId}${log.details == null ? '' : ' • ${log.details}'}'),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _export(List<dynamic> rows) async {
    final path = await _csv.export(
      suggestedName: 'audit_logs_export.csv',
      headers: ['action', 'entity_name', 'record_id', 'details', 'created_at'],
      rows: rows.map<List<String>>((l) => [
        '${l.action}',
        '${l.entityName}',
        '${l.recordId}',
        '${l.details ?? ''}',
        '${l.createdAt}',
      ]).toList(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(path == null ? 'Export cancelled.' : 'CSV exported: $path')),
    );
  }
}
