import 'package:flutter/material.dart';

class ThemeService with ChangeNotifier {
  ThemeData _themeData;

  ThemeService(this._themeData);

  ThemeData get getTheme => _themeData;

  void toggleTheme() {
    if (_themeData.brightness == Brightness.dark) {
      _themeData = _lightTheme();
    } else {
      _themeData = _darkTheme();
    }
    notifyListeners();
  }

  // light theme
  ThemeData _lightTheme() {
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
        backgroundColor: Colors.deepPurpleAccent,
        iconTheme: IconThemeData(color: Colors.deepPurple),
        titleTextStyle: TextStyle(color: Colors.deepPurple),
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
  ThemeData _darkTheme() {
    return ThemeData.dark().copyWith(
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
        backgroundColor: Color(0xFF333333),
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(color: Colors.white),
        unselectedLabelStyle: TextStyle(color: Colors.white70),
      ),
    );
  }


}

