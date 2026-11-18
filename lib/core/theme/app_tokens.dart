import 'package:flutter/widgets.dart';

/// Spacing on a 4-point scale. Use these instead of literal numbers.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Horizontal page gutter.
  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: lg);
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;

  /// Fully rounded ends for pills and chips.
  static const double pill = 999;

  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius control = BorderRadius.all(Radius.circular(md));
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}

abstract final class AppSizes {
  /// Minimum touch target (PRD 10.4).
  static const double minTouchTarget = 48;

  /// Height of primary and secondary buttons.
  static const double buttonHeight = 52;

  static const double iconSm = 18;
  static const double iconMd = 24;
  static const double iconLg = 48;

  /// Avatar diameter in party lists.
  static const double avatar = 46;

  /// Round quick-action button.
  static const double circleAction = 56;

  /// Widest a form or list column grows on a large screen.
  static const double maxContentWidth = 640;
}

abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
}
