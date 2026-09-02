import 'package:flutter/material.dart';
import '../database/party_dao.dart';
import '../models/models.dart';

class PartyProvider with ChangeNotifier {
  List<Party> _parties = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Party> get parties => _parties;
  bool get isLoading => _isLoading;

  List<Party> get customers => _parties
      .where((p) => p.type == 'customer' && p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  List<Party> get suppliers => _parties
      .where((p) => p.type == 'supplier' && p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  double get totalReceivable {
    double total = 0;
    for (var p in _parties) {
      if (p.currentBalance > 0) total += p.currentBalance;
    }
    return total;
  }

  double get totalPayable {
    double total = 0;
    for (var p in _parties) {
      if (p.currentBalance < 0) total += p.currentBalance.abs();
    }
    return total;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadParties() async {
    _isLoading = true;
    notifyListeners();
    _parties = await PartyDAO.getAllParties();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addParty({
    required String name,
    required String phone,
    required String address,
    required String type,
    required double openingBalance,
    required bool isReceivable,
  }) async {
    final double finalBalance = isReceivable ? openingBalance : -openingBalance;
    final newParty = Party(
      name: name,
      phone: phone,
      address: address,
      type: type,
      openingBalance: finalBalance,
      currentBalance: finalBalance,
      createdAt: DateTime.now().toIso8601String(),
    );
    await PartyDAO.insertParty(newParty);
    await loadParties();
  }

  Future<void> deleteParty(int id) async {
    await PartyDAO.deleteParty(id);
    await loadParties();
  }
}
