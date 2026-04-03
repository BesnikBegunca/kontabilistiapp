import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/company.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/section_card.dart';
import '../providers/company_controller.dart';

class FirmaPage extends ConsumerStatefulWidget {
  const FirmaPage({super.key});

  @override
  ConsumerState<FirmaPage> createState() => _FirmaPageState();
}

class _FirmaPageState extends ConsumerState<FirmaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _businessCtrl = TextEditingController();
  final _vatCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'Kosovo');
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  Company? _current;

  @override
  void initState() {
    super.initState();
    ref.listenManual(companyControllerProvider, (_, next) {
      final company = next.valueOrNull;
      if (company != null && company != _current) {
        _current = company;
        _nameCtrl.text = company.name;
        _businessCtrl.text = company.businessNumber ?? '';
        _vatCtrl.text = company.vatNumber ?? '';
        _addressCtrl.text = company.address ?? '';
        _cityCtrl.text = company.city ?? '';
        _countryCtrl.text = company.country ?? '';
        _phoneCtrl.text = company.phone ?? '';
        _emailCtrl.text = company.email ?? '';
        _websiteCtrl.text = company.website ?? '';
        _bankCtrl.text = company.bankAccount ?? '';
        _notesCtrl.text = company.notes ?? '';
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _businessCtrl.dispose();
    _vatCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _bankCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final company = Company(
      id: _current?.id,
      name: _nameCtrl.text.trim(),
      businessNumber: _businessCtrl.text.trim().isEmpty ? null : _businessCtrl.text.trim(),
      vatNumber: _vatCtrl.text.trim().isEmpty ? null : _vatCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      country: _countryCtrl.text.trim().isEmpty ? null : _countryCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      website: _websiteCtrl.text.trim().isEmpty ? null : _websiteCtrl.text.trim(),
      bankAccount: _bankCtrl.text.trim().isEmpty ? null : _bankCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: _current?.createdAt ?? now,
      updatedAt: now,
    );

    await ref.read(companyControllerProvider.notifier).save(company);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Firma u ruajt me sukses.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companyControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Firma',
          subtitle: 'Company profile used across invoices, PDFs, reports and settings.',
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SectionCard(
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Wrap(
                    runSpacing: 16,
                    spacing: 16,
                    children: [
                      _field(_nameCtrl, 'Emri i firmës', required: true),
                      _field(_businessCtrl, 'Business number'),
                      _field(_vatCtrl, 'VAT number'),
                      _field(_addressCtrl, 'Adresa'),
                      _field(_cityCtrl, 'Qyteti'),
                      _field(_countryCtrl, 'Shteti'),
                      _field(_phoneCtrl, 'Telefoni'),
                      _field(_emailCtrl, 'Email'),
                      _field(_websiteCtrl, 'Website'),
                      _field(_bankCtrl, 'Bank account / IBAN'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesCtrl,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(labelText: 'Shënime / footer notes'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: state.isLoading ? null : _save,
                        icon: const Icon(Icons.save_rounded),
                        label: Text(state.isLoading ? 'Duke ruajtur...' : 'Ruaj firmën'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label, {bool required = false}) {
    return SizedBox(
      width: 360,
      child: TextFormField(
        controller: controller,
        validator: required
            ? (value) => (value == null || value.trim().isEmpty) ? 'Required' : null
            : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
