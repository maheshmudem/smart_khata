import 'package:flutter/material.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_theme.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/form_fields.dart';
import 'package:smart_khata/core/widgets/formatters.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';

/// One ledger line (wireframes 5, `TransactionListTile`): date, type in
/// words, description, the effect as "Added"/"Reduced" with an icon, a
/// "Reversed" tag, and optionally the balance after the line.
class LedgerLineTile extends StatelessWidget {
  const LedgerLineTile({
    required this.transactionType,
    required this.amount,
    required this.effectiveAt,
    this.description,
    this.dueAt,
    this.isReversed = false,
    this.runningBalance,
    this.horizontalPadding = AppSpacing.lg,
    this.onTap,
    super.key,
  });

  /// Zero when the tile already sits inside a padded list.
  final double horizontalPadding;

  final TransactionType transactionType;

  /// Signed effect on the balance.
  final Money amount;
  final DateTime effectiveAt;
  final String? description;
  final DateTime? dueAt;
  final bool isReversed;

  /// The account role and the balance after this line, when shown.
  final (PartyRole, Money)? runningBalance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final increases = amount.isPositive;
    final formatted = MoneyFormatter.format(amount.abs());
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    // A reversed line is struck through and tagged in words; it is not
    // hidden and not shown by colour alone.
    final amountStyle = AppTheme.amountStyle(theme.textTheme.titleMedium)
        ?.copyWith(
          decoration: isReversed ? TextDecoration.lineThrough : null,
          color: isReversed ? theme.colorScheme.onSurfaceVariant : null,
        );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: AppSpacing.md,
        ),
        // Type and amount share the first line; everything else gets the
        // full width so long text wraps instead of overflowing. A very
        // large amount at a large text size shrinks to fit.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    l10n.transactionTypeLabel(transactionType),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerEnd,
                    child: Semantics(
                      label: increases
                          ? l10n.entryIncrease(formatted)
                          : l10n.entryDecrease(formatted),
                      excludeSemantics: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            increases ? Icons.add : Icons.remove,
                            size: AppSizes.iconSm,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          Text(formatted, style: amountStyle),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Text(AppDateFormat.instant(context, effectiveAt), style: muted),
            if (description case final String text) Text(text, style: muted),
            if (dueAt case final DateTime due)
              Text(
                l10n.ledgerDue(AppDateFormat.instant(context, due)),
                style: muted,
              ),
            if (isReversed)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: _Tag(text: l10n.ledgerReversedTag),
              ),
            if (runningBalance case (final role, final balance))
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  l10n.balanceText(BalanceKind.of(role, balance), balance),
                  style: muted,
                  textAlign: TextAlign.end,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.sm)),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}
