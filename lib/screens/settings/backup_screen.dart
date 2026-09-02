import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../utils/colors.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  List<FileSystemEntity> _backupFiles = [];
  final _dir = Directory('/storage/emulated/0/Download/AAA_Billing_Backups');

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    if (await _dir.exists()) {
      setState(() {
        _backupFiles = _dir.listSync().where((f) => f.path.endsWith('.db')).toList();
      });
    }
  }

  Future<void> _createBackup() async {
    try {
      final dbPath = await getDatabasesPath();
      final source = File(p.join(dbPath, 'aaa_billing.db'));

      if (!await _dir.exists()) {
        await _dir.create(recursive: true);
      }

      final targetName = "${_dir.path}/AAA_Backup_${DateTime.now().millisecondsSinceEpoch}.db";
      await source.copy(targetName);
      await _loadBackups();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Backup created: $targetName")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Backup error: $e")));
    }
  }

  Future<void> _restoreBackup(File file) async {
    try {
      final dbPath = await getDatabasesPath();
      final target = File(p.join(dbPath, 'aaa_billing.db'));
      await file.copy(target.path);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Backup Restored! Please restart app.")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Restore error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Backup & Restore")),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                const Text("Backups are saved locally in your phone's Download/AAA_Billing_Backups folder.", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.saleGreen),
                    icon: const Icon(Icons.backup),
                    label: const Text("CREATE NEW BACKUP NOW"),
                    onPressed: _createBackup,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(14),
            child: Align(alignment: Alignment.centerLeft, child: Text("AVAILABLE BACKUPS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
          ),
          Expanded(
            child: _backupFiles.isEmpty
                ? const Center(child: Text("No backups found."))
                : ListView.builder(
                    itemCount: _backupFiles.length,
                    itemBuilder: (ctx, i) {
                      final f = _backupFiles[i];
                      final name = p.basename(f.path);
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.storage, color: AppColors.primary),
                          title: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                            child: const Text("Restore"),
                            onPressed: () => _restoreBackup(File(f.path)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
