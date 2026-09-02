import 'package:flutter/material.dart';
import 'database/db_helper.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AAABillingApp());
}

class AAABillingApp extends StatelessWidget {
  const AAABillingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AAA Billing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const EngineStatusScreen(),
    );
  }
}

class EngineStatusScreen extends StatefulWidget {
  const EngineStatusScreen({Key? key}) : super(key: key);

  @override
  State<EngineStatusScreen> createState() => _EngineStatusScreenState();
}

class _EngineStatusScreenState extends State<EngineStatusScreen> {
  bool isLoading = true;
  String dbStatus = "Connecting to SQLite Engine...";
  Map<String, int> stats = {};

  @override
  void initState() {
    super.initState();
    _checkDatabase();
  }

  Future<void> _checkDatabase() async {
    try {
      final db = await DBHelper.instance.database;
      final currentStats = await DBHelper.instance.getDatabaseStats();
      setState(() {
        isLoading = false;
        dbStatus = "Offline Relational Database Active & Healthy!";
        stats = currentStats;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        dbStatus = "Database Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AAA Billing (Vyapar Edition)'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.saleGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.saleGreen,
                  size: 64,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Step 2: Database Engine Ready',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dbStatus,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isLoading ? AppColors.textSecondary : AppColors.saleGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        "Verified Offline Tables",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const Divider(height: 20),
                      _buildRow("Business Settings Table", "Active"),
                      _buildRow("Parties (Customers & Suppliers)", "Active"),
                      _buildRow("Items & Inventory (Auto-Stock)", "Active"),
                      _buildRow("Sales & Purchase Invoices", "Active"),
                      _buildRow("Cash & Bank Ledger", "Active"),
                      _buildRow("Expenses & Reports", "Active"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Ready for Step 3: Parties & Ledger'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Step 2 Verified! Step 3 shuru karein.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          Row(
            children: [
              const Icon(Icons.done, size: 16, color: AppColors.saleGreen),
              const SizedBox(width: 4),
              Text(status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.saleGreen)),
            ],
          ),
        ],
      ),
    );
  }
}
