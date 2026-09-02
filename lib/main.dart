import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/party_provider.dart';
import 'providers/item_provider.dart';
import 'screens/home_nav_screen.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AAABillingApp());
}

class AAABillingApp extends StatelessWidget {
  const AAABillingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PartyProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
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
        home: const HomeNavScreen(),
      ),
    );
  }
}
