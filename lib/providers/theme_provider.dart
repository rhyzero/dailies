import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // Load theme preference from SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _isDarkMode = isDarkMode;
    notifyListeners();
  }

  // Save theme preference to SharedPreferences
  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  // Toggle between light and dark mode
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemeToPrefs();
    notifyListeners();
  }

  // Get the current theme
  ThemeData get themeData {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  // Light theme
  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      background: Colors.grey[50]!,
      surface: Colors.white,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      labelStyle: TextStyle(color: Colors.grey[700]),
    ),
  );

  // Dark theme
  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: Color(0xFF121212),
    cardColor: Color(0xFF1E1E1E),
    dividerColor: Colors.white24,
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1A1A1A),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: Color(0xFF1E1E1E),
      elevation: 1,
      shadowColor: Colors.black38,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Color(0xFF2C2C2C),
      filled: true,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[700]!),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[700]!),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue[400]!),
        borderRadius: BorderRadius.circular(8),
      ),
      labelStyle: TextStyle(color: Colors.grey[400]),
    ),
  );
}
