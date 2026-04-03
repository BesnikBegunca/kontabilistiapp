import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoicePdfService {
  Future<void> previewSimpleInvoice({
    required String companyName,
    required String customerName,
    required String invoiceNumber,
    required DateTime issueDate,
    required DateTime dueDate,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(companyName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.Text('Invoice: $invoiceNumber'),
                pw.Text('Customer: $customerName'),
                pw.Text('Issue date: ${issueDate.toIso8601String().split('T').first}'),
                pw.Text('Due date: ${dueDate.toIso8601String().split('T').first}'),
                pw.SizedBox(height: 24),
                pw.Text('Detailed invoice item rendering will be implemented in the invoice module step.'),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }
}
