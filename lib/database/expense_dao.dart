import 'package:sqflite/sqflite.dart';
import 'db_helper.dart';

class ExpenseDAO {
  static Future<int> addExpense({
    required String category,
    required double amount,
    required String paymentMode,
    required String date,
    String notes = '',
  }) async {
    final db = await DBHelper.instance.database;
    return await db.insert('expenses', {
      'category': category,
      'amount': amount,
      'payment_mode': paymentMode,
      'date': date,
      'notes': notes,
    });
  }

  static Future<List<Map<String, dynamic>>> getAllExpenses() async {
    final db = await DBHelper.instance.database;
    return await db.query('expenses', orderBy: 'id DESC');
  }

  static Future<double> getTotalExpense() async {
    final db = await DBHelper.instance.database;
    final res = await db.rawQuery('SELECT COALESCE(SUM(amount), 0) as total FROM expenses');
    return (res.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
