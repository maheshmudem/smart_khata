import 'package:flutter/material.dart';

/// Brand colours: one emerald brand on calm neutrals, a slate partner for
/// the supplier side, and amber only for warnings.
///
/// The surface roles are set by hand so the app reads as clean white cards
/// on a soft grey-green page in light mode, and lifted charcoal cards on a
/// near-black page in dark mode. In this app `surfaceContainerLow` is the
/// page and `surfaceContainerLowest` is a card, in both themes.
abstract final class AppColors {
  static const Color brandEmerald = Color(0xFF0B7A55);

  /// Calm slate: the supplier side and secondary accents. Not a second brand
  /// hue, so the app reads as one green brand on neutrals.
  static const Color brandSlate = Color(0xFF34505A);
  static const Color brandAmber = Color(0xFFF59E0B);

  static final ColorScheme light =
      ColorScheme.fromSeed(
        seedColor: brandEmerald,
      ).copyWith(
        primary: brandEmerald,
        onPrimary: const Color(0xFFFFFFFF),
        primaryContainer: const Color(0xFFD1F4E3),
        onPrimaryContainer: const Color(0xFF00402A),
        secondary: brandSlate,
        onSecondary: const Color(0xFFFFFFFF),
        secondaryContainer: const Color(0xFFE3ECEF),
        onSecondaryContainer: const Color(0xFF14282F),
        tertiary: const Color(0xFF8A5300),
        onTertiary: const Color(0xFFFFFFFF),
        tertiaryContainer: const Color(0xFFFFE7BA),
        onTertiaryContainer: const Color(0xFF2B1700),
        surface: const Color(0xFFF3F6F4),
        onSurface: const Color(0xFF0F1A15),
        onSurfaceVariant: const Color(0xFF52615A),
        surfaceContainerLowest: const Color(0xFFFFFFFF),
        surfaceContainerLow: const Color(0xFFF3F6F4),
        surfaceContainer: const Color(0xFFEBF0ED),
        surfaceContainerHigh: const Color(0xFFE5EBE8),
        surfaceContainerHighest: const Color(0xFFDCE3DF),
        outline: const Color(0xFF85928C),
        outlineVariant: const Color(0xFFD6DEDA),
        error: const Color(0xFFC62828),
        errorContainer: const Color(0xFFFFE1DE),
        onErrorContainer: const Color(0xFF5F0A0A),
      );

  static final ColorScheme dark =
      ColorScheme.fromSeed(
        seedColor: brandEmerald,
        brightness: Brightness.dark,
      ).copyWith(
        primary: const Color(0xFF4FD6A3),
        onPrimary: const Color(0xFF00382A),
        primaryContainer: const Color(0xFF0E4D38),
        onPrimaryContainer: const Color(0xFFBDF5DC),
        secondary: const Color(0xFFA9C6D0),
        onSecondary: const Color(0xFF14282F),
        secondaryContainer: const Color(0xFF283C43),
        onSecondaryContainer: const Color(0xFFE3ECEF),
        tertiary: const Color(0xFFF7C35C),
        onTertiary: const Color(0xFF412D00),
        tertiaryContainer: const Color(0xFF5D4200),
        onTertiaryContainer: const Color(0xFFFFE7BA),
        surface: const Color(0xFF0D1311),
        onSurface: const Color(0xFFE6EDE9),
        onSurfaceVariant: const Color(0xFFB0BDB6),
        surfaceContainerLowest: const Color(0xFF18211E),
        surfaceContainerLow: const Color(0xFF0D1311),
        surfaceContainer: const Color(0xFF1C2622),
        surfaceContainerHigh: const Color(0xFF232E2A),
        surfaceContainerHighest: const Color(0xFF2C3833),
        outline: const Color(0xFF7D8A84),
        outlineVariant: const Color(0xFF34403B),
      );
}

/// Gradients for hero areas. Text on them is always white; every stop keeps
/// white text above WCAG AA (contrast test).
abstract final class AppGradients {
  /// Customer side and the Home header: emerald deepening to forest.
  static const LinearGradient customers = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B7A55), Color(0xFF065A44), Color(0xFF07473A)],
  );

  /// Supplier side: deep slate, so the two sides never look alike without
  /// adding a second brand colour.
  static const LinearGradient suppliers = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3E5E69), Color(0xFF2B454E), Color(0xFF1C3138)],
  );

  /// The raised Quick Add button.
  static const LinearGradient action = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0E8A61), Color(0xFF065A44)],
  );

  /// Text and icons on a hero gradient.
  static const Color onGradient = Color(0xFFFFFFFF);

  /// Secondary text on a hero gradient.
  static const Color onGradientMuted = Color(0xFFE6F4EE);
}

/// Soft shadows that lift white cards off the page without borders.
abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F0B2A1E),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A0B2A1E),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Under a gradient hero or the Quick Add button.
  static const List<BoxShadow> raised = [
    BoxShadow(
      color: Color(0x330B7A55),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];
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
    receivable: Color(0xFF0B7A55),
    payable: Color(0xFFC62828),
    advance: Color(0xFF3949AB),
    warning: Color(0xFF8A5300),
    neutral: Color(0xFF52615A),
  );

  static const AppSemanticColors dark = AppSemanticColors(
    receivable: Color(0xFF4FD6A3),
    payable: Color(0xFFFF8A80),
    advance: Color(0xFFAAB6FF),
    warning: Color(0xFFF7C35C),
    neutral: Color(0xFFB0BDB6),
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
