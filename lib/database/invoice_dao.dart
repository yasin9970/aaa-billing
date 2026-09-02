import 'package:sqflite/sqflite.dart';
import 'db_helper.dart';
import '../models/models.dart';

class InvoiceDAO {
  static Future<int> createInvoice({
    required Invoice invoice,
    required List<InvoiceItem> items,
  }) async {
    final db = await DBHelper.instance.database;
    int invoiceId = 0;

    await db.transaction((txn) async {
      // 1. Insert Invoice
      invoiceId = await txn.insert('invoices', invoice.toMap());

      // 2. Insert Line Items and Auto-Update Stock
      for (var item in items) {
        final itemMap = item.toMap();
        itemMap['invoice_id'] = invoiceId;
        await txn.insert('invoice_items', itemMap);

        if (item.itemId != null) {
          if (invoice.invoiceType == 'SALE') {
            await txn.rawUpdate(
              'UPDATE items SET current_stock = current_stock - ? WHERE id = ?',
              [item.quantity, item.itemId],
            );
          } else if (invoice.invoiceType == 'PURCHASE') {
            await txn.rawUpdate(
              'UPDATE items SET current_stock = current_stock + ? WHERE id = ?',
              [item.quantity, item.itemId],
            );
          }
        }
      }

      // 3. Auto-Update Party Ledger Balance for Due Amount
      if (invoice.partyId != null && invoice.balanceAmount > 0) {
        if (invoice.invoiceType == 'SALE') {
          // Customer owes money (increases positive balance)
          await txn.rawUpdate(
            'UPDATE parties SET current_balance = current_balance + ? WHERE id = ?',
            [invoice.balanceAmount, invoice.partyId],
          );
        } else if (invoice.invoiceType == 'PURCHASE') {
          // We owe supplier money (decreases balance / increases negative)
          await txn.rawUpdate(
            'UPDATE parties SET current_balance = current_balance - ? WHERE id = ?',
            [invoice.balanceAmount, invoice.partyId],
          );
        }
      }
    });

    return invoiceId;
  }

  static Future<List<Invoice>> getInvoicesByType(String type) async {
    final db = await DBHelper.instance.database;
    final res = await db.query(
      'invoices',
      where: 'invoice_type = ?',
      whereArgs: [type],
      orderBy: 'id DESC',
    );
    return res.map((e) => Invoice.fromMap(e)).toList();
  }

  static Future<List<Invoice>> getRecentTransactions({int limit = 10}) async {
    final db = await DBHelper.instance.database;
    final res = await db.query('invoices', orderBy: 'id DESC', limit: limit);
    return res.map((e) => Invoice.fromMap(e)).toList();
  }

  static Future<Map<String, double>> getDashboardMetrics() async {
    final db = await DBHelper.instance.database;

    final salesTotal = Sqflite.firstIntValue(
          await db.rawQuery("SELECT CAST(COALESCE(SUM(total_amount), 0) AS INT) FROM invoices WHERE invoice_type = 'SALE'"),
        )?.toDouble() ?? 0.0;

    final purchaseTotal = Sqflite.firstIntValue(
          await db.rawQuery("SELECT CAST(COALESCE(SUM(total_amount), 0) AS INT) FROM invoices WHERE invoice_type = 'PURCHASE'"),
        )?.toDouble() ?? 0.0;

    final receivable = Sqflite.firstIntValue(
          await db.rawQuery("SELECT CAST(COALESCE(SUM(current_balance), 0) AS INT) FROM parties WHERE current_balance > 0"),
        )?.toDouble() ?? 0.0;

    final payable = Sqflite.firstIntValue(
          await db.rawQuery("SELECT CAST(COALESCE(ABS(SUM(current_balance)), 0) AS INT) FROM parties WHERE current_balance < 0"),
        )?.toDouble() ?? 0.0;

    return {
      'totalSales': salesTotal,
      'totalPurchases': purchaseTotal,
      'receivable': receivable,
      'payable': payable,
    };
  }
}
