import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/db_helper.dart';
import '../../models/models.dart';
import '../../providers/party_provider.dart';
import '../../providers/item_provider.dart';
import '../../utils/colors.dart';

class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({Key? key}) : super(key: key);

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  final _csvInputController = TextEditingController();

  Future<void> _importPartiesCsv() async {
    final text = _csvInputController.text.trim();
    if (text.isEmpty) return;

    final lines = text.split('\n');
    int count = 0;
    final db = await DBHelper.instance.database;

    for (var line in lines) {
      final parts = line.split(',');
      if (parts.length >= 2) {
        final name = parts[0].trim();
        final phone = parts[1].trim();
        final balance = parts.length >= 3 ? (double.tryParse(parts[2].trim()) ?? 0.0) : 0.0;
        final type = parts.length >= 4 ? parts[3].trim().toLowerCase() : 'customer';

        if (name.isNotEmpty && name.toLowerCase() != 'name') {
          await db.insert('parties', {
            'name': name,
            'phone': phone,
            'address': '',
            'type': type == 'supplier' ? 'supplier' : 'customer',
            'opening_balance': balance,
            'current_balance': balance,
            'created_at': DateTime.now().toIso8601String(),
          });
          count++;
        }
      }
    }

    await Provider.of<PartyProvider>(context, listen: false).loadParties();
    _csvInputController.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully imported $count parties!")));
  }

  Future<void> _exportPartiesCsv() async {
    final parties = Provider.of<PartyProvider>(context, listen: false).parties;
    final dir = Directory('/storage/emulated/0/Download');
    final file = File('${dir.path}/AAA_Parties_Export.csv');

    String csvContent = "Name,Phone,CurrentBalance,Type\n";
    for (var p in parties) {
      csvContent += "${p.name},${p.phone},${p.currentBalance},${p.type}\n";
    }

    await file.writeAsString(csvContent);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Exported to: ${file.path}")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Import / Export Data")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Export Data to Excel/CSV", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.saleGreen),
                icon: const Icon(Icons.download),
                label: const Text("Export All Parties to Download Folder"),
                onPressed: _exportPartiesCsv,
              ),
            ),
            const Divider(height: 32),
            const Text("Quick Import Parties (Paste CSV)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            const Text("Format: Name, Phone, Balance, Type (customer/supplier)", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            TextField(
              controller: _csvInputController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: "Ramesh, 9876543210, 500, customer\nSuresh Batteries, 9123456780, 2000, supplier",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                icon: const Icon(Icons.upload),
                label: const Text("Import Now"),
                onPressed: _importPartiesCsv,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
