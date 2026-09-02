import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../screens/expenses/expenses_screen.dart';
import '../screens/cash_bank/cash_bank_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/settings_screen.dart';

class VyaparAppDrawer extends StatelessWidget {
  final Function(int)? onTabSelect;
  const VyaparAppDrawer({Key? key, this.onTabSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Business Profile Header (Image 2 Match)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 45, 16, 16),
            color: AppColors.accent,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: const Text("AAA", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "AAA BILLING",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Offline Business Edition",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ],
            ),
          ),

          // Menu List
          _drawerItem(
            icon: Icons.people_outline,
            title: "Parties",
            onTap: () {
              Navigator.pop(context);
              if (onTabSelect != null) onTabSelect!(1);
            },
          ),
          _drawerItem(
            icon: Icons.format_list_bulleted,
            title: "Items & Inventory",
            onTap: () {
              Navigator.pop(context);
              if (onTabSelect != null) onTabSelect!(2);
            },
          ),
          _drawerItem(
            icon: Icons.dashboard_outlined,
            title: "Business Dashboard",
            onTap: () {
              Navigator.pop(context);
              if (onTabSelect != null) onTabSelect!(0);
            },
          ),
          _drawerItem(
            icon: Icons.trending_up,
            title: "Reports & Profit/Loss",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
            },
          ),
          const Divider(height: 1),
          _drawerItem(
            icon: Icons.call_made,
            title: "Sale Invoices",
            onTap: () {
              Navigator.pop(context);
              if (onTabSelect != null) onTabSelect!(3);
            },
          ),
          _drawerItem(
            icon: Icons.call_received,
            title: "Purchase Bills",
            onTap: () {
              Navigator.pop(context);
              if (onTabSelect != null) onTabSelect!(3);
            },
          ),
          _drawerItem(
            icon: Icons.account_balance_wallet_outlined,
            title: "Expenses (Kharcha)",
            trailing: const Icon(Icons.add_circle_outline, size: 20, color: AppColors.dueRed),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen()));
            },
          ),
          _drawerItem(
            icon: Icons.account_balance_outlined,
            title: "Cash & Bank",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CashBankScreen()));
            },
          ),
          const Divider(height: 1),
          _drawerItem(
            icon: Icons.backup_outlined,
            title: "Backup & Restore",
            subtitle: "Unlimited local folder backup",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          _drawerItem(
            icon: Icons.settings_outlined,
            title: "Settings & Company Profile",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "AAA Billing • Non-GST Version 1.0\n100% Offline & Secure",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
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
