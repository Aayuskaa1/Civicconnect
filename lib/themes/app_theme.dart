import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  const Color primaryWarm = Color(0XFF501600); // Your signature tone

  return ThemeData(
    useMaterial3: true,
    fontFamily: "Montserrat Regular",
    scaffoldBackgroundColor: Colors.grey[200],
    
    // Establishing the warm palette
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryWarm,
      primary: primaryWarm,
      surface: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.amber,
      elevation: 4,
      shadowColor: Colors.black,
      titleTextStyle: TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontFamily: "Montserrat Bold",
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryWarm,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold, 
          fontFamily: "Montserrat Bold"
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(fontFamily: "Montserrat Regular", color: Colors.cyan),
      prefixIconColor: Colors.grey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: primaryWarm, width: 1.5),
      ),
    ),
  );
}