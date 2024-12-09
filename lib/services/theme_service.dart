import 'package:flutter/material.dart';

class ThemeService with ChangeNotifier {
  ThemeData _themeData;

  // constructor with light mode as default theme
  ThemeService() : _themeData = _lightTheme();

  // get theme
  ThemeData get getTheme => _themeData;

  // toggle between themes
  void toggleTheme() {
    if (_themeData.brightness == Brightness.dark) {
      _themeData = _lightTheme();
    } else {
      _themeData = _darkTheme();
    }
    notifyListeners();
  }

  // switch themes
  void setTheme(String theme) {
    switch (theme) {
      case 'Dark':
        _themeData = _darkTheme();
        break;
      case 'Light':
      default:
        _themeData = _lightTheme();
        break;
    }
    notifyListeners();
  }

  // light theme
  static ThemeData _lightTheme() {
    return ThemeData(
      primaryColor: Color(0xFF171D1E),
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFFF6E4E4),
        secondary: Color(0xFFFADADD),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.deepPurpleAccent,
        textTheme: ButtonTextTheme.primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.blueGrey),
        titleTextStyle: TextStyle(color: Colors.black),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFF8C9D4),
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  // dark theme
  static ThemeData _darkTheme() {
    return ThemeData(
      primaryColor: Color(0xFF171D1E),
      scaffoldBackgroundColor: Color(0xFFB1BBCF),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF1A1A1A),
        secondary: Color(0xFF2F2F2F),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.deepPurple,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(color: Colors.deepPurple),
        unselectedLabelStyle: TextStyle(color: Colors.deepPurple),
      ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
          ),
        )
    );
  }
}
