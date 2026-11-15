import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/date_time/date_range.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_theme.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/core/widgets/choice_tile.dart';
import 'package:smart_khata/core/widgets/dialogs.dart';
import 'package:smart_khata/core/widgets/form_fields.dart';
import 'package:smart_khata/core/widgets/formatters.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/money_text.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/money/domain/cash_book.dart';
import 'package:smart_khata/features/money/domain/money_account.dart';
import 'package:smart_khata/features/money/presentation/money_cubits.dart';
import 'package:smart_khata/l10n/generated/app_localizations.dart';

extension MoneyLabelsX on AppLocalizations {
  String accountTypeName(MoneyAccountType type) => switch (type) {
    MoneyAccountType.cash => accountTypeCash,
    MoneyAccountType.bank => accountTypeBank,
    MoneyAccountType.upiSettlement => accountTypeUpi,
    MoneyAccountType.other => accountTypeOther,
  };

  String rangeName(DateRangePreset preset) => switch (preset) {
    DateRangePreset.today => rangeToday,
    DateRangePreset.last7Days => rangeLast7Days,
    DateRangePreset.thisMonth => rangeThisMonth,
    DateRangePreset.allTime => rangeAllTime,
  };

  /// A money-account balance. It can be below zero, so the sign is kept.
  String accountBalance(Money balance) => MoneyFormatter.format(balance);
}

enum _CashBookAction { adjust, accounts }

/// WF-040: what came into and went out of one money account.
class CashBookPage extends StatelessWidget {
  const CashBookPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<CashBookCubit>();

    return BlocBuilder<CashBookCubit, CashBookState>(
      builder: (context, state) {
        final account = state.selectedAccount;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.cashBookTitle),
            actions: [
              PopupMenuButton<_CashBookAction>(
                tooltip: l10n.moreActionsTooltip,
                onSelected: (action) => unawaited(
                  context.push(switch (action) {
                    _CashBookAction.adjust => AppRoutes.adjustment(
                      accountId: state.selectedAccountId,
                    ),
                    _CashBookAction.accounts => AppRoutes.moneyAccounts,
                  }),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _CashBookAction.adjust,
                    child: Text(l10n.actionRecordAdjustment),
                  ),
                  PopupMenuItem(
                    value: _CashBookAction.accounts,
                    child: Text(l10n.moneyAccountsTitle),
                  ),
                ],
              ),
            ],
          ),
          body: state.status == LoadStatus.failure
              ? ErrorView(
                  message: l10n.failureMessage(
                    state.failure ?? const UnexpectedFailure(),
                    context: FailureContext.loading,
                  ),
                  onRetry: null,
                )
              : ListView(
                  children: [
                    _Chips<String>(
                      values: [for (final a in state.accounts) a.id],
                      selected: state.selectedAccountId,
                      labelOf: (id) =>
                          state.accounts.firstWhere((a) => a.id == id).name,
                      onSelected: cubit.accountSelected,
                    ),
                    if (account != null)
                      Padding(
                        padding: AppSpacing.page,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.cashBookBalance),
                            MoneyText(
                              account.balance,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    _Chips<DateRangePreset>(
                      values: DateRangePreset.values,
                      selected: state.preset,
                      labelOf: l10n.rangeName,
                      onSelected: cubit.presetSelected,
                    ),
                    if (state.summary case final CashBookSummary summary)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: _SummaryCard(summary: summary),
                      ),
                    if (state.status == LoadStatus.loading)
                      const SizedBox(height: 96, child: LoadingView())
                    else if (state.lines.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          l10n.cashBookEmpty,
                          textAlign: TextAlign.center,
                        ),
                      )
                    else ...[
                      for (final line in state.lines) ...[
                        _CashBookTile(line: line),
                        const Divider(),
                      ],
                      if (state.hasMore)
                        TextButton(
                          onPressed: cubit.loadMore,
                          child: Text(l10n.actionLoadMore),
                        ),
                    ],
                  ],
                ),
        );
      },
    );
  }
}

