import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../database/db_helper.dart';
import '../../models/models.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/party_provider.dart';
import '../../providers/item_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/pdf_invoice_service.dart';
import '../../utils/colors.dart';
import '../../utils/formatters.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final Invoice invoice;
  const InvoiceDetailScreen({Key? key, required this.invoice}) : super(key: key);

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  List<InvoiceItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final db = await DBHelper.instance.database;
    final res = await db.query('invoice_items', where: 'invoice_id = ?', whereArgs: [widget.invoice.id]);
    setState(() {
      _items = res.map((m) => InvoiceItem.fromMap(m)).toList();
      _isLoading = false;
    });
  }

  Future<void> _shareOnWhatsapp() async {
    final pdfBytes = await PdfInvoiceService.generateInvoicePdf(invoice: widget.invoice, items: _items);
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/${widget.invoice.invoiceNumber}.pdf");
    await file.writeAsBytes(pdfBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Dear Customer, here is your invoice ${widget.invoice.invoiceNumber} from BATTERY ZONE. Total: ₹${widget.invoice.totalAmount}. Thank you!",
    );
  }

  Future<void> _printInvoice() async {
    final pdfBytes = await PdfInvoiceService.generateInvoicePdf(invoice: widget.invoice, items: _items);
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }

  Future<void> _deleteInvoice() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Invoice?"),
        content: const Text("Stock and Party Ledger balances will be automatically restored."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dueRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("DELETE"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final db = await DBHelper.instance.database;
    await db.transaction((txn) async {
      // 1. Reverse Stock
      for (var item in _items) {
        if (item.itemId != null) {
          if (widget.invoice.invoiceType == 'SALE') {
            await txn.rawUpdate('UPDATE items SET current_stock = current_stock + ? WHERE id = ?', [item.quantity, item.itemId]);
          } else {
            await txn.rawUpdate('UPDATE items SET current_stock = current_stock - ? WHERE id = ?', [item.quantity, item.itemId]);
          }
        }
      }

      // 2. Reverse Party Ledger
      if (widget.invoice.partyId != null && widget.invoice.balanceAmount > 0) {
        if (widget.invoice.invoiceType == 'SALE') {
          await txn.rawUpdate('UPDATE parties SET current_balance = current_balance - ? WHERE id = ?', [widget.invoice.balanceAmount, widget.invoice.partyId]);
        } else {
          await txn.rawUpdate('UPDATE parties SET current_balance = current_balance + ? WHERE id = ?', [widget.invoice.balanceAmount, widget.invoice.partyId]);
        }
      }

      // 3. Delete items & invoice
      await txn.delete('invoice_items', where: 'invoice_id = ?', whereArgs: [widget.invoice.id]);
      await txn.delete('invoices', where: 'id = ?', whereArgs: [widget.invoice.id]);
    });

    await Provider.of<InvoiceProvider>(context, listen: false).loadInvoices();
    await Provider.of<PartyProvider>(context, listen: false).loadParties();
    await Provider.of<ItemProvider>(context, listen: false).loadItems();
    await Provider.of<DashboardProvider>(context, listen: false).refreshDashboard();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(inv.invoiceType == 'SALE' ? "Sale" : "Purchase", style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.print_outlined, color: Colors.black87), onPressed: _printInvoice),
          IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black87), onPressed: _shareOnWhatsapp),
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.black87), onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Top Invoice No & Date Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Invoice No.", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("Date", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              Text(inv.date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Customer Box (Screenshot 2 Match)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Customer Name *", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(inv.partyName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Billed Items Section Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF90CAF9).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text("Billed Items", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueAccent)),
                            const Spacer(),
                            const Text("Rate exl. tax", style: TextStyle(fontSize: 11, color: Colors.blueAccent)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Line Item Card (Screenshot 2 Match)
                      ...List.generate(_items.length, (idx) {
                        final it = _items[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                                        child: Text("#${idx + 1}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(it.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    ],
                                  ),
                                  Text(AppFormatters.formatCurrency(it.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Item Subtotal", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                  Text("${it.quantity.toStringAsFixed(0)} x ${AppFormatters.formatCurrency(it.price)} = ${AppFormatters.formatCurrency(it.total)}", style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),

                      // Total, Received & Balance (Screenshot 2 Match)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Total Amount", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                Text(AppFormatters.formatCurrency(inv.totalAmount), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.check_box, color: Colors.blue, size: 20),
                                    SizedBox(width: 6),
                                    Text("Received", style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                                Text(AppFormatters.formatCurrency(inv.paidAmount), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Balance Due", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.saleGreen)),
                                Text(AppFormatters.formatCurrency(inv.balanceAmount), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.saleGreen)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Delete & Edit Buttons (Screenshot 2 Match)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                          onPressed: _deleteInvoice,
                          child: const Text("Delete", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: _printInvoice,
                          child: const Text("Print / View PDF", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
