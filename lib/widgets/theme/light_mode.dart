import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Colors.grey.shade100, // Lighter for more contrast
    primary: Colors.grey.shade200,    // Adjusted for tiles/buttons
    secondary: Colors.teal.shade600,  // Accent for interactivity
    tertiary: const Color.fromARGB(255, 105, 105, 105),
    inversePrimary: const Color.fromARGB(255, 28, 27, 27),
  ),
  cardColor: Colors.white, // Card background for contrast
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w400, // Regular weight for body text (default)
      color: Colors.grey[800],
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w400, // Regular weight for body text (default)
      color: Colors.grey[800],
    ),
    headlineLarge: const TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w700, // Bold weight for headlines
      color: Colors.black,
    ),
    headlineMedium: const TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600, // Semi-bold for other headlines
      color: Colors.black,
    ),
  ).apply(
    bodyColor: Colors.grey[800], // Default color for body text in light mode
    displayColor: Colors.black,  // Default color for headings in light mode
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 48, 47, 47),
      shadowColor: Colors.black.withOpacity(0.2),
    ),
  ),
);
