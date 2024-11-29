import 'package:strive_project/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor:  Color(0xFFF6E4E4),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor:  Color(0xFFF6E4E4),
          secondary:  Color(0xFFFADADD),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor:  Colors.deepPurpleAccent,
          textTheme: ButtonTextTheme.primary,
        ),
        appBarTheme:  AppBarTheme(
          backgroundColor: Colors.white, // AppBar background color
          iconTheme: IconThemeData(color: Colors.black), // Icon color in AppBar
        ),
        bottomNavigationBarTheme:  BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFF8C9D4) , // BottomNavigationBar background color
          selectedItemColor: Colors.deepPurpleAccent, // Selected icon color
          unselectedItemColor: Colors.black54, // Unselected icon color
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: WidgetTree(),
    );
  }
}
