import 'package:flutter/material.dart';
import '../database/invoice_dao.dart';
import '../models/models.dart';

class DashboardProvider with ChangeNotifier {
  double _totalSales = 0.0;
  double _totalPurchases = 0.0;
  double _receivable = 0.0;
  double _payable = 0.0;
  List<Invoice> _recentTransactions = [];
  bool _isLoading = false;

  double get totalSales => _totalSales;
  double get totalPurchases => _totalPurchases;
  double get receivable => _receivable;
  double get payable => _payable;
  List<Invoice> get recentTransactions => _recentTransactions;
  bool get isLoading => _isLoading;

  Future<void> refreshDashboard() async {
    _isLoading = true;
    notifyListeners();

    final metrics = await InvoiceDAO.getDashboardMetrics();
    _totalSales = metrics['totalSales'] ?? 0.0;
    _totalPurchases = metrics['totalPurchases'] ?? 0.0;
    _receivable = metrics['receivable'] ?? 0.0;
    _payable = metrics['payable'] ?? 0.0;
    _recentTransactions = await InvoiceDAO.getRecentTransactions(limit: 10);

    _isLoading = false;
    notifyListeners();
  }
}