/// A horizontally scrolling row of single-choice chips.
class _Chips<T> extends StatelessWidget {
  const _Chips({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final List<T> values;
  final T? selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          for (final value in values)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(labelOf(value)),
                selected: value == selected,
                onSelected: (_) => onSelected(value),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final CashBookSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    Widget row(String label, Money amount, {bool strong = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                MoneyFormatter.format(amount),
                style: AppTheme.amountStyle(
                  strong
                      ? theme.textTheme.titleMedium
                      : theme.textTheme.bodyLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row(l10n.cashBookOpening, summary.openingBalance),
            row(l10n.cashBookIn, summary.inflows),
            row(l10n.cashBookOut, summary.outflows),
            const Divider(),
            row(l10n.cashBookClosing, summary.closingBalance, strong: true),
            const SizedBox(height: AppSpacing.sm),
            // Collections and cash added are not income (FR-CASH-009).
            Text(l10n.cashBookNotIncomeNote, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// One movement: what caused it in words, the date, and "In" or "Out"
/// written out next to the amount.
class _CashBookTile extends StatelessWidget {
  const _CashBookTile({required this.line});

  final CashBookLine line;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final formatted = MoneyFormatter.format(line.amount);
    final source = line.partyName ?? line.categoryName ?? line.description;

    return InkWell(
      onTap: () =>
          unawaited(context.push(AppRoutes.transaction(line.transactionId))),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    l10n.transactionTypeLabel(line.transactionType),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      line.isInflow
                          ? l10n.movementIn(formatted)
                          : l10n.movementOut(formatted),
                      style: AppTheme.amountStyle(theme.textTheme.titleMedium)
                          ?.copyWith(
                            decoration: line.isReversed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            if (source != null) Text(source, style: muted),
            Text(
              [
                AppDateFormat.instant(context, line.effectiveAt),
                if (line.isReversed) l10n.ledgerReversedTag,
              ].join(' · '),
              style: muted,
            ),
          ],
        ),
      ),
    );
  }
}

/// WF-041: the shop's cash and bank accounts.
class MoneyAccountsPage extends StatelessWidget {
  const MoneyAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<MoneyAccountsCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.moneyAccountsTitle),
        actions: [
          IconButton(
            tooltip: l10n.actionAddAccount,
            icon: const Icon(Icons.add),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => _AddAccountDialog(onSave: cubit.add),
            ),
          ),
        ],
      ),
      body: BlocBuilder<MoneyAccountsCubit, MoneyAccountsState>(
        builder: (context, state) => switch (state.status) {
          LoadStatus.loading => const LoadingView(),
          LoadStatus.failure => ErrorView(
            message: l10n.failureMessage(
              state.failure ?? const UnexpectedFailure(),
              context: FailureContext.loading,
            ),
            onRetry: null,
          ),
          LoadStatus.loaded => ListView.separated(
            itemCount: state.accounts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final account = state.accounts[index];
              return ListTile(
                title: Text(account.name),
                subtitle: Text(
                  '${l10n.accountTypeName(account.type)} · '
                  '${l10n.accountBalance(account.balance)}',
                ),
                // The cash drawer is always needed.
                trailing: account.isCash
                    ? null
                    : PopupMenuButton<void>(
                        tooltip: l10n.accountActionsTooltip,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            onTap: () => _deactivate(context, account),
                            child: Text(l10n.actionDeactivate),
                          ),
                        ],
                      ),
              );
            },
          ),
        },
      ),
    );
  }

  Future<void> _deactivate(BuildContext context, MoneyAccount account) async {
    final l10n = context.l10n;
    final cubit = context.read<MoneyAccountsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deactivateConfirmTitle(account.name),
      message: l10n.deactivateConfirmBody,
      confirmLabel: l10n.actionDeactivate,
      cancelLabel: l10n.actionCancel,
    );
    if (!confirmed) return;
    final failure = await cubit.deactivate(account.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            failure == null
                ? l10n.accountDeactivated
                : l10n.failureMessage(failure),
          ),
        ),
      );
  }
}

class _AddAccountDialog extends StatefulWidget {
  const _AddAccountDialog({required this.onSave});

  final Future<Failure?> Function({
    required String name,
    required MoneyAccountType type,
    Money? openingBalance,
  })
  onSave;

