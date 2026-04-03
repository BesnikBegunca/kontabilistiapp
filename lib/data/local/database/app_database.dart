import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../core/security/password_hasher.dart';

class AppDatabase {
  static const _dbName = 'accounting_desktop.db';
  static const _dbVersion = 1;
  static Database? _db;

  static Future<void> ensureInitialized() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await instance;
  }

  static Future<Database> get instance async {
    _db ??= await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    final appDir = await getApplicationSupportDirectory();
    final dbPath = p.join(appDir.path, _dbName);

    return databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: _dbVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON;');
        },
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE company (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        business_number TEXT,
        vat_number TEXT,
        address TEXT,
        city TEXT,
        country TEXT,
        phone TEXT,
        email TEXT,
        website TEXT,
        bank_account TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE roles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        full_name TEXT NOT NULL,
        role_code TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(role_code) REFERENCES roles(code) ON DELETE RESTRICT ON UPDATE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        business_number TEXT,
        vat_number TEXT,
        address TEXT,
        city TEXT,
        phone TEXT,
        email TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        business_number TEXT,
        vat_number TEXT,
        address TEXT,
        city TEXT,
        phone TEXT,
        email TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT,
        name TEXT NOT NULL,
        description TEXT,
        unit TEXT NOT NULL,
        price REAL NOT NULL DEFAULT 0,
        vat_rate REAL NOT NULL DEFAULT 18,
        is_service INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE outgoing_invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT NOT NULL UNIQUE,
        customer_id INTEGER NOT NULL,
        issue_date TEXT NOT NULL,
        due_date TEXT NOT NULL,
        status TEXT NOT NULL,
        subtotal REAL NOT NULL DEFAULT 0,
        vat_total REAL NOT NULL DEFAULT 0,
        total REAL NOT NULL DEFAULT 0,
        paid_amount REAL NOT NULL DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(customer_id) REFERENCES customers(id) ON DELETE RESTRICT
      );
    ''');

    await db.execute('''
      CREATE TABLE outgoing_invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        item_id INTEGER,
        item_name_snapshot TEXT NOT NULL,
        unit_snapshot TEXT NOT NULL,
        price_snapshot REAL NOT NULL,
        vat_rate_snapshot REAL NOT NULL,
        quantity REAL NOT NULL,
        line_subtotal REAL NOT NULL,
        line_vat REAL NOT NULL,
        line_total REAL NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(invoice_id) REFERENCES outgoing_invoices(id) ON DELETE CASCADE,
        FOREIGN KEY(item_id) REFERENCES items(id) ON DELETE SET NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE incoming_invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT NOT NULL UNIQUE,
        supplier_id INTEGER NOT NULL,
        issue_date TEXT NOT NULL,
        due_date TEXT NOT NULL,
        status TEXT NOT NULL,
        subtotal REAL NOT NULL DEFAULT 0,
        vat_total REAL NOT NULL DEFAULT 0,
        total REAL NOT NULL DEFAULT 0,
        paid_amount REAL NOT NULL DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(supplier_id) REFERENCES suppliers(id) ON DELETE RESTRICT
      );
    ''');

    await db.execute('''
      CREATE TABLE incoming_invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        item_id INTEGER,
        item_name_snapshot TEXT NOT NULL,
        unit_snapshot TEXT NOT NULL,
        price_snapshot REAL NOT NULL,
        vat_rate_snapshot REAL NOT NULL,
        quantity REAL NOT NULL,
        line_subtotal REAL NOT NULL,
        line_vat REAL NOT NULL,
        line_total REAL NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(invoice_id) REFERENCES incoming_invoices(id) ON DELETE CASCADE,
        FOREIGN KEY(item_id) REFERENCES items(id) ON DELETE SET NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_type TEXT NOT NULL,
        invoice_id INTEGER NOT NULL,
        payment_date TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE cash_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reference_no TEXT,
        direction TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        transaction_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE bank_accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        iban TEXT,
        bank_name TEXT,
        currency TEXT NOT NULL,
        opening_balance REAL NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE bank_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bank_account_id INTEGER NOT NULL,
        reference_no TEXT,
        direction TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        transaction_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(bank_account_id) REFERENCES bank_accounts(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE expense_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        expense_type TEXT NOT NULL,
        amount REAL NOT NULL,
        expense_date TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(category_id) REFERENCES expense_categories(id) ON DELETE SET NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT NOT NULL,
        entity_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        details TEXT,
        created_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_prefix TEXT NOT NULL,
        next_invoice_number INTEGER NOT NULL,
        currency TEXT NOT NULL,
        default_vat_rate REAL NOT NULL,
        backup_folder_path TEXT,
        theme_mode TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await db.execute('CREATE INDEX idx_users_username ON users(username);');
    await db.execute('CREATE INDEX idx_outgoing_invoices_customer_id ON outgoing_invoices(customer_id);');
    await db.execute('CREATE INDEX idx_incoming_invoices_supplier_id ON incoming_invoices(supplier_id);');
    await db.execute('CREATE INDEX idx_payments_invoice ON payments(invoice_type, invoice_id);');
    await db.execute('CREATE INDEX idx_expenses_date ON expenses(expense_date);');
    await db.execute('CREATE INDEX idx_audit_logs_entity_record ON audit_logs(entity_name, record_id);');

    final now = DateTime.now().toIso8601String();
    await db.insert('roles', {'code': 'admin', 'name': 'Administrator', 'created_at': now, 'updated_at': now});
    await db.insert('roles', {'code': 'accountant', 'name': 'Accountant', 'created_at': now, 'updated_at': now});
    await db.insert('roles', {'code': 'viewer', 'name': 'Viewer', 'created_at': now, 'updated_at': now});

    await db.insert('users', {
      'username': 'admin',
      'password_hash': PasswordHasher.hash('admin123'),
      'full_name': 'System Administrator',
      'role_code': 'admin',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('settings', {
      'invoice_prefix': 'INV',
      'next_invoice_number': 1,
      'currency': 'EUR',
      'default_vat_rate': 18.0,
      'backup_folder_path': null,
      'theme_mode': 'light',
      'created_at': now,
      'updated_at': now,
    });
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here.
  }

  static Future<String> databasePath() async {
    final appDir = await getApplicationSupportDirectory();
    return p.join(appDir.path, _dbName);
  }

  static Future<bool> replaceDatabaseFrom(String sourcePath) async {
    try {
      final currentPath = await databasePath();
      final currentFile = File(currentPath);
      final backupFile = File(sourcePath);
      if (!await backupFile.exists()) return false;

      _db = null;
      if (await currentFile.exists()) {
        await currentFile.delete();
      }
      await backupFile.copy(currentPath);
      await ensureInitialized();
      return true;
    } catch (_) {
      return false;
    }
  }
}
