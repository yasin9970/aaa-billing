import 'package:flutter/material.dart';
import '../database/invoice_dao.dart';
import '../models/models.dart';

class InvoiceProvider with ChangeNotifier {
  List<Invoice> _salesInvoices = [];
  List<Invoice> _purchaseInvoices = [];
  bool _isLoading = false;

  List<Invoice> get salesInvoices => _salesInvoices;
  List<Invoice> get purchaseInvoices => _purchaseInvoices;
  bool get isLoading => _isLoading;

  Future<void> loadInvoices() async {
    _isLoading = true;
    notifyListeners();
    _salesInvoices = await InvoiceDAO.getInvoicesByType('SALE');
    _purchaseInvoices = await InvoiceDAO.getInvoicesByType('PURCHASE');
    _isLoading = false;
    notifyListeners();
  }

  Future<int> createNewInvoice({
    required Invoice invoice,
    required List<InvoiceItem> items,
  }) async {
    final id = await InvoiceDAO.createInvoice(invoice: invoice, items: items);
    await loadInvoices();
    return id;
  }
}
