import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../utils/colors.dart';
import '../../utils/formatters.dart';
import '../sales/create_invoice_screen.dart';
import '../parties/add_party_screen.dart';
import '../inventory/add_item_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<DashboardProvider>(context, listen: false).refreshDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final dash = Provider.of<DashboardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AAA Billing Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => dash.refreshDashboard(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => dash.refreshDashboard(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Sale & Purchase
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard("TOTAL SALES", dash.totalSales, AppColors.saleGreen, Icons.trending_up),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard("TOTAL PURCHASES", dash.totalPurchases, AppColors.purchaseBlue, Icons.shopping_bag_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row 2: To Receive & To Pay
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard("TO RECEIVE (LENA)", dash.receivable, AppColors.saleGreen, Icons.arrow_downward),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard("TO PAY (DENA)", dash.payable, AppColors.dueRed, Icons.arrow_upward),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick Actions Title
              const Text("QUICK ACTIONS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 10),

              // 4 Quick Buttons
              Row(
                children: [
                  _buildActionBtn("Sale", Icons.add_shopping_cart, AppColors.saleGreen, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateInvoiceScreen(invoiceType: 'SALE')))
                        .then((_) => dash.refreshDashboard());
                  }),
                  const SizedBox(width: 8),
                  _buildActionBtn("Purchase", Icons.shopping_cart_checkout, AppColors.primary, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateInvoiceScreen(invoiceType: 'PURCHASE')))
                        .then((_) => dash.refreshDashboard());
                  }),
                  const SizedBox(width: 8),
                  _buildActionBtn("Add Party", Icons.person_add_alt_1, Colors.purple, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPartyScreen()))
                        .then((_) => dash.refreshDashboard());
                  }),
                  const SizedBox(width: 8),
                  _buildActionBtn("Add Item", Icons.playlist_add, Colors.teal, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddItemScreen()))
                        .then((_) => dash.refreshDashboard());
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Transactions
              const Text("RECENT TRANSACTIONS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 10),

              dash.recentTransactions.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Text("No transactions recorded yet.", style: TextStyle(color: Colors.grey.shade500)),
                    )
                  : Column(
                      children: dash.recentTransactions.map((tx) {
                        final isSale = tx.invoiceType == 'SALE';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: (isSale ? AppColors.saleGreen : AppColors.primary).withOpacity(0.1),
                              child: Icon(isSale ? Icons.arrow_outward : Icons.arrow_downward, color: isSale ? AppColors.saleGreen : AppColors.primary),
                            ),
                            title: Text(tx.partyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text("${tx.invoiceNumber}  •  ${tx.date}"),
                            trailing: Text(
                              AppFormatters.formatCurrency(tx.totalAmount),
                              style: TextStyle(fontWeight: FontWeight.bold, color: isSale ? AppColors.saleGreen : AppColors.primary, fontSize: 14),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(AppFormatters.formatCurrency(amount), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
