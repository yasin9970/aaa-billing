import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/party_provider.dart';
import '../../providers/item_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../utils/colors.dart';
import '../../utils/formatters.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final String invoiceType; // 'SALE' or 'PURCHASE'
  const CreateInvoiceScreen({Key? key, required this.invoiceType}) : super(key: key);

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  Party? _selectedParty;
  final List<InvoiceItem> _cartItems = [];
  final _discountController = TextEditingController(text: '0');
  final _paidController = TextEditingController();
  String _paymentMode = 'CASH';

  double get _subtotal => _cartItems.fold(0.0, (sum, i) => sum + i.total);
  double get _discount => double.tryParse(_discountController.text.trim()) ?? 0.0;
  double get _totalAmount => (_subtotal - _discount) > 0 ? (_subtotal - _discount) : 0.0;
  double get _paidAmount => double.tryParse(_paidController.text.trim()) ?? _totalAmount;
  double get _balanceAmount => (_totalAmount - _paidAmount) > 0 ? (_totalAmount - _paidAmount) : 0.0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<PartyProvider>(context, listen: false).loadParties();
      Provider.of<ItemProvider>(context, listen: false).loadItems();
    });
  }

  void _addItemToCart(Item item) {
    final defaultPrice = widget.invoiceType == 'SALE' ? item.salePrice : item.purchasePrice;
    showDialog(
      context: context,
      builder: (ctx) {
        final qtyCtrl = TextEditingController(text: '1');
        final rateCtrl = TextEditingController(text: defaultPrice.toStringAsFixed(2));

        return AlertDialog(
          title: Text("Add ${item.name}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Quantity (${item.unit})", border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: rateCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price per Unit", prefixText: "₹ ", border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                final q = double.tryParse(qtyCtrl.text.trim()) ?? 1.0;
                final r = double.tryParse(rateCtrl.text.trim()) ?? defaultPrice;
                setState(() {
                  _cartItems.add(InvoiceItem(
                    itemId: item.id,
                    itemName: item.name,
                    unit: item.unit,
                    price: r,
                    quantity: q,
                    total: q * r,
                  ));
                  _paidController.text = _totalAmount.toStringAsFixed(2);
                });
                Navigator.pop(ctx);
              },
              child: const Text("ADD"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final partyProv = Provider.of<PartyProvider>(context);
    final itemProv = Provider.of<ItemProvider>(context);
    final isSale = widget.invoiceType == 'SALE';
    final parties = isSale ? partyProv.customers : partyProv.suppliers;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSale ? 'New Sales Invoice' : 'New Purchase Bill'),
        backgroundColor: isSale ? AppColors.saleGreen : AppColors.primary,
      ),
      body: Column(
        children: [
          // Party Selector
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: DropdownButtonFormField<Party>(
              value: _selectedParty,
              decoration: InputDecoration(
                labelText: isSale ? 'Select Customer *' : 'Select Supplier *',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: parties.map((p) => DropdownMenuItem(value: p, child: Text("${p.name} (${p.phone})"))).toList(),
              onChanged: (p) => setState(() => _selectedParty = p),
            ),
          ),

          // Cart Items List
          Expanded(
            child: _cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_shopping_cart, size: 50, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text("No items added yet. Click '+ Add Product' below.", style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _cartItems.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final c = _cartItems[i];
                      return ListTile(
                        tileColor: Colors.white,
                        title: Text(c.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text("${c.quantity.toStringAsFixed(0)} ${c.unit} x ${AppFormatters.formatCurrency(c.price)}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(AppFormatters.formatCurrency(c.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.dueRed, size: 20),
                              onPressed: () {
                                setState(() {
                                  _cartItems.removeAt(i);
                                  _paidController.text = _totalAmount.toStringAsFixed(2);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Total and Payment Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, -2))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Subtotal:", style: TextStyle(color: AppColors.textSecondary)),
                    Text(AppFormatters.formatCurrency(_subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text("Discount (₹):", style: TextStyle(color: AppColors.textSecondary)),
                    const Spacer(),
                    SizedBox(
                      width: 90,
                      height: 35,
                      child: TextField(
                        controller: _discountController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.end,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0), border: OutlineInputBorder()),
                        onChanged: (_) => setState(() {
                          _paidController.text = _totalAmount.toStringAsFixed(2);
                        }),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Grand Total:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(AppFormatters.formatCurrency(_totalAmount), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSale ? AppColors.saleGreen : AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _paidController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Paid Amount",
                          prefixText: "₹ ",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Balance Due", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            Text(AppFormatters.formatCurrency(_balanceAmount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.dueRed)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("Add Product"),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (bCtx) => ListView.builder(
                              itemCount: itemProv.items.length,
                              itemBuilder: (ctx, i) {
                                final it = itemProv.items[i];
                                return ListTile(
                                  title: Text(it.name),
                                  subtitle: Text("Stock: ${it.currentStock} ${it.unit}  •  Price: ₹${isSale ? it.salePrice : it.purchasePrice}"),
                                  onTap: () {
                                    Navigator.pop(bCtx);
                                    _addItemToCart(it);
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSale ? AppColors.saleGreen : AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("SAVE INVOICE", style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          if (_selectedParty == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a party first!")));
                            return;
                          }
                          if (_cartItems.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add at least one product!")));
                            return;
                          }

                          final now = DateTime.now();
                          final invNum = "${widget.invoiceType[0]}INV-${now.millisecondsSinceEpoch.toString().substring(7)}";
                          String status = 'PAID';
                          if (_balanceAmount > 0 && _paidAmount > 0) status = 'PARTIAL';
                          if (_paidAmount == 0) status = 'UNPAID';

                          final newInvoice = Invoice(
                            invoiceNumber: invNum,
                            invoiceType: widget.invoiceType,
                            partyId: _selectedParty!.id,
                            partyName: _selectedParty!.name,
                            date: AppFormatters.formatDate(now),
                            subtotal: _subtotal,
                            discount: _discount,
                            totalAmount: _totalAmount,
                            paidAmount: _paidAmount,
                            balanceAmount: _balanceAmount,
                            paymentStatus: status,
                            paymentMode: _paymentMode,
                            createdAt: now.toIso8601String(),
                          );

                          await Provider.of<InvoiceProvider>(context, listen: false).createNewInvoice(
                            invoice: newInvoice,
                            items: _cartItems,
                          );

                          await Provider.of<PartyProvider>(context, listen: false).loadParties();
                          await Provider.of<ItemProvider>(context, listen: false).loadItems();
                          await Provider.of<DashboardProvider>(context, listen: false).refreshDashboard();

                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
