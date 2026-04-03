import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/app_settings.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/section_card.dart';
import '../providers/settings_controller.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _prefixCtrl = TextEditingController();
  final _nextNoCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController();
  final _vatCtrl = TextEditingController();
  final _backupCtrl = TextEditingController();
  String _themeMode = 'light';
  AppSettings? _current;

  @override
  void initState() {
    super.initState();
    ref.listenManual(settingsControllerProvider, (_, next) {
      final settings = next.valueOrNull;
      if (settings != null && settings != _current) {
        _current = settings;
        _prefixCtrl.text = settings.invoicePrefix;
        _nextNoCtrl.text = settings.nextInvoiceNumber.toString();
        _currencyCtrl.text = settings.currency;
        _vatCtrl.text = settings.defaultVatRate.toString();
        _backupCtrl.text = settings.backupFolderPath ?? '';
        _themeMode = settings.themeMode;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _prefixCtrl.dispose();
    _nextNoCtrl.dispose();
    _currencyCtrl.dispose();
    _vatCtrl.dispose();
    _backupCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _current == null) return;
    final settings = _current!.copyWith(
      invoicePrefix: _prefixCtrl.text.trim(),
      nextInvoiceNumber: int.tryParse(_nextNoCtrl.text.trim()) ?? 1,
      currency: _currencyCtrl.text.trim(),
      defaultVatRate: double.tryParse(_vatCtrl.text.trim()) ?? 18,
      backupFolderPath: _backupCtrl.text.trim().isEmpty ? null : _backupCtrl.text.trim(),
      themeMode: _themeMode,
      updatedAt: DateTime.now(),
    );
    await ref.read(settingsControllerProvider.notifier).save(settings);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings u ruajten me sukses.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Settings',
          subtitle: 'System-wide accounting preferences and invoice numbering setup.',
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SectionCard(
            child: state.when(
              data: (_) => Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _field(_prefixCtrl, 'Invoice prefix'),
                        _field(_nextNoCtrl, 'Next invoice number', number: true),
                        _field(_currencyCtrl, 'Currency'),
                        _field(_vatCtrl, 'Default VAT rate', number: true),
                        _field(_backupCtrl, 'Backup folder path'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _themeMode,
                      items: const [
                        DropdownMenuItem(value: 'light', child: Text('Light')),
                        DropdownMenuItem(value: 'dark', child: Text('Dark (reserved for next phase)')),
                      ],
                      onChanged: (value) => setState(() => _themeMode = value ?? 'light'),
                      decoration: const InputDecoration(labelText: 'Theme mode'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: state.isLoading ? null : _save,
                          icon: const Icon(Icons.save_rounded),
                          label: Text(state.isLoading ? 'Saving...' : 'Save settings'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              error: (e, _) => Center(child: Text('$e')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label, {bool number = false}) {
    return SizedBox(
      width: 320,
      child: TextFormField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
