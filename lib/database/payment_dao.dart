import 'package:sqflite/sqflite.dart';
import 'db_helper.dart';

class PaymentDAO {
  static Future<int> addPayment({
    required int partyId,
    required String partyName,
    required double amount,
    required String paymentType, // 'PAYMENT_IN' (Customer gives cash) or 'PAYMENT_OUT' (Supplier paid)
    required String paymentMode,
    required String date,
    String notes = '',
  }) async {
    final db = await DBHelper.instance.database;
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

      // Update party ledger
      if (paymentType == 'PAYMENT_IN') {
        // Customer paid money: reduces receivable
        await txn.rawUpdate(
          'UPDATE parties SET current_balance = current_balance - ? WHERE id = ?',
          [amount, partyId],
        );
      } else {
        // We paid supplier: increases supplier balance towards zero
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
    return await db.query('payments', orderBy: 'id DESC');
  }
}
