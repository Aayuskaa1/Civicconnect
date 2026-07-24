import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:civic_connect/app/theme/app_typography.dart';

/// CivicConnect — modern government-grade design system.
/// Trust, accessibility, professionalism (Material 3).
class MyTheme {
  MyTheme._();

  // ── Brand — teal system tuned for background #B3D9D9 ─────────────────────
  /// Primary accent — buttons, links, active states (deep teal).
  static const Color primary = Color(0xFF0F6B66);
  static const Color primaryDark = Color(0xFF0A524E);
  /// Soft teal wash for chips, icon wells, selected states.
  static const Color primaryLight = Color(0xFFD9EEEE);
  static const Color secondary = Color(0xFF2A9D8F);

  // ── Light surfaces ───────────────────────────────────────────────────────
  /// Main app / page background.
  static const Color background = Color(0xFFB3D9D9);
  /// Cards, panels, modals.
  static const Color surface = Color(0xFFFFFFFF);
  /// Soft fill for inputs / elevated chips on teal pages.
  static const Color surfaceElevatedLight = Color(0xFFE4F2F2);

  // ── Dark surfaces (same teal brand) ──────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F2A28);
  static const Color surfaceDark = Color(0xFF1A3D3A);
  static const Color surfaceElevatedDark = Color(0xFF2A5552);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A3D3A);
  static const Color textSecondary = Color(0xFF5A7A77);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textPrimaryDark = Color(0xFFE8F6F5);
  static const Color textSecondaryDark = Color(0xFFA8C5C3);

  // ── Borders ──────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFC5DCDC);
  static const Color borderDark = Color(0xFF2A5552);

  // ── Status ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF15803D);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = primary;

  // ── Shadow base (tint only; use with alpha) ──────────────────────────────
  static const Color shadow = Color(0xFF1A3D3A);

  // ── Compat aliases (existing screens) ────────────────────────────────────
  static const Color brandBlue = primary;
  static const Color primaryBlue = primaryDark;
  static const Color accentOrange = warning;
  static const Color darkBackground = background;
  static const Color darkNavy = surface;
  static const Color surfaceElevated = surfaceElevatedLight;
  static const Color hairline = border;
  static const Color heroGradient = primaryLight;
  static const Color disabled = Color(0xFF9BBFBF);
  static const Color mutedText = textSecondary;
  static const Color softBody = textSecondary;
  static const Color textOnLight = textPrimary;
  static const Color lightBg = Color(0xFFE4F2F2);
  /// Pending / open — amber.
  static const Color statusPending = warning;
  /// In progress — primary teal.
  static const Color statusActive = primary;
  static const Color statusResolved = success;
  static const Color statusError = error;
  static const Color statusInfo = info;
  static const Color onBrand = textOnPrimary;

  // ── Layout tokens ────────────────────────────────────────────────────────
  static const double radiusSm = 12;
  static const double radiusMd = 14;
  static const double radiusLg = 16;
  static const double space = 8;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: shadow.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadowDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static ThemeData get themeData => lightTheme;
  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? backgroundDark : background;
    final surf = isDark ? surfaceDark : surface;
    final elevated = isDark ? surfaceElevatedDark : surfaceElevatedLight;
    final onSurf = isDark ? textPrimaryDark : textPrimary;
    final muted = isDark ? textSecondaryDark : textSecondary;
    final line = isDark ? borderDark : border;
    final textTheme = AppTypography.textTheme(onSurf, muted);

    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: textOnPrimary,
      primaryContainer: isDark ? primaryDark : primaryLight,
      onPrimaryContainer: isDark ? primaryLight : primaryDark,
      secondary: secondary,
      onSecondary: textOnPrimary,
      secondaryContainer: isDark ? surfaceElevatedDark : primaryLight,
      onSecondaryContainer: onSurf,
      surface: surf,
      onSurface: onSurf,
      error: error,
      onError: textOnPrimary,
      outline: line,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      dividerColor: line,
      appBarTheme: AppBarTheme(
        backgroundColor: surf,
        foregroundColor: onSurf,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.title(onSurf),
      ),
      cardTheme: CardThemeData(
        color: surf,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: line),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: elevated,
        selectedColor: primaryLight.withValues(alpha: isDark ? 0.25 : 1),
        disabledColor: disabled,
        labelStyle: AppTypography.caption(muted),
        secondaryLabelStyle: AppTypography.caption(textOnPrimary).copyWith(
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(color: line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        showCheckmark: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? elevated : lightBg,
        hintStyle: AppTypography.body(muted),
        labelStyle: AppTypography.body(muted),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textOnPrimary,
          disabledBackgroundColor: disabled,
          disabledForegroundColor: muted,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: AppTypography.button(textOnPrimary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: surf,
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.4),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: AppTypography.button(primary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: AppTypography.button(primary),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: textOnPrimary,
        elevation: 2,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surf,
        selectedItemColor: primary,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.navLabel(primary),
        unselectedLabelStyle: AppTypography.navLabel(muted),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surf,
        indicatorColor: primaryLight.withValues(alpha: isDark ? 0.2 : 1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.navLabel(primary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            );
          }
          return AppTypography.navLabel(muted).copyWith(fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary);
          }
          return IconThemeData(color: muted);
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? surfaceElevatedDark : textPrimary,
        contentTextStyle: AppTypography.body(textOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
      ),
      iconTheme: const IconThemeData(color: primary),
    );
  }
}
