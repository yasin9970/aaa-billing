import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('aaa_billing.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Business Profile Table
    await db.execute('''
      CREATE TABLE business_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_name TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        email TEXT,
        invoice_prefix TEXT DEFAULT 'INV-',
        next_invoice_number INTEGER DEFAULT 1,
        terms TEXT,
        currency_symbol TEXT DEFAULT '₹'
      )
    ''');

    // Default Profile insert
    await db.insert('business_profile', {
      'business_name': 'My Business',
      'phone': '9876543210',
      'address': 'Main Market, City',
      'invoice_prefix': 'INV-',
      'next_invoice_number': 1,
      'terms': 'Thank you for your visit!',
      'currency_symbol': '₹'
    });

    // 2. Parties Table (Customers & Suppliers)
    await db.execute('''
      CREATE TABLE parties (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        type TEXT NOT NULL,
        opening_balance REAL DEFAULT 0.0,
        current_balance REAL DEFAULT 0.0,
        created_at TEXT NOT NULL
      )
    ''');

    // 3. Items & Inventory Table
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT DEFAULT 'General',
        unit TEXT DEFAULT 'PCS',
        purchase_price REAL DEFAULT 0.0,
        sale_price REAL NOT NULL,
        current_stock REAL DEFAULT 0.0,
        min_stock_alert REAL DEFAULT 5.0,
        barcode TEXT
      )
    ''');

    // 4. Invoices Table (Sales, Purchases, Quotations)
    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT NOT NULL UNIQUE,
        invoice_type TEXT NOT NULL,
        party_id INTEGER,
        party_name TEXT NOT NULL,
        date TEXT NOT NULL,
        subtotal REAL NOT NULL,
        discount REAL DEFAULT 0.0,
        total_amount REAL NOT NULL,
        paid_amount REAL DEFAULT 0.0,
        balance_amount REAL DEFAULT 0.0,
        payment_status TEXT NOT NULL,
        payment_mode TEXT DEFAULT 'CASH',
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 5. Invoice Items (Line details)
    await db.execute('''
      CREATE TABLE invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        item_id INTEGER,
        item_name TEXT NOT NULL,
        unit TEXT DEFAULT 'PCS',
        price REAL NOT NULL,
        quantity REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE
      )
    ''');

    // 6. Payments Table (In/Out Ledger)
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        receipt_number TEXT,
        payment_type TEXT NOT NULL,
        party_id INTEGER,
        party_name TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_mode TEXT NOT NULL,
        date TEXT NOT NULL,
        notes TEXT
      )
    ''');

    // 7. Expenses Table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_mode TEXT DEFAULT 'CASH',
        date TEXT NOT NULL,
        notes TEXT
      )
    ''');
  }

  // Quick Health Check method for testing
  Future<Map<String, int>> getDatabaseStats() async {
    final db = await database;
    final parties = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM parties')) ?? 0;
    final items = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM items')) ?? 0;
    final invoices = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM invoices')) ?? 0;
    final expenses = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM expenses')) ?? 0;
    return {
      'parties': parties,
      'items': items,
      'invoices': invoices,
      'expenses': expenses,
    };
  }
}
