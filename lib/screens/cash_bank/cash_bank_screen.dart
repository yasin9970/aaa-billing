import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class CashBankScreen extends StatelessWidget {
  const CashBankScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cash & Bank Ledger")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: const ListTile(
              leading: Icon(Icons.wallet, color: AppColors.saleGreen, size: 36),
              title: Text("Cash in Hand", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Physical Cash Balance"),
              trailing: Text("₹ 0.00", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.saleGreen)),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: const ListTile(
              leading: Icon(Icons.account_balance, color: AppColors.accent, size: 36),
              title: Text("Bank Accounts / UPI", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Online & Digital Accounts"),
              trailing: Text("₹ 0.00", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.accent)),
            ),
          ),
        ],
      ),
    );
  }
}
