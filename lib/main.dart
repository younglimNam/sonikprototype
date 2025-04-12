import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/sales_register_screen.dart';
import 'screens/expense_register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SONIK',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ko', 'KR'),
      home: const HomeScreen(),
      routes: {
        '/salesRegister': (context) {
          return const SalesRegisterScreen();
        },
        '/expense-register': (context) => const ExpenseRegisterScreen(),
        '/stats': (context) =>
            const Placeholder(), // TODO: Implement StatsScreen
        '/settings': (context) =>
            const Placeholder(), // TODO: Implement SettingsScreen
        '/notifications': (context) =>
            const Placeholder(), // TODO: Implement NotificationsScreen
      },
    );
  }
}
