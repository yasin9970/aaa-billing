import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../utils/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Future<void> _createLocalBackup(BuildContext context) async {
    try {
      final dbPath = await getDatabasesPath();
      final sourcePath = join(dbPath, 'aaa_billing.db');

      // Backup to internal storage folder
      final backupDir = Directory('/storage/emulated/0/Download/AAA_Billing_Backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final targetPath = "${backupDir.path}/Backup_$timestamp.db";

      final File sourceFile = File(sourcePath);
      await sourceFile.copy(targetPath);

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Backup Successful!"),
          content: Text("Backup saved at:\n$targetPath"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Backup notice: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings & Backup")),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text("DATA BACKUP & RESTORE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
          ),
          ListTile(
            leading: const Icon(Icons.backup, color: AppColors.saleGreen),
            title: const Text("Create Local Backup", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Save full database copy to any folder"),
            onTap: () => _createLocalBackup(context),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text("BUSINESS PROFILE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
          ),
          const ListTile(
            leading: Icon(Icons.storefront, color: AppColors.primary),
            title: Text("Shop / Business Name"),
            subtitle: Text("AAA Billing"),
          ),
          const ListTile(
            leading: Icon(Icons.receipt, color: AppColors.primary),
            title: Text("Invoice Prefix"),
            subtitle: Text("INV-"),
          ),
        ],
      ),
    );
  }
}
