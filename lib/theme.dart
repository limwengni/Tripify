import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF3B3B3B),
  colorScheme: ColorScheme.light(
    primary: Color(0xFF3B3B3B),
    secondary: Colors.blueAccent,
  ),
  scaffoldBackgroundColor: const Color(0xFFFBFBFB),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFBFBFB), // App bar background color
    iconTheme: IconThemeData(color: Color(0xFF3B3B3B)), // Optional icon color
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Color(0xFF3B3B3B)), // Updated for light mode text color
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.grey[900],
  colorScheme: ColorScheme.dark(
    primary: Colors.grey[900]!,
    secondary: Colors.blueAccent,
  ),
  scaffoldBackgroundColor: const Color(0xFF222222),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF222222), // Dark theme app bar color
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white), // Updated for dark mode text color
  ),
);
