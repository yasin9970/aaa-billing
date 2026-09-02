import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/security_dao.dart';
import 'providers/party_provider.dart';
import 'providers/item_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/business_provider.dart';
import 'screens/home_nav_screen.dart';
import 'screens/security/pin_screen.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool hasPin = await SecurityDAO.isPinEnabled();

  runApp(AAABillingApp(hasPin: hasPin));
}

class AAABillingApp extends StatelessWidget {
  final bool hasPin;
  const AAABillingApp({Key? key, required this.hasPin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BusinessProvider()..loadProfile()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => PartyProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
      ],
      child: MaterialApp(
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
        home: hasPin ? const PinScreen(mode: PinMode.unlock) : const HomeNavScreen(),
      ),
    );
  }
}
