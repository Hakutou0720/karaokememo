import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(KaraokeMemoApp());
}

class KaraokeMemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final emerald = Color(0xFF009F6B);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'カラオケ メモ',
      theme: ThemeData(
        primaryColor: emerald,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green).copyWith(secondary: emerald),
        appBarTheme: AppBarTheme(
          backgroundColor: emerald,
          foregroundColor: Colors.white,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 26.0),
          bodyMedium: TextStyle(fontSize: 24.0),
          titleLarge: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
