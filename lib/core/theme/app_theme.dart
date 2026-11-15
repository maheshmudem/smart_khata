import 'package:flutter/material.dart';
import 'package:smart_khata/core/theme/app_colors.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';

/// Material 3 themes for Smart Khata.
abstract final class AppTheme {
  /// Bundled fonts, so text renders the same with no network.
  static const String fontFamily = 'NotoSans';
  static const List<String> fontFamilyFallback = ['NotoSansTelugu'];

  static final ThemeData light = _build(
    AppColors.light,
    AppSemanticColors.light,
  );
  static final ThemeData dark = _build(AppColors.dark, AppSemanticColors.dark);

  static ThemeData _build(ColorScheme scheme, AppSemanticColors semantic) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
    final textTheme = _textTheme(base.textTheme);

    const controlShape = RoundedRectangleBorder(
      borderRadius: AppRadius.control,
    );
    const buttonSize = Size(
      AppSizes.minTouchTarget,
      AppSizes.buttonHeight,
    );
    final buttonText = textTheme.titleMedium;

    return base.copyWith(
      textTheme: textTheme,
      extensions: [semantic],
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          shape: controlShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: controlShape,
          textStyle: buttonText,
          side: BorderSide(color: scheme.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            AppSizes.minTouchTarget,
            AppSizes.minTouchTarget,
          ),
          shape: controlShape,
          textStyle: buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.control,
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.control,
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.control,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.control,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.control,
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        // Telugu error text is longer than English; let it wrap.
        errorMaxLines: 3,
        helperMaxLines: 3,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.xl)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: controlShape,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: AppSpacing.md,
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Slightly taller lines than the Material default: Telugu glyphs have
  /// marks above and below the line that clip at tight heights.
  static TextTheme _textTheme(TextTheme base) {
    TextStyle? tune(TextStyle? style, {FontWeight? weight, double? height}) =>
        style?.copyWith(fontWeight: weight, height: height);

    return base.copyWith(
      displaySmall: tune(base.displaySmall, weight: FontWeight.w700),
      headlineMedium: tune(base.headlineMedium, weight: FontWeight.w700),
      headlineSmall: tune(base.headlineSmall, weight: FontWeight.w600),
      titleLarge: tune(base.titleLarge, weight: FontWeight.w600),
      titleMedium: tune(base.titleMedium, weight: FontWeight.w600),
      titleSmall: tune(base.titleSmall, weight: FontWeight.w600),
      bodyLarge: tune(base.bodyLarge, height: 1.5),
      bodyMedium: tune(base.bodyMedium, height: 1.5),
      bodySmall: tune(base.bodySmall, height: 1.45),
      labelLarge: tune(base.labelLarge, weight: FontWeight.w600),
      labelMedium: tune(base.labelMedium, weight: FontWeight.w500, height: 1.4),
    );
  }

  /// Style for amounts: figures of equal width so columns of money line up.
  static TextStyle? amountStyle(TextStyle? base) => base?.copyWith(
    fontWeight: FontWeight.w700,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
