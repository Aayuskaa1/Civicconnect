import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:civic_connect/app/theme/my_theme.dart';

/// CivicConnect typography — Plus Jakarta Sans.
/// Clean, modern, government-grade hierarchy.
class AppTypography {
  AppTypography._();

  static String? get fontFamily => GoogleFonts.plusJakartaSans().fontFamily;

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    required Color color,
    double height = 1.35,
    double letterSpacing = 0,
    FontStyle style = FontStyle.normal,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: style,
    );
  }

  // Brand / display
  static TextStyle display(Color color) => _base(
        size: 32,
        weight: FontWeight.w800,
        color: color,
        height: 1.15,
        letterSpacing: -0.6,
      );

  static TextStyle headline(Color color) => _base(
        size: 24,
        weight: FontWeight.w700,
        color: color,
        height: 1.2,
        letterSpacing: -0.3,
      );

  static TextStyle title(Color color) => _base(
        size: 18,
        weight: FontWeight.w700,
        color: color,
        height: 1.3,
        letterSpacing: -0.2,
      );

  static TextStyle titleSm(Color color) => _base(
        size: 16,
        weight: FontWeight.w700,
        color: color,
        height: 1.3,
      );

  static TextStyle body(Color color) => _base(
        size: 14,
        weight: FontWeight.w500,
        color: color,
        height: 1.5,
      );

  static TextStyle bodySm(Color color) => _base(
        size: 13,
        weight: FontWeight.w500,
        color: color,
        height: 1.45,
      );

  static TextStyle caption(Color color) => _base(
        size: 12,
        weight: FontWeight.w500,
        color: color,
        height: 1.4,
        letterSpacing: 0.1,
      );

  static TextStyle overline(Color color) => _base(
        size: 11,
        weight: FontWeight.w700,
        color: color,
        height: 1.3,
        letterSpacing: 0.8,
      );

  static TextStyle button(Color color) => _base(
        size: 15,
        weight: FontWeight.w700,
        color: color,
        height: 1.2,
        letterSpacing: 0.2,
      );

  static TextStyle navLabel(Color color) => _base(
        size: 10,
        weight: FontWeight.w600,
        color: color,
        height: 1.2,
      );

  /// Full Material text theme for light/dark.
  static TextTheme textTheme(Color onSurface, Color muted) {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return base.copyWith(
      displayLarge: display(onSurface),
      displayMedium: headline(onSurface),
      displaySmall: _base(
        size: 22,
        weight: FontWeight.w700,
        color: onSurface,
        letterSpacing: -0.25,
      ),
      headlineLarge: headline(onSurface),
      headlineMedium: title(onSurface),
      headlineSmall: titleSm(onSurface),
      titleLarge: title(onSurface),
      titleMedium: titleSm(onSurface),
      titleSmall: _base(
        size: 14,
        weight: FontWeight.w700,
        color: onSurface,
      ),
      bodyLarge: _base(
        size: 16,
        weight: FontWeight.w500,
        color: onSurface,
        height: 1.5,
      ),
      bodyMedium: body(onSurface),
      bodySmall: bodySm(muted),
      labelLarge: button(onSurface),
      labelMedium: caption(muted),
      labelSmall: overline(muted),
    );
  }

  /// Convenience for screens still using TextStyle(...) manually.
  static TextStyle style({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = MyTheme.textPrimary,
    double height = 1.4,
    double letterSpacing = 0,
    FontStyle fontStyle = FontStyle.normal,
  }) =>
      _base(
        size: size,
        weight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        style: fontStyle,
      );
}
