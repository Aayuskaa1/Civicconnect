import 'package:flutter/material.dart';
import 'package:civic_connect/app/theme/my_theme.dart';

/// Compatibility aliases — prefer [MyTheme] in new code.
/// Admin + resident UIs both resolve through these / [MyTheme] tokens.
class AppColors {
  AppColors._();

  static const Color primary = MyTheme.primary;
  static const Color primaryDark = MyTheme.primaryDark;
  static const Color background = MyTheme.background;
  static const Color surface = MyTheme.surface;
  static const Color textDark = MyTheme.textPrimary;
  static const Color textMuted = MyTheme.textSecondary;
  static const Color border = MyTheme.border;
  static const Color success = MyTheme.success;
  static const Color warning = MyTheme.warning;
  static const Color error = MyTheme.error;
  static const Color authPrimary = MyTheme.primary;
  static const Color darkTextPrimary = MyTheme.textPrimaryDark;
}
