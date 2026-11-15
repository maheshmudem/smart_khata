import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
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
    // Entries whose form exists carry a route; the rest say they are not
    // available yet instead of doing nothing.
    final entries = <(IconData, String, String, String?)>[
      (
        Icons.south_west,
        l10n.quickAddGiveCredit,
        l10n.quickAddGiveCreditHint,
        AppRoutes.charge(role: PartyRole.customer),
      ),
      (
        Icons.payments_outlined,
        l10n.quickAddReceivePayment,
        l10n.quickAddReceivePaymentHint,
        AppRoutes.payment(role: PartyRole.customer),
      ),
      (
        Icons.local_shipping_outlined,
        l10n.quickAddSupplierPurchase,
        l10n.quickAddSupplierPurchaseHint,
        AppRoutes.charge(role: PartyRole.supplier),
      ),
      (
        Icons.north_east,
        l10n.quickAddPaySupplier,
        l10n.quickAddPaySupplierHint,
        AppRoutes.payment(role: PartyRole.supplier),
      ),
      (
        Icons.receipt_long_outlined,
        l10n.quickAddExpense,
        l10n.quickAddExpenseHint,
        null,
      ),
      (
        Icons.calculate_outlined,
        l10n.quickAddCashCount,
        l10n.quickAddCashCountHint,
        null,
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
                  for (final (icon, title, hint, route) in entries)
                    ListTile(
                      leading: Icon(icon),
                      title: Text(title),
                      subtitle: Text(hint),
                      // Choosing an entry only opens its form; nothing is
                      // posted from this sheet.
                      onTap: () {
                        final messenger = ScaffoldMessenger.of(context);
                        final router = GoRouter.of(context);
                        Navigator.of(context).pop();
                        if (route != null) {
                          unawaited(router.push(route));
                          return;
                        }
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
