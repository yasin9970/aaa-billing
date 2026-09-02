import 'package:flutter/material.dart';
import '../../database/security_dao.dart';
import '../../utils/colors.dart';
import '../security/pin_screen.dart';
import 'business_profile_screen.dart';
import 'backup_screen.dart';
import 'import_export_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isPinActive = false;

  @override
  void initState() {
    super.initState();
    _checkSecurity();
  }

  Future<void> _checkSecurity() async {
    final active = await SecurityDAO.isPinEnabled();
    setState(() => _isPinActive = active);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text("BUSINESS DETAILS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
          ),
          ListTile(
            leading: const Icon(Icons.store, color: AppColors.primary),
            title: const Text("Shop & Business Profile", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Change Shop Name, Phone, Address & Terms"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessProfileScreen())),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text("APP SECURITY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.lock, color: AppColors.accent),
            title: const Text("4-Digit PIN Lock", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_isPinActive ? "App lock is active" : "Protect your business data"),
            value: _isPinActive,
            onChanged: (val) async {
              if (val) {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const PinScreen(mode: PinMode.setup)));
                _checkSecurity();
              } else {
                await SecurityDAO.setPin('', false);
                _checkSecurity();
              }
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text("DATA & STORAGE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
          ),
          ListTile(
            leading: const Icon(Icons.backup, color: AppColors.saleGreen),
            title: const Text("Backup & Restore", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("1-Click save to phone storage"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.import_export, color: Colors.deepOrange),
            title: const Text("Import / Export (Vyapar Data)", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Export or load parties from CSV"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportExportScreen())),
          ),
        ],
      ),
    );
  }
}
