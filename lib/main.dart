/// Main - main.dart
/// ================
/// The entry point for the application.
import 'package:flutter/material.dart';
import 'package:stock/screens/groceries_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Groceries',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black
        ),
      ),
      home: const GroceriesPage(),
    );
  }
}