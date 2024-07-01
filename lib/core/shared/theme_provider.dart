import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// CONSTANTS HERE
const Color primaryColor = Color(0xFF7B1113);
const Color secondaryColor = Color(0xFF014421);

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  ThemeData get themeData => _isDarkMode ? _darkTheme : _lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  final ThemeData _lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light,
    textTheme: GoogleFonts.robotoTextTheme(),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Colors.white,
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Colors.white,
      shadowColor: Colors.grey,
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(color: primaryColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: Colors.grey[400]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(
          color: Colors.grey,
        ),
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.black,
    ),
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: Colors.white,
    ),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: Colors.white,
    ),
  );

  final ThemeData _darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey[850],
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(),
    // timePickerTheme: const TimePickerThemeData(
    //   backgroundColor: Colors.white,
    // ),
    // datePickerTheme: const DatePickerThemeData(
    //   backgroundColor: Colors.white,
    // ),
  );
}
