import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../utils/colors.dart';
import '../screens/expenses/expenses_screen.dart';
import '../screens/cash_bank/cash_bank_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/payments/add_payment_screen.dart';

class VyaparAppDrawer extends StatelessWidget {
  final Function(int)? onTabSelect;
  const VyaparAppDrawer({Key? key, this.onTabSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final business = Provider.of<BusinessProvider>(context).profile;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 45, 16, 16),
            color: AppColors.accent,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Text(
                    business.businessName.isNotEmpty ? business.businessName[0].toUpperCase() : "A",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.accent),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.businessName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        business.email.isNotEmpty ? business.email : business.phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white70, size: 18),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  },
                ),
              ],
            ),
          ),
          _drawerItem(icon: Icons.dashboard_outlined, title: "Business Dashboard", onTap: () {
            Navigator.pop(context);
            if (onTabSelect != null) onTabSelect!(0);
          }),
          _drawerItem(icon: Icons.people_outline, title: "Parties (Khata Book)", onTap: () {
            Navigator.pop(context);
            if (onTabSelect != null) onTabSelect!(1);
          }),
          _drawerItem(icon: Icons.format_list_bulleted, title: "Items & Stock", onTap: () {
            Navigator.pop(context);
            if (onTabSelect != null) onTabSelect!(2);
          }),
          _drawerItem(icon: Icons.receipt_long_outlined, title: "Sale & Purchase Bills", onTap: () {
            Navigator.pop(context);
            if (onTabSelect != null) onTabSelect!(3);
          }),
          const Divider(height: 1),
          _drawerItem(
            icon: Icons.call_received,
            title: "Payment In (Udhaar Jama)",
            trailing: const Icon(Icons.add, size: 20, color: AppColors.saleGreen),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPaymentScreen(paymentType: 'PAYMENT_IN')));
            },
          ),
          _drawerItem(
            icon: Icons.call_made,
            title: "Payment Out (Supplier Chukaana)",
            trailing: const Icon(Icons.add, size: 20, color: AppColors.dueRed),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPaymentScreen(paymentType: 'PAYMENT_OUT')));
            },
          ),
          _drawerItem(icon: Icons.account_balance_wallet_outlined, title: "Expenses (Kharcha)", onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen()));
          }),
          _drawerItem(icon: Icons.trending_up, title: "Reports & Profit/Loss", onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
          }),
          _drawerItem(icon: Icons.account_balance_outlined, title: "Cash & Bank Ledger", onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CashBankScreen()));
          }),
          const Divider(height: 1),
          _drawerItem(icon: Icons.settings_outlined, title: "Settings & Backup", subtitle: "Folder Backup, Import & Profile", onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          }),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("AAA Billing • Non-GST Edition\n100% Offline, Secure & Free", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({required IconData icon, required String title, String? subtitle, Widget? trailing, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)) : null,
      trailing: trailing,
      onTap: onTap,
      dense: true,
    );
  }
}
