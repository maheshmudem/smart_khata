import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_cards.dart';
import 'package:smart_khata/core/widgets/dialogs.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/features/ledger/domain/entry_type.dart';

/// WF-011: what the owner can add. Choosing an option only opens its form;
/// nothing is ever posted from this sheet.
Future<void> showQuickAddSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => const _QuickAddSheet(),
  );
}

class _QuickAddSheet extends StatelessWidget {
  const _QuickAddSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final router = GoRouter.of(context);
    final messengerContext = Navigator.of(context).context;

    void open(String location) {
      Navigator.of(context).pop();
      unawaited(router.push(location));
    }

    void comingSoon() {
      Navigator.of(context).pop();
      showComingSoon(messengerContext);
    }

    final people = <_Option>[
      _Option(
        Icons.person_add_alt_1,
        l10n.actionAddCustomer,
        l10n.quickAddAddCustomerHint,
        () => open(AppRoutes.partyNewFor(PartyRole.customer)),
      ),
      _Option(
        Icons.local_shipping_outlined,
        l10n.actionAddSupplier,
        l10n.quickAddAddSupplierHint,
        () => open(AppRoutes.partyNewFor(PartyRole.supplier)),
      ),
    ];
    // Expenses and the cash count arrive with the cash book.
    final entries = <_Option>[
      _Option(
        Icons.south_west_rounded,
        l10n.quickAddGiveCredit,
        l10n.quickAddGiveCreditHint,
        () => open(AppRoutes.entry(EntryType.customerCredit)),
      ),
      _Option(
        Icons.payments_rounded,
        l10n.quickAddReceivePayment,
        l10n.quickAddReceivePaymentHint,
        () => open(AppRoutes.entry(EntryType.customerPayment)),
      ),
      _Option(
        Icons.inventory_2_rounded,
        l10n.quickAddSupplierPurchase,
        l10n.quickAddSupplierPurchaseHint,
        () => open(AppRoutes.entry(EntryType.supplierPurchase)),
      ),
      _Option(
        Icons.north_east_rounded,
        l10n.quickAddPaySupplier,
        l10n.quickAddPaySupplierHint,
        () => open(AppRoutes.entry(EntryType.supplierPayment)),
      ),
      _Option(
        Icons.receipt_long_outlined,
        l10n.quickAddExpense,
        l10n.quickAddExpenseHint,
        comingSoon,
        comingSoon: true,
      ),
      _Option(
        Icons.calculate_outlined,
        l10n.quickAddCashCount,
        l10n.quickAddCashCountHint,
        comingSoon,
        comingSoon: true,
      ),
    ];

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          children: [
            Text(l10n.quickAddTitle, style: theme.textTheme.titleLarge),
            SectionHeader(title: l10n.quickAddSectionPeople),
            for (final option in people) _OptionTile(option: option),
            SectionHeader(title: l10n.quickAddSectionEntries),
            for (final option in entries) _OptionTile(option: option),
          ],
        ),
      ),
    );
  }
}

class _Option {
  const _Option(
    this.icon,
    this.title,
    this.hint,
    this.onTap, {
    this.comingSoon = false,
  });

  final IconData icon;
  final String title;
  final String hint;
  final VoidCallback onTap;
  final bool comingSoon;
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.option});

  final _Option option;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: option.onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: option.comingSoon
                    ? scheme.surfaceContainerHigh
                    : scheme.primaryContainer,
                borderRadius: AppRadius.control,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Icon(
                  option.icon,
                  color: option.comingSoon
                      ? scheme.onSurfaceVariant
                      : scheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.title, style: theme.textTheme.titleSmall),
                  Text(
                    option.hint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (option.comingSoon) ...[
              const SizedBox(width: AppSpacing.sm),
              const ComingSoonBadge(),
            ] else
              const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
