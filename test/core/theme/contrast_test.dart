import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/theme/app_colors.dart';
import 'package:smart_khata/core/theme/app_theme.dart';

/// WCAG 2.x contrast ratio between two opaque colours.
double contrastRatio(Color a, Color b) {
  double channel(double c) =>
      c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  double luminance(Color c) =>
      0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
  final la = luminance(a);
  final lb = luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  const aaText = 4.5;

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    final name = theme.brightness.name;
    final scheme = theme.colorScheme;
    final semantic = theme.extension<AppSemanticColors>()!;

    group('$name theme meets WCAG AA for text', () {
      final pairs = <String, (Color, Color)>{
        'onSurface / surface': (scheme.onSurface, scheme.surface),
        'onSurfaceVariant / surface': (scheme.onSurfaceVariant, scheme.surface),
        'onPrimary / primary': (scheme.onPrimary, scheme.primary),
        'primary / surface': (scheme.primary, scheme.surface),
        'onPrimaryContainer / primaryContainer': (
          scheme.onPrimaryContainer,
          scheme.primaryContainer,
        ),
        'onTertiary / tertiary': (scheme.onTertiary, scheme.tertiary),
        'onTertiaryContainer / tertiaryContainer': (
          scheme.onTertiaryContainer,
          scheme.tertiaryContainer,
        ),
        'onErrorContainer / errorContainer': (
          scheme.onErrorContainer,
          scheme.errorContainer,
        ),
        'error / surface': (scheme.error, scheme.surface),
        'receivable / surface': (semantic.receivable, scheme.surface),
        'payable / surface': (semantic.payable, scheme.surface),
        'advance / surface': (semantic.advance, scheme.surface),
        'warning / surface': (semantic.warning, scheme.surface),
        'neutral / surface': (semantic.neutral, scheme.surface),
        // Balance labels also sit on cards.
        'receivable / card': (semantic.receivable, scheme.surfaceContainerLow),
        'payable / card': (semantic.payable, scheme.surfaceContainerLow),
        'advance / card': (semantic.advance, scheme.surfaceContainerLow),
        'warning / card': (semantic.warning, scheme.surfaceContainerLow),
        // Cards are surfaceContainerLowest on a surfaceContainerLow page.
        'onSurface / raised card': (
          scheme.onSurface,
          scheme.surfaceContainerLowest,
        ),
        'onSurfaceVariant / page': (
          scheme.onSurfaceVariant,
          scheme.surfaceContainerLow,
        ),
        'receivable / raised card': (
          semantic.receivable,
          scheme.surfaceContainerLowest,
        ),
        'payable / raised card': (
          semantic.payable,
          scheme.surfaceContainerLowest,
        ),
        'advance / raised card': (
          semantic.advance,
          scheme.surfaceContainerLowest,
        ),
        'warning / raised card': (
          semantic.warning,
          scheme.surfaceContainerLowest,
        ),
        'onTertiaryContainer / badge': (
          scheme.onTertiaryContainer,
          scheme.tertiaryContainer,
        ),
        'error / raised card': (scheme.error, scheme.surfaceContainerLowest),
      };

      for (final MapEntry(key: label, value: (fg, bg)) in pairs.entries) {
        test(label, () {
          expect(
            contrastRatio(fg, bg),
            greaterThanOrEqualTo(aaText),
            reason: '$label in $name theme',
          );
        });
      }
    });
  }

  group('hero gradients keep white text readable at both ends', () {
    for (final (name, gradient) in [
      ('customers', AppGradients.customers),
      ('suppliers', AppGradients.suppliers),
    ]) {
      for (final stop in gradient.colors) {
        test('$name ${stop.toARGB32().toRadixString(16)}', () {
          expect(
            contrastRatio(AppGradients.onGradient, stop),
            greaterThanOrEqualTo(aaText),
          );
          expect(
            contrastRatio(AppGradients.onGradientMuted, stop),
            greaterThanOrEqualTo(aaText),
          );
        });
      }
    }
  });

  test('both themes carry the semantic colours and bundled fonts', () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      expect(theme.extension<AppSemanticColors>(), isNotNull);
      expect(theme.textTheme.bodyMedium?.fontFamily, AppTheme.fontFamily);
      expect(
        theme.textTheme.bodyMedium?.fontFamilyFallback,
        AppTheme.fontFamilyFallback,
      );
    }
  });
}
