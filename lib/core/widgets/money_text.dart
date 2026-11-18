import 'package:flutter/material.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_colors.dart';
import 'package:smart_khata/core/theme/app_theme.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';

/// An amount in rupees with Indian digit grouping.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.amount, {
    this.style,
    this.color,
    this.alwaysShowPaise = false,
    super.key,
  });

  final Money amount;
  final TextStyle? style;
  final Color? color;
  final bool alwaysShowPaise;

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.titleMedium;
    return Text(
      MoneyFormatter.format(amount, alwaysShowPaise: alwaysShowPaise),
      style: AppTheme.amountStyle(base)?.copyWith(color: color),
    );
  }
}

/// The supporting colour for a balance direction. Always shown with the
/// direction label, never alone.
Color balanceColor(BuildContext context, BalanceKind kind) {
  final semantic = context.semanticColors;
  return switch (kind) {
    BalanceKind.customerOwes => semantic.receivable,
    BalanceKind.youOweSupplier => semantic.payable,
    BalanceKind.customerAdvance ||
    BalanceKind.supplierAdvance => semantic.advance,
    BalanceKind.settled => semantic.neutral,
  };
}

/// The supporting icon for a balance direction.
IconData balanceIcon(BalanceKind kind) => switch (kind) {
  BalanceKind.customerOwes => Icons.south_west,
  BalanceKind.youOweSupplier => Icons.north_east,
  BalanceKind.customerAdvance ||
  BalanceKind.supplierAdvance => Icons.savings_outlined,
  BalanceKind.settled => Icons.check_circle_outline,
};

/// A balance with its direction in words, an icon and a supporting colour.
///
/// The label carries the meaning ("Customer owes", "Customer advance"); the
/// amount is always shown as a magnitude so a minus sign is never the only
/// clue to direction (UI spec 3.2).
class BalanceSummary extends StatelessWidget {
  const BalanceSummary({
    required this.kind,
    required this.amount,
    this.amountStyle,
    super.key,
  });

  final BalanceKind kind;

  /// The balance; its sign is ignored for display.
  final Money amount;
  final TextStyle? amountStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = balanceColor(context, kind);
    final icon = balanceIcon(kind);
    final label = context.l10n.balanceLabel(kind);
    final formatted = MoneyFormatter.format(amount.abs());

    return Semantics(
      label: context.l10n.amountSemantics(label, formatted),
      container: true,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppSizes.iconSm, color: color),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          MoneyText(
            amount.abs(),
            style: amountStyle ?? theme.textTheme.headlineSmall,
            color: theme.colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}
