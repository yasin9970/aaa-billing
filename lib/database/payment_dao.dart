import 'package:sqflite/sqflite.dart';
import 'db_helper.dart';

class PaymentDAO {
  static Future<void> _ensureTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        party_id INTEGER,
        party_name TEXT,
        amount REAL,
        payment_type TEXT,
        payment_mode TEXT,
        date TEXT,
        notes TEXT,
        created_at TEXT
      )
    ''');
  }

  static Future<int> addPayment({
    required int partyId,
    required String partyName,
    required double amount,
    required String paymentType,
    required String paymentMode,
    required String date,
    String notes = '',
  }) async {
    final db = await DBHelper.instance.database;
    await _ensureTable(db);
    int paymentId = 0;

    await db.transaction((txn) async {
      paymentId = await txn.insert('payments', {
        'party_id': partyId,
        'party_name': partyName,
        'amount': amount,
        'payment_type': paymentType,
        'payment_mode': paymentMode,
        'date': date,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (paymentType == 'PAYMENT_IN') {
        await txn.rawUpdate(
          'UPDATE parties SET current_balance = current_balance - ? WHERE id = ?',
          [amount, partyId],
        );
      } else {
        await txn.rawUpdate(
          'UPDATE parties SET current_balance = current_balance + ? WHERE id = ?',
          [amount, partyId],
        );
      }
    });

    return paymentId;
  }

  static Future<List<Map<String, dynamic>>> getPayments() async {
    final db = await DBHelper.instance.database;
    await _ensureTable(db);
    return await db.query('payments', orderBy: 'id DESC');
  }
}
