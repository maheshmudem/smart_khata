import 'package:flutter/material.dart';

/// Brand colours: deep green with a warm amber accent.
abstract final class AppColors {
  static const Color brandGreen = Color(0xFF1B6B4A);
  static const Color brandAmber = Color(0xFFF2A516);

  /// Light scheme: generated from the green seed, with the tertiary roles
  /// replaced by the amber family.
  static final ColorScheme light =
      ColorScheme.fromSeed(
        seedColor: brandGreen,
      ).copyWith(
        primary: brandGreen,
        tertiary: const Color(0xFF7A5700),
        onTertiary: const Color(0xFFFFFFFF),
        tertiaryContainer: const Color(0xFFFFDEA6),
        onTertiaryContainer: const Color(0xFF271900),
      );

  static final ColorScheme dark =
      ColorScheme.fromSeed(
        seedColor: brandGreen,
        brightness: Brightness.dark,
      ).copyWith(
        tertiary: const Color(0xFFF5BE48),
        onTertiary: const Color(0xFF412D00),
        tertiaryContainer: const Color(0xFF5D4200),
        onTertiaryContainer: const Color(0xFFFFDEA6),
      );
}

/// Colours with a money meaning. They support the direction label and icon;
/// they never replace them (PRD 10.4: not by colour alone).
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.receivable,
    required this.payable,
    required this.advance,
    required this.warning,
    required this.neutral,
  });

  /// Money coming to the shop: a customer owes.
  final Color receivable;

  /// Money the shop must pay: owed to a supplier.
  final Color payable;

  /// An advance held either way.
  final Color advance;

  /// Needs attention: overdue, backup needed, over credit limit.
  final Color warning;

  /// Settled or no direction.
  final Color neutral;

  static const AppSemanticColors light = AppSemanticColors(
    receivable: Color(0xFF1B6B4A),
    payable: Color(0xFFB3261E),
    advance: Color(0xFF1F5FA8),
    warning: Color(0xFF7A5700),
    neutral: Color(0xFF49524C),
  );

  static const AppSemanticColors dark = AppSemanticColors(
    receivable: Color(0xFF8AD6AE),
    payable: Color(0xFFFFB4AB),
    advance: Color(0xFFA6C8FF),
    warning: Color(0xFFF5BE48),
    neutral: Color(0xFFC0C9C1),
  );

  @override
  AppSemanticColors copyWith({
    Color? receivable,
    Color? payable,
    Color? advance,
    Color? warning,
    Color? neutral,
  }) => AppSemanticColors(
    receivable: receivable ?? this.receivable,
    payable: payable ?? this.payable,
    advance: advance ?? this.advance,
    warning: warning ?? this.warning,
    neutral: neutral ?? this.neutral,
  );

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      receivable: Color.lerp(receivable, other.receivable, t)!,
      payable: Color.lerp(payable, other.payable, t)!,
      advance: Color.lerp(advance, other.advance, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
    );
  }
}

extension AppSemanticColorsX on BuildContext {
  /// The money-meaning colours of the current theme.
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>()!;
}
