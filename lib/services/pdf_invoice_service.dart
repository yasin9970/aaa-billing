import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/models.dart';

class PdfInvoiceService {
  static String getAmountInWords(int amount) {
    if (amount == 0) return "Zero Rupees only";

    final units = ["", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten",
      "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen"];
    final tens = ["", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"];

    String convertLessThanOneThousand(int num) {
      String current = "";
      if (num >= 100) {
        current += "${units[num ~/ 100]} Hundred ";
        num %= 100;
      }
      if (num >= 20) {
        current += "${tens[num ~/ 10]} ";
        num %= 10;
      }
      if (num > 0) {
        current += "${units[num]} ";
      }
      return current;
    }

    String result = "";
    if (amount >= 10000000) {
      result += "${convertLessThanOneThousand(amount ~/ 10000000)}Crore ";
      amount %= 10000000;
    }
    if (amount >= 100000) {
      result += "${convertLessThanOneThousand(amount ~/ 100000)}Lakh ";
      amount %= 100000;
    }
    if (amount >= 1000) {
      result += "${convertLessThanOneThousand(amount ~/ 1000)}Thousand ";
      amount %= 1000;
    }
    if (amount > 0) {
      result += convertLessThanOneThousand(amount);
    }

    return "${result.trim()} Rupees only";
  }

  static Future<Uint8List> generateInvoicePdf({
    required Invoice invoice,
    required List<InvoiceItem> items,
    String shopName = "BATTERY ZONE",
    String shopAddress = "Shop No.12 Gurukrupa Vyapari Sankul Dasak Opp. Bharat Petrol Pump\nJail Road Nashik Road - 422101",
    String shopPhone = "9975914610",
    String shopEmail = "wankhedeyaseen@gmail.com",
  }) async {
    final pdf = pw.Document();
    final vyaparCyan = PdfColor.fromHex('#1E88E5');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey500, width: 0.8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Top Centered Title
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 6),
                    child: pw.Text("Tax Invoice", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ),
                ),
                pw.Divider(thickness: 0.5, color: PdfColors.grey400),

                // Shop Header
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 50,
                        height: 50,
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#1A237E'),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Center(
                          child: pw.Text("BZ", style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                      pw.Spacer(),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(shopName, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                          pw.SizedBox(height: 2),
                          pw.Text(shopAddress, textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8)),
                          pw.SizedBox(height: 2),
                          pw.Text("Phone no: $shopPhone  Email: $shopEmail", style: const pw.TextStyle(fontSize: 8)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Bill To & Invoice Details Bar (Exact Vyapar Cyan Header)
                pw.Container(
                  color: vyaparCyan,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Bill To", style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text("Invoice Details", style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),

                // Customer & Invoice Details Values
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(invoice.partyName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text("Invoice No: ${invoice.invoiceNumber}", style: const pw.TextStyle(fontSize: 9)),
                          pw.Text("Date: ${invoice.date}", style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Items Table
                pw.TableHelper.fromTextArray(
                  border: const pw.TableBorder(
                    horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                    verticalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                    top: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
                    bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
                  ),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
                  headerDecoration: pw.BoxDecoration(color: vyaparCyan),
                  cellHeight: 22,
                  cellStyle: const pw.TextStyle(fontSize: 8.5),
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.centerRight,
                    3: pw.Alignment.centerRight,
                    4: pw.Alignment.centerRight,
                  },
                  headers: ['#', 'Item name', 'Quantity', 'Price/ unit', 'Amount'],
                  data: [
                    ...List.generate(items.length, (index) {
                      final it = items[index];
                      return [
                        '${index + 1}',
                        it.itemName,
                        '${it.quantity.toStringAsFixed(0)}',
                        '₹ ${it.price.toStringAsFixed(2)}',
                        '₹ ${it.total.toStringAsFixed(2)}',
                      ];
                    }),
                    ['', 'Total', '${items.fold<double>(0, (s, e) => s + e.quantity).toStringAsFixed(0)}', '', '₹ ${invoice.totalAmount.toStringAsFixed(2)}'],
                  ],
                ),

                // Amounts Box
                pw.Row(
                  children: [
                    pw.Expanded(child: pw.Container()),
                    pw.Container(
                      width: 230,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(left: pw.BorderSide(color: PdfColors.grey400, width: 0.5)),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Container(
                            color: vyaparCyan,
                            width: double.infinity,
                            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            child: pw.Text("Amounts", style: pw.TextStyle(color: PdfColors.white, fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                          ),
                          _calcRow("Sub Total", "₹ ${invoice.subtotal.toStringAsFixed(2)}"),
                          _calcRow("Total", "₹ ${invoice.totalAmount.toStringAsFixed(2)}", isBold: true),
                          _calcRow("Received", "₹ ${invoice.paidAmount.toStringAsFixed(2)}"),
                          _calcRow("Balance", "₹ ${invoice.balanceAmount.toStringAsFixed(2)}", isBold: true),
                        ],
                      ),
                    ),
                  ],
                ),

                // Amount In Words Bar
                pw.Container(
                  color: vyaparCyan,
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: pw.Text("Invoice Amount In Words", style: pw.TextStyle(color: PdfColors.white, fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: pw.Text(getAmountInWords(invoice.totalAmount.toInt()), style: const pw.TextStyle(fontSize: 8.5)),
                ),

                // Terms & Authorized Signatory Block
                pw.Expanded(
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      // Left: Terms
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              color: vyaparCyan,
                              width: double.infinity,
                              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              child: pw.Text("Terms and conditions", style: pw.TextStyle(color: PdfColors.white, fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text("Thank you for doing business with us.", style: const pw.TextStyle(fontSize: 8)),
                            ),
                          ],
                        ),
                      ),
                      // Right: Signatory
                      pw.Container(
                        width: 230,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(left: pw.BorderSide(color: PdfColors.grey400, width: 0.5)),
                        ),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(top: 6),
                              child: pw.Text("For: $shopName", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 8),
                              child: pw.Text("Authorized Signatory", style: const pw.TextStyle(fontSize: 8.5)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _calcRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 8, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(fontSize: 8, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }
}
