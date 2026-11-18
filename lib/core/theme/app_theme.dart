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
      // Cards are lighter than the page so they read as raised without
      // borders or shadows.
      scaffoldBackgroundColor: scheme.surfaceContainerLow,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerLow,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        toolbarHeight: 64,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
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
        fillColor: scheme.surfaceContainerHigh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        // Soft filled fields: no outline until focus or error.
        border: const OutlineInputBorder(
          borderRadius: AppRadius.control,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.control,
          borderSide: BorderSide(color: scheme.surfaceContainerHigh),
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.control,
          borderSide: BorderSide.none,
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
      // Borderless tonal cards on a slightly darker page.
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLowest,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        elevation: 0,
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
        // labelSmall: long Telugu tab names must fit on one line.
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      // Chips: white pills; the selected one is solid brand colour.
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        // Unselected chips are outlined so they read as buttons on white
        // cards too; the selected one is solid with no outline.
        side: WidgetStateBorderSide.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? BorderSide.none
              : BorderSide(color: scheme.outlineVariant),
        ),
        backgroundColor: scheme.surfaceContainerLowest,
        selectedColor: scheme.primary,
        checkmarkColor: scheme.onPrimary,
        // White text on the selected (solid brand) chip, dark otherwise.
        labelStyle: textTheme.labelLarge?.copyWith(
          color: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? scheme.onPrimary
                : scheme.onSurface,
          ),
        ),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: scheme.onPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          minimumSize: const Size(
            AppSizes.minTouchTarget,
            AppSizes.minTouchTarget,
          ),
          shape: const StadiumBorder(),
          side: BorderSide(color: scheme.surfaceContainerLowest, width: 4),
          backgroundColor: scheme.surfaceContainerLowest,
          foregroundColor: scheme.onSurfaceVariant,
          selectedBackgroundColor: scheme.primary,
          selectedForegroundColor: scheme.onPrimary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 4,
        highlightElevation: 6,
        shape: const StadiumBorder(),
        extendedTextStyle: textTheme.titleSmall,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: scheme.outlineVariant,
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
