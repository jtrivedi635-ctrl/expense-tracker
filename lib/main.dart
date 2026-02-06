import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Ensure you have this import
import 'services/database_service.dart';
import 'providers/expense_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'models/expense_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Hive
  await Hive.initFlutter();

  // 2. Initialize DatabaseService (This opens 'expense_box' and 'settings_box' for you)
  await DatabaseService.init();

  // REMOVED: These lines caused the error because the boxes are already open
  // await Hive.openBox('expense_box');
  // await Hive.openBox('settings_box');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ExpenseProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Expense Tracker',
          // Set system UI overlay style based on theme
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: themeProvider.isDarkMode
                  ? Brightness.light
                  : Brightness.dark,
            ),
          );

          return MaterialApp(
            title: 'Expense Tracker',
            debugShowCheckedModeBanner: false,
            // Use the themes from your ThemeProvider
            theme: themeProvider.currentTheme,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}