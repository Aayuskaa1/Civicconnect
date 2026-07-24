import 'package:flutter/material.dart';
import 'package:civic_connect/app/theme/my_theme.dart';

/// 8px spacing scale for consistent layout.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;

  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets pageAll = EdgeInsets.all(lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
}

/// Shared card / chip / surface recipes.
class AppDecorations {
  AppDecorations._();

  static BoxDecoration card({Color? color}) => BoxDecoration(
        color: color ?? MyTheme.surface,
        borderRadius: BorderRadius.circular(MyTheme.radiusLg),
        border: Border.all(color: MyTheme.border),
        boxShadow: MyTheme.cardShadow,
      );

  static BoxDecoration cardFlat({Color? color}) => BoxDecoration(
        color: color ?? MyTheme.surface,
        borderRadius: BorderRadius.circular(MyTheme.radiusLg),
        border: Border.all(color: MyTheme.border),
      );

  static BoxDecoration iconWell() => BoxDecoration(
        color: MyTheme.primaryLight,
        borderRadius: BorderRadius.circular(MyTheme.radiusSm),
      );

  static BoxDecoration statusPill(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(MyTheme.radiusSm),
      );
}
