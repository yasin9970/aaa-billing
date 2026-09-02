import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/item_provider.dart';
import '../../database/expense_dao.dart';
import '../../utils/colors.dart';
import '../../utils/formatters.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  double _totalExpenses = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final exp = await ExpenseDAO.getTotalExpense();
    setState(() {
      _totalExpenses = exp;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dash = Provider.of<DashboardProvider>(context);
    final itemProv = Provider.of<ItemProvider>(context);

    // Approximate Net Profit = Total Sales - Purchases - Expenses
    final netProfit = dash.totalSales - dash.totalPurchases - _totalExpenses;

    return Scaffold(
      appBar: AppBar(title: const Text("Business Reports")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profit & Loss Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: netProfit >= 0 ? AppColors.saleGreen.withOpacity(0.1) : AppColors.dueRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: netProfit >= 0 ? AppColors.saleGreen : AppColors.dueRed),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("NET PROFIT / LOSS ESTIMATE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Text(
                        AppFormatters.formatCurrency(netProfit),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: netProfit >= 0 ? AppColors.saleGreen : AppColors.dueRed),
                      ),
                      const SizedBox(height: 6),
                      Text("Sales: ₹${dash.totalSales} - Purchases: ₹${dash.totalPurchases} - Expenses: ₹$_totalExpenses", style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.inventory_2, color: AppColors.primary),
                    title: const Text("Stock Valuation", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${itemProv.totalItemCount} Total Products in stock"),
                    trailing: Text(AppFormatters.formatCurrency(itemProv.totalStockValue), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.trending_up, color: AppColors.saleGreen),
                    title: const Text("Total Sales Revenue", style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(AppFormatters.formatCurrency(dash.totalSales), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.saleGreen)),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.shopping_cart, color: AppColors.purchaseBlue),
                    title: const Text("Total Purchases Cost", style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(AppFormatters.formatCurrency(dash.totalPurchases), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.money_off, color: AppColors.dueRed),
                    title: const Text("Total Expenses", style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(AppFormatters.formatCurrency(_totalExpenses), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.dueRed)),
                  ),
                ),
              ],
            ),
    );
  }
}
