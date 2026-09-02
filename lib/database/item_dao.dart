import 'package:sqflite/sqflite.dart';
import 'db_helper.dart';
import '../models/models.dart';

class ItemDAO {
  static Future<int> insertItem(Item item) async {
    final db = await DBHelper.instance.database;
    return await db.insert('items', item.toMap());
  }

  static Future<List<Item>> getAllItems() async {
    final db = await DBHelper.instance.database;
    final results = await db.query('items', orderBy: 'name ASC');
    return results.map((e) => Item.fromMap(e)).toList();
  }

  static Future<int> updateItem(Item item) async {
    final db = await DBHelper.instance.database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  static Future<int> updateStock(int itemId, double newStock) async {
    final db = await DBHelper.instance.database;
    return await db.update(
      'items',
      {'current_stock': newStock},
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  static Future<int> deleteItem(int id) async {
    final db = await DBHelper.instance.database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
