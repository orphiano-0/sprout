import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.grey.shade900,
    primary: Colors.grey.shade700,    // Subtle contrast for buttons/tiles
    secondary: Colors.teal.shade400,  
    tertiary: const Color.fromARGB(255, 105, 105, 105),// Accent color for vibrancy
    inversePrimary: Colors.grey.shade200,
  ),
  cardColor: Colors.grey.shade800, // Darker card color for depth
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w400, // Regular weight for body text
      color: Colors.grey[300],
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w200, // Extra Light for secondary body text
      color: Colors.grey[300],
    ),
    headlineLarge: const TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w700, // Bold weight for headlines
      color: Colors.white,
    ),
    headlineMedium: const TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600, // Semi-bold for other headlines
      color: Colors.white,
    ),
  ).apply(
    bodyColor: Colors.grey[300], // Default color for text
    displayColor: Colors.white,  // Default color for headings
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.grey.shade700,
      shadowColor: Colors.black.withOpacity(0.1),
    ),
  ),
);
