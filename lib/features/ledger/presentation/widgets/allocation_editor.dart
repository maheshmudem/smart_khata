import 'package:flutter/material.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/core/widgets/formatters.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/features/ledger/domain/allocation.dart';

/// What the owner decided in the [showAllocationEditor] sheet.
sealed class AllocationChoice {
  const AllocationChoice();
}

/// Go back to settling the oldest dues first.
final class UseOldestFirst extends AllocationChoice {
  const UseOldestFirst();
}

/// Settle exactly these dues.
final class UseManual extends AllocationChoice {
  const UseManual(this.lines);

  final List<AllocationLine> lines;
}

/// Lets the owner choose which dues a payment settles (wireframes 5,
/// `AllocationEditor`). Returns `null` if the sheet is dismissed.
Future<AllocationChoice?> showAllocationEditor(
  BuildContext context, {
  required List<OpenCharge> charges,
  required List<AllocationLine> current,
  required Money amount,
}) => showModalBottomSheet<AllocationChoice>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _AllocationEditor(
    charges: AllocationPolicy.inSettlementOrder(charges),
    current: current,
    amount: amount,
  ),
);

class _AllocationEditor extends StatefulWidget {
  const _AllocationEditor({
    required this.charges,
    required this.current,
    required this.amount,
  });

  final List<OpenCharge> charges;
  final List<AllocationLine> current;
  final Money amount;

  @override
  State<_AllocationEditor> createState() => _AllocationEditorState();
}

class _AllocationEditorState extends State<_AllocationEditor> {
  late final Map<String, Money> _amounts = {
    for (final line in widget.current) line.targetEntryId: line.amount,
  };

  List<AllocationLine> get _lines => [
    for (final charge in widget.charges)
      if (_amounts[charge.entryId] case final Money amount
          when amount.isPositive)
        AllocationLine(targetEntryId: charge.entryId, amount: amount),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final required = AllocationPolicy.amountToAllocate(
      widget.charges,
      widget.amount,
    );
    final lines = _lines;
    final applied = Money.sum(lines.map((l) => l.amount));
    // The same rule the repository enforces when saving.
    final isValid = AllocationPolicy.isValidManual(
      lines,
      widget.charges,
      widget.amount,
    );

    return SafeArea(
      child: Padding(
        // Keep the sheet above the keyboard.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          // One scrolling list for the dues and the buttons: at large text
          // on a small phone a fixed footer would not fit.
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: [
              Text(
                l10n.allocationEditorTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              for (final charge in widget.charges) ...[
                Text(
                  '${l10n.transactionTypeLabel(charge.transactionType)}'
                  ' · ${AppDateFormat.instant(context, charge.effectiveAt)}',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                MoneyAmountField(
                  label: l10n.allocationOpenAmount(
                    MoneyFormatter.format(charge.openAmount),
                  ),
                  isRequired: false,
                  emphasized: false,
                  initialValue: _amounts[charge.entryId],
                  errorText:
                      (_amounts[charge.entryId] ?? Money.zero) >
                          charge.openAmount
                      ? l10n.validationAmountTooLarge
                      : null,
                  onChanged: (value) => setState(() {
                    if (value == null) {
                      _amounts.remove(charge.entryId);
                    } else {
                      _amounts[charge.entryId] = value;
                    }
                  }),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Text(
                l10n.allocationApplied(MoneyFormatter.format(applied)),
                style: theme.textTheme.titleMedium,
              ),
              if (!isValid)
                Text(
                  l10n.allocationMustMatch(MoneyFormatter.format(required)),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              AppPrimaryButton(
                label: l10n.actionDone,
                onPressed: isValid
                    ? () => Navigator.of(context).pop(UseManual(lines))
                    : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppSecondaryButton(
                label: l10n.actionResetOldestFirst,
                onPressed: () =>
                    Navigator.of(context).pop(const UseOldestFirst()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
