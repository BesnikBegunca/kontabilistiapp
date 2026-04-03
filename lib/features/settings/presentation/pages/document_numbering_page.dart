import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/document_numbering_settings.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/section_card.dart';
import '../providers/document_numbering_controller.dart';

class DocumentNumberingPage extends ConsumerStatefulWidget {
  const DocumentNumberingPage({super.key});

  @override
  ConsumerState<DocumentNumberingPage> createState() => _DocumentNumberingPageState();
}

class _DocumentNumberingPageState extends ConsumerState<DocumentNumberingPage> {
  final _outPrefixCtrl = TextEditingController();
  final _outNextCtrl = TextEditingController();
  final _inPrefixCtrl = TextEditingController();
  final _inNextCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final value = ref.read(documentNumberingControllerProvider).valueOrNull;
      if (value != null) _fill(value);
    });
    ref.listenManual(documentNumberingControllerProvider, (_, next) {
      final value = next.valueOrNull;
      if (value != null) _fill(value);
    });
  }

  void _fill(DocumentNumberingSettings value) {
    _outPrefixCtrl.text = value.outgoingInvoicePrefix;
    _outNextCtrl.text = value.nextOutgoingInvoiceNumber.toString();
    _inPrefixCtrl.text = value.incomingInvoicePrefix;
    _inNextCtrl.text = value.nextIncomingInvoiceNumber.toString();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _outPrefixCtrl.dispose();
    _outNextCtrl.dispose();
    _inPrefixCtrl.dispose();
    _inNextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentNumberingControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Document Numbering')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Document Numbering',
              subtitle: 'Configure separate prefixes and next numbers for outgoing and incoming invoices.',
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SectionCard(
                child: state.when(
                  data: (_) => ListView(
                    children: [
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _field(_outPrefixCtrl, 'Outgoing prefix'),
                          _field(_outNextCtrl, 'Next outgoing number', number: true),
                          _field(_inPrefixCtrl, 'Incoming prefix'),
                          _field(_inNextCtrl, 'Next incoming number', number: true),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final settings = DocumentNumberingSettings(
                            outgoingInvoicePrefix: _outPrefixCtrl.text.trim(),
                            nextOutgoingInvoiceNumber: int.tryParse(_outNextCtrl.text.trim()) ?? 1,
                            incomingInvoicePrefix: _inPrefixCtrl.text.trim(),
                            nextIncomingInvoiceNumber: int.tryParse(_inNextCtrl.text.trim()) ?? 1,
                          );
                          await ref.read(documentNumberingControllerProvider.notifier).save(settings);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document numbering saved.')));
                        },
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Save numbering'),
                      ),
                    ],
                  ),
                  error: (e, _) => Center(child: Text('$e')),
                  loading: () => const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, {bool number = false}) {
    return SizedBox(
      width: 320,
      child: TextField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