  @override
  State<_AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<_AddAccountDialog> {
  String _name = '';
  MoneyAccountType _type = MoneyAccountType.bank;
  Money? _opening;
  Failure? _failure;
  bool _isSaving = false;

  Future<void> _submit() async {
    setState(() => _isSaving = true);
    final failure = await widget.onSave(
      name: _name,
      type: _type,
      openingBalance: _opening,
    );
    if (!mounted) return;
    if (failure == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _failure = failure;
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.actionAddAccount),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: l10n.accountNameLabel,
            helperText: l10n.accountNameHint,
            isRequired: true,
            autofocus: true,
            maxLength: CreateMoneyAccount.maxNameLength,
            textCapitalization: TextCapitalization.words,
            errorText: switch (_failure) {
              final Failure f => l10n.failureMessage(f),
              null => null,
            },
            onChanged: (value) => setState(() {
              _name = value;
              _failure = null;
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final type in const [
                MoneyAccountType.bank,
                MoneyAccountType.upiSettlement,
              ])
                ChoiceChip(
                  label: Text(l10n.accountTypeName(type)),
                  selected: _type == type,
                  onSelected: (_) => setState(() => _type = type),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          MoneyAmountField(
            label: l10n.openingBalanceLabel,
            isRequired: false,
            emphasized: false,
            helperText: l10n.openingBalanceAccountHelp,
            onChanged: (value) => _opening = value,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: Text(l10n.actionAdd),
        ),
      ],
    );
  }
}

/// Add or remove money with a reason: opening cash, a counted difference,
/// a correction.
class AdjustmentFormPage extends StatelessWidget {
  const AdjustmentFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<AdjustmentFormCubit>();

    return BlocConsumer<AdjustmentFormCubit, AdjustmentFormState>(
      listenWhen: (previous, current) =>
          current.status == SubmissionStatus.success &&
          previous.status != SubmissionStatus.success,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.adjustmentSaved)));
        context.pop();
      },
      builder: (context, state) {
        final isBusy =
            state.status.isSubmitting ||
            state.status == SubmissionStatus.success;
        final account = state.account;
        final newBalance = state.newBalance;

        String? error(String field) => switch (state.errors[field]) {
          final ValidationError e => l10n.validationMessage(e),
          null => null,
        };

        return DiscardChangesGuard(
          isDirty: state.isDirty && !isBusy,
          child: Scaffold(
            appBar: AppBar(title: Text(l10n.actionRecordAdjustment)),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: [
                        Text(l10n.adjustmentExplain),
                        const SizedBox(height: AppSpacing.lg),
                        DropdownButtonFormField<String>(
                          key: ValueKey(
                            '${state.moneyAccountId}-${state.accounts.length}',
                          ),
                          initialValue: account?.id,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: '${l10n.moneyAccountLabel} *',
                            errorText: error(
                              RecordAdjustmentCommand.accountField,
                            ),
                          ),
                          items: [
                            for (final a in state.accounts)
                              DropdownMenuItem(
                                value: a.id,
                                child: Text(
                                  a.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (id) {
                            if (id != null) cubit.accountChanged(id);
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ChoiceTile(
                          label: l10n.adjustmentAdd,
                          isSelected:
                              state.direction == MovementDirection.inflow,
                          onTap: () =>
                              cubit.directionChanged(MovementDirection.inflow),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ChoiceTile(
                          label: l10n.adjustmentRemove,
                          isSelected:
                              state.direction == MovementDirection.outflow,
                          onTap: () =>
                              cubit.directionChanged(MovementDirection.outflow),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        MoneyAmountField(
                          label: l10n.amountLabel,
                          initialValue: state.amount,
                          errorText: error(RecordAdjustmentCommand.amountField),
                          onChanged: cubit.amountChanged,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: l10n.reasonLabel,
                          isRequired: true,
                          errorText: error(RecordAdjustmentCommand.reasonField),
                          textCapitalization: TextCapitalization.sentences,
                          maxLength: RecordAdjustmentCommand.maxReasonLength,
                          onChanged: cubit.reasonChanged,
                        ),
                        if (account != null) ...[
                          const SizedBox(height: AppSpacing.lg),
                          ReviewCard(
                            rows: [
                              (
                                l10n.cashBookBalance,
                                l10n.accountBalance(account.balance),
                              ),
                              (
                                l10n.cashBookClosing,
                                newBalance == null
                                    ? '—'
                                    : l10n.accountBalance(newBalance),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state.failure case final Failure failure) ...[
                          InlineError(message: l10n.failureMessage(failure)),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        AppPrimaryButton(
                          label: l10n.actionSave,
                          isLoading: isBusy,
                          onPressed: cubit.submit,
                        ),
                      ],
                    ),
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
