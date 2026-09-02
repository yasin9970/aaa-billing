import 'package:sqflite/sqflite.dart';
import 'db_helper.dart';
import '../models/models.dart';

class PartyDAO {
  static Future<int> insertParty(Party party) async {
    final db = await DBHelper.instance.database;
    return await db.insert('parties', party.toMap());
  }

  static Future<List<Party>> getAllParties({String? type}) async {
    final db = await DBHelper.instance.database;
    List<Map<String, dynamic>> results;
    if (type != null) {
      results = await db.query(
        'parties',
        where: 'type = ?',
        whereArgs: [type],
        orderBy: 'name ASC',
      );
    } else {
      results = await db.query('parties', orderBy: 'name ASC');
    }
    return results.map((e) => Party.fromMap(e)).toList();
  }

  static Future<int> updateParty(Party party) async {
    final db = await DBHelper.instance.database;
    return await db.update(
      'parties',
      party.toMap(),
      where: 'id = ?',
      whereArgs: [party.id],
    );
  }

  static Future<int> deleteParty(int id) async {
    final db = await DBHelper.instance.database;
    return await db.delete(
      'parties',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
