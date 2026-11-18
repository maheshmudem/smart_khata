import 'package:flutter/material.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/contact_text.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_cards.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/money_text.dart';
import 'package:smart_khata/features/parties/domain/party.dart';

/// One party in the list: avatar, name, phone and the balance with its
/// direction in words (never colour or sign alone).
class PartyTile extends StatelessWidget {
  const PartyTile({required this.item, required this.onTap, super.key});

  final PartyListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final kind = BalanceKind.of(item.role, item.balance);
    final label = l10n.balanceLabel(kind);
    final phone = item.phone;

    return Semantics(
      button: true,
      label:
          '${item.name}, '
          '${l10n.amountSemantics(label, MoneyFormatter.format(item.balance.abs()))}',
      excludeSemantics: true,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            PartyAvatar(name: item.name),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: theme.textTheme.titleMedium),
                  if (phone != null)
                    Text(
                      ContactText.displayPhone(phone),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (item.isArchived)
                    Text(
                      l10n.partyArchivedTag,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: balanceColor(context, kind),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: MoneyText(item.balance.abs()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
