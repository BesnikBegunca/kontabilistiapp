import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/app_user.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../shared/widgets/empty_placeholder.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/search_toolbar.dart';
import '../../../../shared/widgets/section_card.dart';
import '../providers/users_controller.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Users & Roles',
          subtitle: 'Manage local users, passwords and role-based access levels.',
        ),
        const SizedBox(height: 20),
        SearchToolbar(
          hintText: 'Search users...',
          controller: _searchCtrl,
          onSearchChanged: () {
            ref.read(usersSearchProvider.notifier).state = _searchCtrl.text.trim();
            ref.invalidate(usersControllerProvider);
          },
          onAdd: () => _openEditor(context),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SectionCard(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (rows) {
                if (rows.isEmpty) {
                  return const EmptyPlaceholder(
                    title: 'No users',
                    subtitle: 'Create accountant and viewer accounts for the desktop app.',
                  );
                }
                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = rows[index];
                    return ListTile(
                      title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('${user.username} • ${user.role.name}'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          Chip(label: Text(user.isActive ? 'Active' : 'Inactive')),
                          IconButton(onPressed: () => _openEditor(context, existing: user), icon: const Icon(Icons.edit_rounded)),
                          if (user.username != 'admin')
                            IconButton(
                              onPressed: user.id == null ? null : () => ref.read(usersControllerProvider.notifier).remove(user.id!),
                              icon: const Icon(Icons.delete_rounded),
                            ),
                        ],
                      ),
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

  Future<void> _openEditor(BuildContext context, {AppUser? existing}) async {
    final usernameCtrl = TextEditingController(text: existing?.username ?? '');
    final nameCtrl = TextEditingController(text: existing?.fullName ?? '');
    final passwordCtrl = TextEditingController();
    UserRole role = existing?.role ?? UserRole.accountant;
    bool isActive = existing?.isActive ?? true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(existing == null ? 'Add user' : 'Edit user'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: usernameCtrl, decoration: const InputDecoration(labelText: 'Username')),
                const SizedBox(height: 12),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full name')),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  initialValue: role,
                  items: UserRole.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                  onChanged: (v) => setLocal(() => role = v ?? UserRole.accountant),
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: existing == null ? 'Password' : 'New password (optional)',
                  ),
                ),
                SwitchListTile(
                  value: isActive,
                  onChanged: (v) => setLocal(() => isActive = v),
                  title: const Text('Active'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await ref.read(usersControllerProvider.notifier).save(
                  id: existing?.id,
                  username: usernameCtrl.text.trim(),
                  fullName: nameCtrl.text.trim(),
                  role: role,
                  isActive: isActive,
                  plainPassword: passwordCtrl.text.trim().isEmpty ? null : passwordCtrl.text.trim(),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
