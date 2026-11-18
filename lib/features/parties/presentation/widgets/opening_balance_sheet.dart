import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/load_state.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/core/widgets/dialogs.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/money_text.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/parties/domain/party_use_cases.dart';
import 'package:smart_khata/features/parties/presentation/bloc/opening_balance_bloc.dart';

/// Opens the opening-balance form for one account. Returns `true` when the
/// balance was committed.
Future<bool> showOpeningBalanceSheet(
  BuildContext context, {
  required PostOpeningBalance postOpeningBalance,
  required String accountId,
  required String operationId,
  required PartyRole role,
  required Money currentBalance,
}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider(
      create: (_) => OpeningBalanceBloc(
        post: postOpeningBalance,
        accountId: accountId,
        operationId: operationId,
      ),
      child: _OpeningBalanceSheet(role: role, currentBalance: currentBalance),
    ),
  );
  return saved ?? false;
}

class _OpeningBalanceSheet extends StatelessWidget {
  const _OpeningBalanceSheet({
    required this.role,
    required this.currentBalance,
  });

  final PartyRole role;
  final Money currentBalance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bloc = context.read<OpeningBalanceBloc>();
    final isCustomer = role == PartyRole.customer;

    return BlocConsumer<OpeningBalanceBloc, OpeningBalanceState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) {
        if (state.status == SubmitStatus.success) {
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        final failure = state.failure;
        final after = currentBalance + state.signedChange;
        return DiscardChangesGuard(
          isDirty: state.isDirty && state.status != SubmitStatus.success,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.openingBalanceTitle,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.openingBalanceIntro,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (final (direction, label) in [
                    (
                      OpeningDirection.owed,
                      isCustomer
                          ? l10n.openingCustomerOwes
                          : l10n.openingSupplierOwed,
                    ),
                    (
                      OpeningDirection.advance,
                      isCustomer
                          ? l10n.openingCustomerAdvance
                          : l10n.openingSupplierAdvance,
                    ),
                  ])
                    _DirectionOption(
                      label: label,
                      selected: state.direction == direction,
                      onTap: () => bloc.add(OpeningDirectionChanged(direction)),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  MoneyAmountField(
                    label: l10n.amountLabel,
                    autofocus: true,
                    errorText: state.amountError == null
                        ? null
                        : l10n.validationMessage(state.amountError!),
                    onChanged: (m) => bloc.add(OpeningAmountChanged(m)),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Review: current balance and the balance after saving,
                  // each with its direction in words.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: AppRadius.card,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.reviewTitle,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _ReviewLine(
                            caption: l10n.reviewCurrent,
                            role: role,
                            balance: currentBalance,
                          ),
                          const Divider(height: AppSpacing.xl),
                          _ReviewLine(
                            caption: l10n.reviewAfter,
                            role: role,
                            balance: after,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (failure != null) ...[
                    InlineError(message: l10n.failureMessage(failure)),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  AppPrimaryButton(
                    label: l10n.actionSave,
                    icon: Icons.check,
                    isLoading: state.status == SubmitStatus.submitting,
                    onPressed: () => bloc.add(const OpeningBalanceSubmitted()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DirectionOption extends StatelessWidget {
  const _DirectionOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        checked: selected,
        button: true,
        child: Material(
          color: selected
              ? scheme.primaryContainer
              : scheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.control,
            side: BorderSide(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSizes.minTouchTarget + AppSpacing.sm,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selected ? scheme.primary : scheme.outline,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewLine extends StatelessWidget {
  const _ReviewLine({
    required this.caption,
    required this.role,
    required this.balance,
  });

  final String caption;
  final PartyRole role;
  final Money balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          caption,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        BalanceSummary(
          kind: BalanceKind.of(role, balance),
          amount: balance,
          amountStyle: theme.textTheme.titleLarge,
        ),
      ],
    );
  }
}
