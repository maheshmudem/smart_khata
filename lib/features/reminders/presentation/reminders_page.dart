import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_colors.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/form_fields.dart';
import 'package:smart_khata/core/widgets/formatters.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/reminders/domain/reminders.dart';
import 'package:smart_khata/features/reminders/presentation/reminders_cubit.dart';
import 'package:smart_khata/l10n/generated/app_localizations.dart';

extension ReminderTextsX on AppLocalizations {
  /// The owner's notification in this language.
  ReminderTexts get reminderTexts => ReminderTexts(
    title: appTitle,
    body: reminderNotificationBody,
    channelName: remindersTitle,
  );
}

/// WF-060: dues that have a due date, customers and suppliers apart.
///
/// Nothing here sends anything by itself. "Share reminder" opens the
/// phone's share sheet with a message the owner has just read; "Remind
/// me" sets a notification for the owner on this phone.
class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<RemindersCubit>();

    return BlocConsumer<RemindersCubit, RemindersState>(
      listenWhen: (before, after) => after.noticeCount > before.noticeCount,
      listener: (context, state) {
        final text = switch (state.notice) {
          ReminderNotice.shareFailed => l10n.shareFailed,
          ReminderNotice.reminderSet => l10n.reminderSet,
          ReminderNotice.reminderCancelled => l10n.reminderCancelled,
          ReminderNotice.notificationsOff => l10n.reminderNotificationsOff,
          ReminderNotice.failed => l10n.errorSaveFailed,
          null => null,
        };
        if (text == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(text)));
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.remindersTitle)),
          body: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: SegmentedButton<PartyRole>(
                  segments: [
                    ButtonSegment(
                      value: PartyRole.customer,
                      label: Text(l10n.partiesTabCustomers),
                    ),
                    ButtonSegment(
                      value: PartyRole.supplier,
                      label: Text(l10n.partiesTabSuppliers),
                    ),
                  ],
                  selected: {state.role},
                  showSelectedIcon: false,
                  onSelectionChanged: (roles) =>
                      cubit.roleSelected(roles.single),
                ),
              ),
              Padding(
                padding: AppSpacing.page,
                child: Text(
                  state.role == PartyRole.customer
                      ? l10n.remindersExplainCustomers
                      : l10n.remindersExplainSuppliers,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              switch (state.status) {
                LoadStatus.loading => const SizedBox(
                  height: 96,
                  child: LoadingView(),
                ),
                LoadStatus.failure => ErrorView(
                  message: l10n.failureMessage(
                    state.failure ?? const UnexpectedFailure(),
                    context: FailureContext.loading,
                  ),
                  onRetry: cubit.retry,
                ),
                LoadStatus.loaded when state.items.isEmpty => Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(l10n.remindersEmpty, textAlign: TextAlign.center),
                ),
                LoadStatus.loaded => Column(
                  children: [
                    for (final item in state.items) ...[
                      _DueTile(item: item, shopName: state.shopName),
                      const Divider(),
                    ],
                  ],
                ),
              },
            ],
          ),
        );
      },
    );
  }
}

class _DueTile extends StatelessWidget {
  const _DueTile({required this.item, required this.shopName});

  final DueItem item;
  final String shopName;

  Future<void> _share(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<RemindersCubit>();
    final message = l10n.reminderMessage(
      item.partyName,
      MoneyFormatter.format(item.balance.abs()),
      shopName,
    );
    final lastShared = item.lastSharedAt;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.reminderPreviewTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              if (lastShared != null && cubit.sharedRecently(item)) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.reminderSharedRecently(
                    AppDateFormat.instant(context, lastShared),
                  ),
                  style: TextStyle(color: context.semanticColors.warning),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.actionShareReminder),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.share(item, message);
  }

  Future<void> _remindMe(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<RemindersCubit>();
    final first = cubit.today.addDays(1);
    final picked = await showDatePicker(
      context: context,
      helpText: l10n.actionRemindMe,
      initialDate: DateTime(first.year, first.month, first.day),
      firstDate: DateTime(first.year, first.month, first.day),
      lastDate: DateTime(
        first.year,
        first.month,
        first.day + ReminderPolicy.maxDaysAhead,
      ),
    );
    if (picked == null) return;
    await cubit.remindMe(
      item,
      BusinessDate(picked.year, picked.month, picked.day),
      l10n.reminderTexts,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cubit = context.read<RemindersCubit>();
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final lastShared = item.lastSharedAt;
    final remindAt = item.remindAt;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => unawaited(
              context.push(
                AppRoutes.partyLedger(item.partyId, item.accountId),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.partyName, style: theme.textTheme.titleSmall),
                Text(
                  l10n.balanceText(
                    BalanceKind.of(item.role, item.balance),
                    item.balance,
                  ),
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  [
                    if (item.isOverdue)
                      l10n.reminderOverdue(
                        MoneyFormatter.format(item.overdue),
                      ),
                    l10n.reminderOldestDue(
                      AppDateFormat.date(context, item.oldestDueDate),
                    ),
                  ].join(' · '),
                  style: item.isOverdue
                      ? muted?.copyWith(color: context.semanticColors.warning)
                      : muted,
                ),
                if (lastShared != null)
                  Text(
                    l10n.reminderLastShared(
                      AppDateFormat.instant(context, lastShared),
                    ),
                    style: muted,
                  ),
                if (remindAt != null)
                  Text(
                    l10n.reminderSetFor(
                      AppDateFormat.instant(context, remindAt),
                    ),
                    style: muted,
                  ),
              ],
            ),
          ),
          // Wraps instead of overflowing at large text on a small phone.
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              if (item.role == PartyRole.customer)
                TextButton.icon(
                  icon: const Icon(Icons.share_outlined),
                  label: Text(l10n.actionShareReminder),
                  onPressed: () => unawaited(_share(context)),
                ),
              if (remindAt == null)
                TextButton.icon(
                  icon: const Icon(Icons.notifications_none),
                  label: Text(l10n.actionRemindMe),
                  onPressed: () => unawaited(_remindMe(context)),
                )
              else
                TextButton.icon(
                  icon: const Icon(Icons.notifications_off_outlined),
                  label: Text(l10n.actionCancelReminder),
                  onPressed: () => unawaited(cubit.cancelReminder(item)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
