import 'package:flutter/material.dart';
import '../database/business_dao.dart';
import '../models/models.dart';

class BusinessProvider with ChangeNotifier {
  BusinessProfile _profile = BusinessProfile(
    businessName: "BATTERY ZONE",
    phone: "9975914610",
    address: "Nashik Road - 422101",
    email: "wankhedeyaseen@gmail.com",
  );

  BusinessProfile get profile => _profile;

  Future<void> loadProfile() async {
    _profile = await BusinessDAO.getProfile();
    notifyListeners();
  }

  Future<void> updateProfile(BusinessProfile newProfile) async {
    await BusinessDAO.saveProfile(newProfile);
    _profile = newProfile;
    notifyListeners();
  }
}
