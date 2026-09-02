import 'package:flutter/material.dart';
import '../database/item_dao.dart';
import '../models/models.dart';

class ItemProvider with ChangeNotifier {
  List<Item> _items = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Item> get items => _items
      .where((i) =>
          i.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          i.category.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  bool get isLoading => _isLoading;

  int get totalItemCount => _items.length;

  double get totalStockValue {
    double total = 0;
    for (var i in _items) {
      total += (i.currentStock * i.purchasePrice);
    }
    return total;
  }

  int get lowStockCount {
    return _items.where((i) => i.currentStock <= i.minStockAlert).length;
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();
    _items = await ItemDAO.getAllItems();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem({
    required String name,
    required String category,
    required String unit,
    required double purchasePrice,
    required double salePrice,
    required double openingStock,
    required double minStockAlert,
  }) async {
    final newItem = Item(
      name: name,
      category: category.isEmpty ? 'General' : category,
      unit: unit,
      purchasePrice: purchasePrice,
      salePrice: salePrice,
      currentStock: openingStock,
      minStockAlert: minStockAlert,
    );
    await ItemDAO.insertItem(newItem);
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    await ItemDAO.deleteItem(id);
    await loadItems();
  }
}
