import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../core/errors/app_exception.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/outgoing_invoice.dart';
import '../database/app_database.dart';

class OutgoingInvoiceDao {
  Future<Database> get _db async => AppDatabase.instance;

  Future<List<OutgoingInvoiceEntity>> getInvoices({String search = ''}) async {
    final db = await _db;
    final rows = await db.query(
      'outgoing_invoices',
      where: search.trim().isEmpty ? null : '(invoice_number LIKE ? OR notes LIKE ?)',
      whereArgs: search.trim().isEmpty ? null : ['%$search%', '%$search%'],
      orderBy: 'issue_date DESC, id DESC',
    );

    final result = <OutgoingInvoiceEntity>[];
    for (final row in rows) {
      final items = await db.query(
        'outgoing_invoice_items',
        where: 'invoice_id = ?',
        whereArgs: [row['id']],
        orderBy: 'id ASC',
      );
      result.add(_mapInvoice(row, items));
    }
    return result;
  }

  Future<void> saveInvoice(OutgoingInvoiceEntity invoice) async {
    final db = await _db;

    final duplicate = await db.query(
      'outgoing_invoices',
      where: 'invoice_number = ? AND (id IS NULL OR id != ?)',
      whereArgs: [invoice.invoiceNumber, invoice.id ?? -1],
      limit: 1,
    );
    if (duplicate.isNotEmpty) {
      throw const AppException('Invoice number must be unique.');
    }

    await db.transaction((txn) async {
      final invoicePayload = {
        'invoice_number': invoice.invoiceNumber,
        'customer_id': invoice.customerId,
        'issue_date': invoice.issueDate.toIso8601String(),
        'due_date': invoice.dueDate.toIso8601String(),
        'status': invoice.status.name,
        'subtotal': invoice.subtotal,
        'vat_total': invoice.vatTotal,
        'total': invoice.total,
        'paid_amount': invoice.paidAmount,
        'notes': invoice.notes,
        'created_at': invoice.createdAt.toIso8601String(),
        'updated_at': invoice.updatedAt.toIso8601String(),
      };

      int invoiceId;
      if (invoice.id == null) {
        invoiceId = await txn.insert('outgoing_invoices', invoicePayload);
      } else {
        invoiceId = invoice.id!;
        await txn.update('outgoing_invoices', invoicePayload, where: 'id = ?', whereArgs: [invoiceId]);
        await txn.delete('outgoing_invoice_items', where: 'invoice_id = ?', whereArgs: [invoiceId]);
      }

      for (final item in invoice.items) {
        await txn.insert('outgoing_invoice_items', {
          'invoice_id': invoiceId,
          'item_id': item.itemId,
          'item_name_snapshot': item.itemNameSnapshot,
          'unit_snapshot': item.unitSnapshot,
          'price_snapshot': item.priceSnapshot,
          'vat_rate_snapshot': item.vatRateSnapshot,
          'quantity': item.quantity,
          'line_subtotal': item.lineSubtotal,
          'line_vat': item.lineVat,
          'line_total': item.lineTotal,
          'created_at': invoice.createdAt.toIso8601String(),
          'updated_at': invoice.updatedAt.toIso8601String(),
        });
      }
    });
  }

  Future<void> deleteInvoice(int id) async {
    final db = await _db;
    await db.delete('outgoing_invoices', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> registerPayment({
    required int invoiceId,
    required double amount,
    required PaymentMethod method,
    String? notes,
  }) async {
    final db = await _db;
    await db.transaction((txn) async {
      final rows = await txn.query('outgoing_invoices', where: 'id = ?', whereArgs: [invoiceId], limit: 1);
      if (rows.isEmpty) throw const AppException('Invoice not found.');
      final row = rows.first;
      final total = (row['total'] as num).toDouble();
      final paid = (row['paid_amount'] as num).toDouble();
      final remaining = total - paid;

      if (amount <= 0) throw const AppException('Payment amount must be greater than 0.');
      if (amount > remaining) throw const AppException('Payment cannot exceed remaining balance.');

      final newPaid = paid + amount;
      final status = newPaid <= 0
          ? InvoiceStatus.issued
          : newPaid >= total
              ? InvoiceStatus.paid
              : InvoiceStatus.partiallyPaid;

      await txn.insert('payments', {
        'invoice_type': 'outgoing',
        'invoice_id': invoiceId,
        'payment_date': DateTime.now().toIso8601String(),
        'amount': amount,
        'payment_method': method.name,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      await txn.update(
        'outgoing_invoices',
        {
          'paid_amount': newPaid,
          'status': status.name,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [invoiceId],
      );

      if (method == PaymentMethod.cash) {
        await txn.insert('cash_transactions', {
          'reference_no': 'PAY-OUT-$invoiceId',
          'direction': 'incoming',
          'amount': amount,
          'description': 'Outgoing invoice payment #$invoiceId',
          'transaction_date': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } else {
        final accounts = await txn.query('bank_accounts', limit: 1);
        if (accounts.isNotEmpty) {
          await txn.insert('bank_transactions', {
            'bank_account_id': accounts.first['id'],
            'reference_no': 'PAY-OUT-$invoiceId',
            'direction': 'incoming',
            'amount': amount,
            'description': 'Outgoing invoice payment #$invoiceId',
            'transaction_date': DateTime.now().toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      }
    });
  }

  OutgoingInvoiceEntity _mapInvoice(
    Map<String, Object?> row,
    List<Map<String, Object?>> items,
  ) {
    return OutgoingInvoiceEntity(
      id: row['id'] as int?,
      invoiceNumber: row['invoice_number'] as String,
      customerId: row['customer_id'] as int,
      issueDate: DateTime.parse(row['issue_date'] as String),
      dueDate: DateTime.parse(row['due_date'] as String),
      status: InvoiceStatus.values.firstWhere((e) => e.name == row['status']),
      subtotal: (row['subtotal'] as num).toDouble(),
      vatTotal: (row['vat_total'] as num).toDouble(),
      total: (row['total'] as num).toDouble(),
      paidAmount: (row['paid_amount'] as num).toDouble(),
      notes: row['notes'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      items: items.map((i) => OutgoingInvoiceItemEntity(
        id: i['id'] as int?,
        itemId: i['item_id'] as int?,
        itemNameSnapshot: i['item_name_snapshot'] as String,
        unitSnapshot: i['unit_snapshot'] as String,
        priceSnapshot: (i['price_snapshot'] as num).toDouble(),
        vatRateSnapshot: (i['vat_rate_snapshot'] as num).toDouble(),
        quantity: (i['quantity'] as num).toDouble(),
        lineSubtotal: (i['line_subtotal'] as num).toDouble(),
        lineVat: (i['line_vat'] as num).toDouble(),
        lineTotal: (i['line_total'] as num).toDouble(),
      )).toList(),
    );
  }
}
