import 'package:flutter/material.dart';
import '../../database/expense_dao.dart';
import '../../utils/colors.dart';
import '../../utils/formatters.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<Map<String, dynamic>> _expenses = [];
  double _total = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await ExpenseDAO.getAllExpenses();
    final total = await ExpenseDAO.getTotalExpense();
    setState(() {
      _expenses = list;
      _total = total;
      _isLoading = false;
    });
  }

  void _showAddExpenseDialog() {
    final catCtrl = TextEditingController(text: 'Shop Rent');
    final amtCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: catCtrl,
              decoration: const InputDecoration(labelText: "Category (Rent, Tea, Salary, Petrol)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amtCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount", prefixText: "₹ ", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: "Notes / Description", border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dueRed),
            onPressed: () async {
              final amt = double.tryParse(amtCtrl.text.trim()) ?? 0.0;
              if (amt > 0) {
                await ExpenseDAO.addExpense(
                  category: catCtrl.text.trim(),
                  amount: amt,
                  paymentMode: 'CASH',
                  date: AppFormatters.formatDate(DateTime.now()),
                  notes: noteCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                _loadData();
              }
            },
            child: const Text("SAVE EXPENSE"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expenses (Kharcha)"),
        backgroundColor: AppColors.dueRed,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.dueRed.withOpacity(0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Expenses", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  AppFormatters.formatCurrency(_total),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.dueRed),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _expenses.isEmpty
                    ? const Center(child: Text("No expenses recorded."))
                    : ListView.separated(
                        itemCount: _expenses.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final e = _expenses[i];
                          return ListTile(
                            tileColor: Colors.white,
                            leading: const CircleAvatar(
                              backgroundColor: Colors.redAccent,
                              child: Icon(Icons.money_off, color: Colors.white, size: 18),
                            ),
                            title: Text(e['category'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text("${e['date']} • ${e['notes'] ?? ''}"),
                            trailing: Text(
                              AppFormatters.formatCurrency((e['amount'] as num).toDouble()),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.dueRed, fontSize: 14),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.dueRed,
        icon: const Icon(Icons.add),
        label: const Text("Add Expense"),
        onPressed: _showAddExpenseDialog,
      ),
    );
  }
}
