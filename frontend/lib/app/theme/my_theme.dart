import 'package:flutter/material.dart';

class MyTheme {
  MyTheme._();

  static const Color primaryBlue    = Color(0xFF1A56DB);
  static const Color darkNavy       = Color(0xFF001A30);
  static const Color darkBackground = Color(0xFF162031);
  static const Color accentOrange   = Color(0xFFE8A020);
  static const Color lightBg        = Color(0xFFF0F4FF);
  static const Color statusPending  = Color(0xFFF59E0B);
  static const Color statusActive   = Color(0xFF3B82F6);
  static const Color statusResolved = Color(0xFF10B981);
  static const Color civicBlue      = Color(0xFF3D7EBF);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: civicBlue,
        secondary: accentOrange,
        surface: darkNavy,
      ),
      fontFamily: 'MontserratRegular',
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkNavy,
        hintStyle: const TextStyle(color: Color(0xFF6B8FAF), fontFamily: 'MontserratRegular'),
        labelStyle: const TextStyle(color: Color(0xFF6B8FAF), fontFamily: 'MontserratRegular'),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1E293B)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: civicBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: civicBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'MontserratBold',
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: civicBlue,
        unselectedItemColor: Color(0xFF6B8FAF),
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: civicBlue.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: civicBlue, fontWeight: FontWeight.bold, fontFamily: 'MontserratBold', fontSize: 12);
          }
          return const TextStyle(color: Color(0xFF6B8FAF), fontFamily: 'MontserratRegular', fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: civicBlue);
          }
          return const IconThemeData(color: Color(0xFF6B8FAF));
        }),
      ),
    );
  }
}
