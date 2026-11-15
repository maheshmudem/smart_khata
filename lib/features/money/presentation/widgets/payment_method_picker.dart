import 'package:flutter/material.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/features/money/domain/money_account.dart';
import 'package:smart_khata/l10n/generated/app_localizations.dart';

/// The payment methods the V1 forms offer (FR-PAY-001). Cheque is in the
/// schema but not offered until its clearing flow exists.
const List<PaymentMethod> offeredPaymentMethods = [
  PaymentMethod.cash,
  PaymentMethod.upi,
  PaymentMethod.bankTransfer,
];

extension PaymentMethodLabelX on AppLocalizations {
  String methodName(PaymentMethod method) => switch (method) {
    PaymentMethod.cash => methodCash,
    PaymentMethod.upi => methodUpi,
    PaymentMethod.bankTransfer => methodBankTransfer,
    PaymentMethod.cheque => methodCheque,
    PaymentMethod.other => methodOther,
  };
}

/// How a payment was made and which money account it moved through.
///
/// The method and the account are separate facts: UPI is a method, the
/// money lands in a bank account. Cash always uses the cash drawer, so no
/// account is asked for; for UPI and bank transfer the owner picks a bank
/// account or adds one on the spot.
class PaymentMethodPicker extends StatelessWidget {
  const PaymentMethodPicker({
    required this.method,
    required this.accountId,
    required this.accounts,
    required this.onMethodChanged,
    required this.onAccountChanged,
    required this.onAddAccount,
    this.errorText,
    super.key,
  });

  final PaymentMethod method;
  final String? accountId;
  final List<MoneyAccount> accounts;
  final ValueChanged<PaymentMethod> onMethodChanged;
  final ValueChanged<String> onAccountChanged;

  /// Creates a bank account with the given name and selects it.
  final Future<void> Function(String name) onAddAccount;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final usable = [
      for (final account in accounts)
        if (method.fits(account.type)) account,
    ];
    final selected = usable.any((a) => a.id == accountId) ? accountId : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            for (final option in offeredPaymentMethods)
              ChoiceChip(
                label: Text(l10n.methodName(option)),
                selected: option == method,
                onSelected: (_) => onMethodChanged(option),
              ),
          ],
        ),
        if (method != PaymentMethod.cash) ...[
          const SizedBox(height: AppSpacing.md),
          if (usable.isNotEmpty)
            DropdownButtonFormField<String>(
              // Rebuilt when the choice or the list changes.
              key: ValueKey('$selected-${usable.length}'),
              initialValue: selected,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.moneyAccountLabel),
              hint: Text(l10n.chooseAccount),
              items: [
                for (final account in usable)
                  DropdownMenuItem(
                    value: account.id,
                    child: Text(account.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (id) {
                if (id != null) onAccountChanged(id);
              },
            ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              icon: const Icon(Icons.add, size: AppSizes.iconSm),
              label: Text(l10n.actionAddBankAccount),
              onPressed: () => _addAccount(context),
            ),
          ),
        ],
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _addAccount(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _AddAccountDialog(),
    );
    if (name != null) await onAddAccount(name);
  }
}

class _AddAccountDialog extends StatefulWidget {
  const _AddAccountDialog();

  @override
  State<_AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<_AddAccountDialog> {
  String _name = '';
  bool _showError = false;

  void _submit() {
    final name = _name.trim();
    if (name.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.actionAddBankAccount),
      content: AppTextField(
        label: l10n.accountNameLabel,
        helperText: l10n.accountNameHint,
        errorText: _showError ? l10n.validationRequired : null,
        isRequired: true,
        autofocus: true,
        maxLength: CreateMoneyAccount.maxNameLength,
        textCapitalization: TextCapitalization.words,
        onChanged: (value) => setState(() {
          _name = value;
          _showError = false;
        }),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.actionAdd)),
      ],
    );
  }
}
