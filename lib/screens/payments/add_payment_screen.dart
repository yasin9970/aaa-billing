import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/payment_dao.dart';
import '../../models/models.dart';
import '../../providers/party_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../utils/colors.dart';
import '../../utils/formatters.dart';

class AddPaymentScreen extends StatefulWidget {
  final String paymentType; // 'PAYMENT_IN' or 'PAYMENT_OUT'
  const AddPaymentScreen({Key? key, required this.paymentType}) : super(key: key);

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  Party? _selectedParty;
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _mode = 'CASH';

  @override
  Widget build(BuildContext context) {
    final partyProv = Provider.of<PartyProvider>(context);
    final isIn = widget.paymentType == 'PAYMENT_IN';
    final parties = isIn ? partyProv.customers : partyProv.suppliers;

    return Scaffold(
      appBar: AppBar(
        title: Text(isIn ? "Payment In (Udhaar Jama)" : "Payment Out (Supplier Chukaana)"),
        backgroundColor: isIn ? AppColors.saleGreen : AppColors.dueRed,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<Party>(
              value: _selectedParty,
              decoration: InputDecoration(
                labelText: isIn ? "Select Customer" : "Select Supplier",
                border: const OutlineInputBorder(),
              ),
              items: parties.map((p) => DropdownMenuItem(value: p, child: Text("${p.name} (Bal: ₹${p.currentBalance.abs()})"))).toList(),
              onChanged: (p) => setState(() => _selectedParty = p),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Received Amount",
                prefixText: "₹ ",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _mode,
              decoration: const InputDecoration(labelText: "Payment Mode", border: OutlineInputBorder()),
              items: ['CASH', 'BANK / UPI', 'CHEQUE'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (m) => setState(() => _mode = m!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: "Notes / Description", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: isIn ? AppColors.saleGreen : AppColors.dueRed),
                child: const Text("RECORD PAYMENT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: () async {
                  if (_selectedParty == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a party!")));
                    return;
                  }
                  final amt = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
                  if (amt <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid amount!")));
                    return;
                  }

                  await PaymentDAO.addPayment(
                    partyId: _selectedParty!.id!,
                    partyName: _selectedParty!.name,
                    amount: amt,
                    paymentType: widget.paymentType,
                    paymentMode: _mode,
                    date: AppFormatters.formatDate(DateTime.now()),
                    notes: _notesCtrl.text.trim(),
                  );

                  await Provider.of<PartyProvider>(context, listen: false).loadParties();
                  await Provider.of<DashboardProvider>(context, listen: false).refreshDashboard();

                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
