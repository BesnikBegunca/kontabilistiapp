import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/helpers/formatters.dart';
import '../../../../data/local/database/app_database.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/section_card.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  DateTimeRange? _range;

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _range ?? DateTimeRange(start: DateTime(now.year, now.month, 1), end: now),
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _printBusinessSummary() async {
    final db = await AppDatabase.instance;
    final range = _range ?? DateTimeRange(start: DateTime(DateTime.now().year, DateTime.now().month, 1), end: DateTime.now());
    final start = range.start.toIso8601String();
    final end = range.end.add(const Duration(days: 1)).toIso8601String();

    Future<double> scalar(String sql, [List<Object?>? args]) async {
      final rows = await db.rawQuery(sql, args);
      return (rows.first.values.first as num?)?.toDouble() ?? 0;
    }

    final sales = await scalar('SELECT COALESCE(SUM(total),0) FROM outgoing_invoices WHERE issue_date >= ? AND issue_date < ?', [start, end]);
    final purchases = await scalar('SELECT COALESCE(SUM(total),0) FROM incoming_invoices WHERE issue_date >= ? AND issue_date < ?', [start, end]);
    final expenses = await scalar('SELECT COALESCE(SUM(amount),0) FROM expenses WHERE expense_date >= ? AND expense_date < ?', [start, end]);
    final payments = await scalar('SELECT COALESCE(SUM(amount),0) FROM payments WHERE payment_date >= ? AND payment_date < ?', [start, end]);

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Business Summary Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text('Range: ${Formatters.date(range.start)} - ${Formatters.date(range.end)}'),
              pw.SizedBox(height: 20),
              _row('Sales', Formatters.money(sales)),
              _row('Purchases', Formatters.money(purchases)),
              _row('Expenses', Formatters.money(expenses)),
              _row('Payments', Formatters.money(payments)),
            ],
          ),
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  Future<void> _printOutstandingReport() async {
    final db = await AppDatabase.instance;
    final out = await db.rawQuery('SELECT invoice_number, total, paid_amount, due_date FROM outgoing_invoices WHERE status IN ("issued","partiallyPaid") ORDER BY due_date ASC');
    final inc = await db.rawQuery('SELECT invoice_number, total, paid_amount, due_date FROM incoming_invoices WHERE status IN ("issued","partiallyPaid") ORDER BY due_date ASC');

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Text('Outstanding Invoices', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Text('Outgoing', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const ['Invoice', 'Total', 'Paid', 'Remaining', 'Due'],
            data: out.map((e) {
              final total = (e['total'] as num).toDouble();
              final paid = (e['paid_amount'] as num).toDouble();
              return ['${e['invoice_number']}', total.toStringAsFixed(2), paid.toStringAsFixed(2), (total - paid).toStringAsFixed(2), '${e['due_date']}'];
            }).toList(),
          ),
          pw.SizedBox(height: 18),
          pw.Text('Incoming', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const ['Invoice', 'Total', 'Paid', 'Remaining', 'Due'],
            data: inc.map((e) {
              final total = (e['total'] as num).toDouble();
              final paid = (e['paid_amount'] as num).toDouble();
              return ['${e['invoice_number']}', total.toStringAsFixed(2), paid.toStringAsFixed(2), (total - paid).toStringAsFixed(2), '${e['due_date']}'];
            }).toList(),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  static pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text(label), pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rangeText = _range == null ? 'Current month' : '${Formatters.date(_range!.start)} - ${Formatters.date(_range!.end)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Reports',
          subtitle: 'Generate filtered PDF reports with date ranges and outstanding summaries.',
        ),
        const SizedBox(height: 20),
        SectionCard(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(onPressed: _pickRange, icon: const Icon(Icons.date_range_rounded), label: Text(rangeText)),
              ElevatedButton.icon(onPressed: _printBusinessSummary, icon: const Icon(Icons.picture_as_pdf_rounded), label: const Text('Business summary PDF')),
              ElevatedButton.icon(onPressed: _printOutstandingReport, icon: const Icon(Icons.warning_amber_rounded), label: const Text('Outstanding invoices PDF')),
            ],
          ),
        ),
      ],
    );
  }
}
