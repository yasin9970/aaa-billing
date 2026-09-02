import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/invoice_provider.dart';
import '../../utils/colors.dart';
import '../../utils/formatters.dart';
import 'create_invoice_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({Key? key}) : super(key: key);

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    Future.microtask(() => Provider.of<InvoiceProvider>(context, listen: false).loadInvoices());
  }

  @override
  Widget build(BuildContext context) {
    final invProv = Provider.of<InvoiceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills & Invoices'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(text: "SALES (${invProv.salesInvoices.length})"),
            Tab(text: "PURCHASES (${invProv.purchaseInvoices.length})"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildInvoiceList(invProv.salesInvoices, 'SALE'),
          _buildInvoiceList(invProv.purchaseInvoices, 'PURCHASE'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _tabCtrl.index == 0 ? AppColors.saleGreen : AppColors.primary,
        icon: const Icon(Icons.add),
        label: Text(_tabCtrl.index == 0 ? "+ Sale Invoice" : "+ Purchase Bill"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateInvoiceScreen(
                invoiceType: _tabCtrl.index == 0 ? 'SALE' : 'PURCHASE',
              ),
            ),
          ).then((_) => invProv.loadInvoices());
        },
      ),
    );
  }

  Widget _buildInvoiceList(List invoices, String type) {
    if (invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text("No $type invoices recorded yet!", style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: invoices.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final inv = invoices[i];
        Color statusColor = AppColors.saleGreen;
        if (inv.paymentStatus == 'UNPAID') statusColor = AppColors.dueRed;
        if (inv.paymentStatus == 'PARTIAL') statusColor = AppColors.warningOrange;

        return ListTile(
          tileColor: Colors.white,
          leading: CircleAvatar(
            backgroundColor: (type == 'SALE' ? AppColors.saleGreen : AppColors.primary).withOpacity(0.1),
            child: Icon(
              type == 'SALE' ? Icons.call_made : Icons.call_received,
              color: type == 'SALE' ? AppColors.saleGreen : AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(inv.partyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text("${inv.invoiceNumber}  •  ${inv.date}", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(AppFormatters.formatCurrency(inv.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(inv.paymentStatus, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
            ],
          ),
        );
      },
    );
  }
}
