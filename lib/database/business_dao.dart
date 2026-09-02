import 'package:sqflite/sqflite.dart';
import 'db_helper.dart';
import '../models/models.dart';

class BusinessDAO {
  static Future<BusinessProfile> getProfile() async {
    final db = await DBHelper.instance.database;
    final res = await db.query('business_settings', limit: 1);
    if (res.isNotEmpty) {
      return BusinessProfile.fromMap(res.first);
    }
    final defaultProf = BusinessProfile(
      businessName: "BATTERY ZONE",
      phone: "9975914610",
      address: "Shop No.12 Gurukrupa Vyapari Sankul Dasak Opp. Bharat Petrol Pump Jail Road Nashik Road - 422101",
      email: "wankhedeyaseen@gmail.com",
      invoicePrefix: "INV-",
      terms: "Thank you for doing business with us.",
    );
    final id = await db.insert('business_settings', defaultProf.toMap());
    return BusinessProfile(
      id: id,
      businessName: defaultProf.businessName,
      phone: defaultProf.phone,
      address: defaultProf.address,
      email: defaultProf.email,
      invoicePrefix: defaultProf.invoicePrefix,
      terms: defaultProf.terms,
    );
  }

  static Future<int> saveProfile(BusinessProfile profile) async {
    final db = await DBHelper.instance.database;
    final res = await db.query('business_settings', limit: 1);
    if (res.isEmpty) {
      return await db.insert('business_settings', profile.toMap());
    } else {
      return await db.update(
        'business_settings',
        profile.toMap(),
        where: 'id = ?',
        whereArgs: [res.first['id']],
      );
    }
  }
}
