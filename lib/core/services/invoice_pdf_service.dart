import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoicePdfLine {
  final String name;
  final String unit;
  final double quantity;
  final double price;
  final double vatRate;
  final double total;

  const InvoicePdfLine({
    required this.name,
    required this.unit,
    required this.quantity,
    required this.price,
    required this.vatRate,
    required this.total,
  });
}

class InvoicePdfService {
  Future<void> previewInvoice({
    required String companyName,
    required String companyAddress,
    required String customerName,
    required String invoiceNumber,
    required DateTime issueDate,
    required DateTime dueDate,
    required List<InvoicePdfLine> lines,
    required double subtotal,
    required double vatTotal,
    required double total,
    String? notes,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(companyName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 6),
                    pw.Text(companyAddress),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('INVOICE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 6),
                      pw.Text('No: $invoiceNumber'),
                      pw.Text('Issue: ${issueDate.toIso8601String().split("T").first}'),
                      pw.Text('Due: ${dueDate.toIso8601String().split("T").first}'),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 22),
            pw.Text('Bill To', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Text(customerName),
            pw.SizedBox(height: 18),
            pw.TableHelper.fromTextArray(
              headers: const ['#', 'Item', 'Qty', 'Unit', 'Price', 'VAT %', 'Total'],
              data: [
                for (int i = 0; i < lines.length; i++)
                  [
                    '${i + 1}',
                    lines[i].name,
                    lines[i].quantity.toStringAsFixed(2),
                    lines[i].unit,
                    lines[i].price.toStringAsFixed(2),
                    lines[i].vatRate.toStringAsFixed(0),
                    lines[i].total.toStringAsFixed(2),
                  ]
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(8),
            ),
            pw.SizedBox(height: 18),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 220,
                child: pw.Column(
                  children: [
                    _summaryRow('Subtotal', subtotal),
                    _summaryRow('VAT', vatTotal),
                    pw.Divider(),
                    _summaryRow('Total', total, bold: true),
                  ],
                ),
              ),
            ),
            if (notes != null && notes.trim().isNotEmpty) ...[
              pw.SizedBox(height: 24),
              pw.Text('Notes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text(notes),
            ],
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  pw.Widget _summaryRow(String label, double value, {bool bold = false}) {
    final style = pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(value.toStringAsFixed(2), style: style),
        ],
      ),
    );
  }
}
