import 'package:sqflite/sqflite.dart';
import 'db_helper.dart';

class SecurityDAO {
  static Future<void> _ensureTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_security (
        id INTEGER PRIMARY KEY,
        pin TEXT,
        is_enabled INTEGER DEFAULT 0
      )
    ''');
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM app_security'));
    if (count == 0) {
      await db.insert('app_security', {'id': 1, 'pin': '', 'is_enabled': 0});
    }
  }

  static Future<bool> isPinEnabled() async {
    final db = await DBHelper.instance.database;
    await _ensureTable(db);
    final res = await db.query('app_security', where: 'id = 1');
    if (res.isNotEmpty) {
      return (res.first['is_enabled'] as int) == 1 && (res.first['pin'] as String).isNotEmpty;
    }
    return false;
  }

  static Future<String> getPin() async {
    final db = await DBHelper.instance.database;
    await _ensureTable(db);
    final res = await db.query('app_security', where: 'id = 1');
    if (res.isNotEmpty) {
      return res.first['pin'] as String? ?? '';
    }
    return '';
  }

  static Future<void> setPin(String newPin, bool enabled) async {
    final db = await DBHelper.instance.database;
    await _ensureTable(db);
    await db.update(
      'app_security',
      {'pin': newPin, 'is_enabled': enabled ? 1 : 0},
      where: 'id = 1',
    );
  }
}
