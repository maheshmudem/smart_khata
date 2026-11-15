import 'package:flutter/material.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';

/// WF-011: the list of entries the owner can add. Choosing one only opens
/// its form; nothing is ever posted from this sheet.
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
    final entries = <(IconData, String, String)>[
      (
        Icons.south_west,
        l10n.quickAddGiveCredit,
        l10n.quickAddGiveCreditHint,
      ),
      (
        Icons.payments_outlined,
        l10n.quickAddReceivePayment,
        l10n.quickAddReceivePaymentHint,
      ),
      (
        Icons.local_shipping_outlined,
        l10n.quickAddSupplierPurchase,
        l10n.quickAddSupplierPurchaseHint,
      ),
      (
        Icons.north_east,
        l10n.quickAddPaySupplier,
        l10n.quickAddPaySupplierHint,
      ),
      (
        Icons.receipt_long_outlined,
        l10n.quickAddExpense,
        l10n.quickAddExpenseHint,
      ),
      (
        Icons.calculate_outlined,
        l10n.quickAddCashCount,
        l10n.quickAddCashCountHint,
      ),
    ];

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                l10n.quickAddTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final (icon, title, hint) in entries)
                    ListTile(
                      leading: Icon(icon),
                      title: Text(title),
                      subtitle: Text(hint),
                      // The entry forms are built in later phases; until
                      // then each row says so instead of doing nothing.
                      onTap: () {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.of(context).pop();
                        messenger
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(content: Text(l10n.featureNotReadyTitle)),
                          );
                      },
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
