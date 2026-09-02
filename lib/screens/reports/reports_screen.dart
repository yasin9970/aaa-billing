import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Business Reports")),
      body: ListView(
        children: [
          _reportTile(context, "Sale Report", "Detailed sales & invoices summary", Icons.trending_up),
          _reportTile(context, "Purchase Report", "Purchases & vendor payments", Icons.shopping_bag_outlined),
          _reportTile(context, "Profit & Loss", "Net profit after deducting expenses", Icons.bar_chart),
          _reportTile(context, "Stock / Inventory Summary", "Current stock quantity & valuation", Icons.inventory_2_outlined),
          _reportTile(context, "Party Statement (Ledger)", "Receivable and payable khata", Icons.people_outline),
        ],
      ),
    );
  }

  Widget _reportTile(BuildContext ctx, String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text("Generating $title...")));
      },
    );
  }
}
