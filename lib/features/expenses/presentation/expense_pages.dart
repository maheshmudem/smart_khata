import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/core/widgets/dialogs.dart';
import 'package:smart_khata/core/widgets/form_fields.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/expenses/domain/expense.dart';
import 'package:smart_khata/features/expenses/presentation/expense_cubits.dart';
import 'package:smart_khata/features/money/presentation/widgets/payment_method_picker.dart';

/// WF-042: record a shop expense. It is a money movement with a category;
/// nothing here is called profit.
class ExpenseFormPage extends StatelessWidget {
  const ExpenseFormPage({required this.today, super.key});

  final BusinessDate today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ExpenseFormCubit>();

    return BlocConsumer<ExpenseFormCubit, ExpenseFormState>(
      listenWhen: (previous, current) =>
          current.status == SubmissionStatus.success &&
          previous.status != SubmissionStatus.success,
      listener: (context, state) {
        // Only now, after the commit.
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.expenseSaved)));
        context.pop();
      },
      builder: (context, state) {
        final isBusy =
            state.status.isSubmitting ||
            state.status == SubmissionStatus.success;
        final account = state.account;

        String? error(String field) => switch (state.errors[field]) {
          final ValidationError e => l10n.validationMessage(e),
          null => null,
        };

        return DiscardChangesGuard(
          isDirty: state.isDirty && !isBusy,
          child: Scaffold(
            appBar: AppBar(title: Text(l10n.expenseTitle)),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: [
                        MoneyAmountField(
                          label: l10n.amountLabel,
                          autofocus: true,
                          errorText: error(RecordExpenseCommand.amountField),
                          onChanged: cubit.amountChanged,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        DropdownButtonFormField<String>(
                          // Rebuilt when the choice or the list changes.
                          key: ValueKey(
                            '${state.categoryId}-${state.categories.length}',
                          ),
                          initialValue: state.categoryId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: '${l10n.categoryLabel} *',
                            errorText: error(
                              RecordExpenseCommand.categoryField,
                            ),
                          ),
                          hint: Text(l10n.chooseCategory),
                          items: [
                            for (final category in state.categories)
                              DropdownMenuItem(
                                value: category.id,
                                child: Text(
                                  category.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: cubit.categoryChanged,
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton(
                            onPressed: () => unawaited(
                              context.push(AppRoutes.expenseCategories),
                            ),
                            child: Text(l10n.actionManageCategories),
                          ),
                        ),
                        DateField(
                          label: l10n.dateLabel,
                          value: state.date,
                          firstDate: BusinessDate(2000, 1, 1),
                          lastDate: today,
                          errorText: error(RecordExpenseCommand.dateField),
                          onChanged: cubit.dateChanged,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l10n.paidFromLabel,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        PaymentMethodPicker(
                          method: state.method,
                          accountId: state.moneyAccountId,
                          accounts: state.moneyAccounts,
                          errorText: error(RecordExpenseCommand.accountField),
                          onMethodChanged: cubit.methodChanged,
                          onAccountChanged: cubit.accountChanged,
                          onAddAccount: cubit.addMoneyAccount,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: l10n.payeeLabel,
                          textCapitalization: TextCapitalization.words,
                          maxLength: RecordExpenseCommand.maxTextLength,
                          onChanged: cubit.payeeChanged,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: l10n.noteLabel,
                          errorText: error(RecordExpenseCommand.noteField),
                          textCapitalization: TextCapitalization.sentences,
                          maxLength: RecordExpenseCommand.maxTextLength,
                          onChanged: cubit.noteChanged,
                        ),
                        if (account != null) ...[
                          const SizedBox(height: AppSpacing.lg),
                          // What will leave which account, before saving.
                          ReviewCard(
                            rows: [
                              (l10n.paidFromLabel, account.name),
                              (
                                l10n.cashBookOut,
                                (state.amount?.isPositive ?? false)
                                    ? MoneyFormatter.format(state.amount!)
                                    : '—',
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
                          label: l10n.actionSaveExpense,
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

enum _CategoryAction { rename, archive, restore }

/// WF-043: add, rename, archive and restore expense categories.
class ExpenseCategoriesPage extends StatelessWidget {
  const ExpenseCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ExpenseCategoriesCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.expenseCategoriesTitle),
        actions: [
          IconButton(
            tooltip: l10n.actionAddCategory,
            icon: const Icon(Icons.add),
            onPressed: () => _edit(context),
          ),
        ],
      ),
      body: BlocBuilder<ExpenseCategoriesCubit, ExpenseCategoriesState>(
        builder: (context, state) => switch (state.status) {
          LoadStatus.loading => const LoadingView(),
          LoadStatus.failure => ErrorView(
            message: l10n.failureMessage(
              state.failure ?? const UnexpectedFailure(),
              context: FailureContext.loading,
            ),
            onRetry: cubit.retry,
          ),
          LoadStatus.loaded when state.categories.isEmpty => EmptyState(
            title: l10n.categoriesEmpty,
            actionLabel: l10n.actionAddCategory,
            onAction: () => _edit(context),
          ),
          LoadStatus.loaded => ListView.separated(
            itemCount: state.categories.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final category = state.categories[index];
              return ListTile(
                title: Text(category.name),
                // Said in words, not only by greying the row.
                subtitle: category.isActive
                    ? null
                    : Text(l10n.categoryArchivedTag),
                trailing: PopupMenuButton<_CategoryAction>(
                  tooltip: l10n.categoryActionsTooltip,
                  onSelected: (action) => _onAction(context, action, category),
                  itemBuilder: (context) => [
                    if (category.isActive) ...[
                      PopupMenuItem(
                        value: _CategoryAction.rename,
                        child: Text(l10n.actionRename),
                      ),
                      PopupMenuItem(
                        value: _CategoryAction.archive,
                        child: Text(l10n.actionArchive),
                      ),
                    ] else
                      PopupMenuItem(
                        value: _CategoryAction.restore,
                        child: Text(l10n.actionRestore),
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

  Future<void> _onAction(
    BuildContext context,
    _CategoryAction action,
    ExpenseCategory category,
  ) async {
    final cubit = context.read<ExpenseCategoriesCubit>();
    switch (action) {
      case _CategoryAction.rename:
        await _edit(context, category: category);
      case _CategoryAction.archive:
      case _CategoryAction.restore:
        final failure = await cubit.setActive(
          category.id,
          active: action == _CategoryAction.restore,
        );
        if (failure != null && context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(context.l10n.failureMessage(failure))),
            );
        }
    }
  }

  Future<void> _edit(BuildContext context, {ExpenseCategory? category}) {
    final cubit = context.read<ExpenseCategoriesCubit>();
    return showDialog<void>(
      context: context,
      builder: (_) => _CategoryDialog(
        initialName: category?.name ?? '',
        isRename: category != null,
        onSave: (name) => cubit.save(name, categoryId: category?.id),
      ),
    );
  }
}

/// Name dialog that stays open, with the reason, until the save succeeds.
class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({
    required this.initialName,
    required this.isRename,
    required this.onSave,
  });

  final String initialName;
  final bool isRename;
  final Future<Failure?> Function(String name) onSave;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late String _name = widget.initialName;
  Failure? _failure;
  bool _isSaving = false;

  Future<void> _submit() async {
    setState(() => _isSaving = true);
    final failure = await widget.onSave(_name);
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
      title: Text(
        widget.isRename ? l10n.renameCategoryTitle : l10n.actionAddCategory,
      ),
      content: AppTextField(
        label: l10n.categoryNameLabel,
        initialValue: widget.initialName,
        isRequired: true,
        autofocus: true,
        maxLength: SaveExpenseCategory.maxNameLength,
        textCapitalization: TextCapitalization.sentences,
        errorText: switch (_failure) {
          final Failure f => l10n.failureMessage(f),
          null => null,
        },
        onChanged: (value) => setState(() {
          _name = value;
          _failure = null;
        }),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}
