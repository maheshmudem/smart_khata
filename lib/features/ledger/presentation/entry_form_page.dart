import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/contact_text.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/load_state.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_cards.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/core/widgets/dialogs.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/money_text.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/ledger/domain/entry_type.dart';
import 'package:smart_khata/features/ledger/domain/ledger.dart';
import 'package:smart_khata/features/ledger/presentation/entry_form_bloc.dart';
import 'package:smart_khata/l10n/generated/app_localizations.dart';

/// The title for each entry type.
String entryTitle(AppLocalizations l10n, EntryType type) => switch (type) {
  EntryType.customerCredit => l10n.actionGiveCredit,
  EntryType.customerPayment => l10n.actionReceivePayment,
  EntryType.supplierPurchase => l10n.actionAddPurchase,
  EntryType.supplierPayment => l10n.actionPaySupplier,
};

/// WF-030 to WF-033: give credit, receive payment, add purchase, pay
/// supplier. Success is shown only after the commit returns.
class EntryFormPage extends StatelessWidget {
  const EntryFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<EntryFormBloc, EntryFormState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) {
        if (state.status != SubmitStatus.success) return;
        final after = state.balanceAfter;
        if (after != null) {
          final kind = BalanceKind.of(state.type.role, after);
          showSavedMessage(
            context,
            l10n.entrySaved(
              l10n.amountSemantics(
                l10n.balanceLabel(kind),
                MoneyFormatter.format(after.abs()),
              ),
            ),
          );
        }
        context.pop();
      },
      builder: (context, state) => DiscardChangesGuard(
        isDirty: state.isDirty && state.status != SubmitStatus.success,
        child: Scaffold(
          appBar: AppBar(title: Text(entryTitle(l10n, state.type))),
          body: state.isLoading
              ? const LoadingView()
              : Column(
                  children: [
                    Expanded(child: _Fields(state: state)),
                    _SaveBar(state: state),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Fields extends StatelessWidget {
  const _Fields({required this.state});

  final EntryFormState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<EntryFormBloc>();
    final party = state.party;
    final amountError = state.errors[EntryFields.amount];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (party == null)
          _PartyPicker(state: state)
        else ...[
          _SelectedParty(
            party: party,
            role: state.type.role,
            canChange: bloc.partyId == null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MoneyAmountField(
                  label: l10n.amountLabel,
                  autofocus: true,
                  initialValue: state.amount,
                  errorText: amountError == null
                      ? null
                      : l10n.validationMessage(amountError),
                  onChanged: (m) => bloc.add(EntryAmountChanged(m)),
                ),
                if (state.type.isPayment) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.entryMethodLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final method in offeredPaymentMethods)
                        ChoiceChip(
                          label: Text(l10n.methodLabel(method)),
                          selected: state.method == method,
                          showCheckmark: false,
                          avatar: Icon(
                            _methodIcon(method),
                            size: AppSizes.iconSm,
                            color: state.method == method
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.primary,
                          ),
                          onSelected: (_) =>
                              bloc.add(EntryMethodChanged(method)),
                        ),
                    ],
                  ),
                ],
                if (state.type.isCharge) ...[
                  const SizedBox(height: AppSpacing.md),
                  _DueDateTile(dueAt: state.dueAt),
                ],
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: l10n.entryNoteLabel,
                  helperText: l10n.entryNoteHint,
                  initialValue: state.note,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 200,
                  onChanged: (v) => bloc.add(EntryNoteChanged(v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _Review(state: state),
        ],
      ],
    );
  }

  static IconData _methodIcon(PaymentMethod method) => switch (method) {
    PaymentMethod.cash => Icons.payments_rounded,
    PaymentMethod.upi => Icons.qr_code_2_rounded,
    _ => Icons.account_balance_rounded,
  };
}

/// Search and pick the customer or supplier, or add a new one.
class _PartyPicker extends StatelessWidget {
  const _PartyPicker({required this.state});

  final EntryFormState state;

  Future<void> _addNew(BuildContext context) async {
    final bloc = context.read<EntryFormBloc>();
    final partyId = await context.push<String>(
      AppRoutes.partyNewToPick(state.type.role),
    );
    if (partyId != null) bloc.add(EntryPartyCreated(partyId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bloc = context.read<EntryFormBloc>();
    final isCustomer = state.type.role == PartyRole.customer;
    final partyError = state.errors[EntryFields.party];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isCustomer ? l10n.entryChooseCustomer : l10n.entryChooseSupplier,
          style: theme.textTheme.titleMedium,
        ),
        if (partyError != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              l10n.entryPartyRequired,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        PartySearchField(
          hintText: l10n.partiesSearchHint,
          onChanged: (text) => bloc.add(EntrySearchChanged(text)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  child: const Icon(Icons.person_add_alt_1_rounded),
                ),
                title: Text(
                  isCustomer ? l10n.actionAddCustomer : l10n.actionAddSupplier,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                onTap: () => unawaited(_addNew(context)),
              ),
              ...switch (state.candidates) {
                Loading() => const [
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: LoadingView(),
                  ),
                ],
                LoadFailed() => [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(l10n.errorLoadFailed),
                  ),
                ],
                Loaded(value: final items) when items.isEmpty => [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      l10n.entryNoMatch,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
                Loaded(value: final items) => [
                  for (final item in items) ...[
                    const Divider(indent: AppSpacing.lg),
                    // A flexible row, not a ListTile: at large text the
                    // balance must wrap, never squeeze out the name.
                    InkWell(
                      onTap: () => bloc.add(EntryPartyPicked(item)),
                      child: Padding(
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
                                  Text(
                                    item.name,
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  if (item.phone case final phone?)
                                    Text(
                                      ContactText.displayPhone(phone),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Flexible(
                              child: _BalanceChip(
                                kind: BalanceKind.of(item.role, item.balance),
                                amount: item.balance,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              },
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectedParty extends StatelessWidget {
  const _SelectedParty({
    required this.party,
    required this.role,
    required this.canChange,
  });

  final EntryParty party;
  final PartyRole role;
  final bool canChange;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final phone = party.phone;
    return AppCard(
      child: Row(
        children: [
          PartyAvatar(name: party.name),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(party.name, style: theme.textTheme.titleMedium),
                Text(
                  [
                    l10n.roleLabel(role),
                    if (phone != null) ContactText.displayPhone(phone),
                  ].join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (canChange)
            TextButton(
              onPressed: () =>
                  context.read<EntryFormBloc>().add(const EntryPartyCleared()),
              child: Text(l10n.entryChangeParty),
            ),
        ],
      ),
    );
  }
}

class _DueDateTile extends StatelessWidget {
  const _DueDateTile({required this.dueAt});

  final DateTime? dueAt;

  Future<void> _pick(BuildContext context) async {
    final bloc = context.read<EntryFormBloc>();
    final zone = ShopTimeZone.resolve(ShopTimeZone.defaultName);
    final today = bloc.nowUtc;
    final picked = await showDatePicker(
      context: context,
      initialDate: today.add(const Duration(days: 7)),
      firstDate: today.subtract(const Duration(days: 365)),
      lastDate: today.add(const Duration(days: 365 * 3)),
    );
    if (picked == null) return;
    // Stored as the start of that day in the shop's zone (ADR-021).
    bloc.add(
      EntryDueDateChanged(
        BusinessDate(picked.year, picked.month, picked.day).startUtc(zone),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final due = dueAt;
    if (due == null) {
      return OutlinedButton.icon(
        onPressed: () => unawaited(_pick(context)),
        icon: const Icon(Icons.event_rounded),
        label: Text(l10n.entryAddDueDate),
      );
    }
    final day = BusinessDate.fromInstant(
      due,
      ShopTimeZone.resolve(ShopTimeZone.defaultName),
    );
    final text = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(DateTime.utc(day.year, day.month, day.day));
    return InputDecorator(
      decoration: InputDecoration(
        labelText: l10n.entryDueDate,
        prefixIcon: const Icon(Icons.event_rounded),
        suffixIcon: IconButton(
          tooltip: l10n.entryRemoveDueDate,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.read<EntryFormBloc>().add(
            const EntryDueDateChanged(null),
          ),
        ),
      ),
      child: InkWell(
        onTap: () => unawaited(_pick(context)),
        child: Text(text, style: theme.textTheme.bodyLarge),
      ),
    );
  }
}

/// Current balance, this entry and the balance after saving, each with its
/// direction in words (UI spec: financial forms have a Review section).
class _Review extends StatelessWidget {
  const _Review({required this.state});

  final EntryFormState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final party = state.party!;
    final role = state.type.role;
    final after = state.preview!;
    final excess = state.excess;

    Widget line(String caption, Widget value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              caption,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(child: value),
        ],
      ),
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.reviewTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          line(
            l10n.reviewCurrent,
            _BalanceChip(
              kind: BalanceKind.of(role, party.balance),
              amount: party.balance,
            ),
          ),
          line(
            l10n.reviewThisEntry,
            Text(
              '${state.change.isNegative ? '−' : '+'}'
              '${MoneyFormatter.format(state.change.abs())}',
              textAlign: TextAlign.end,
              style: theme.textTheme.titleSmall,
            ),
          ),
          const Divider(height: AppSpacing.lg),
          line(
            l10n.reviewAfter,
            _BalanceChip(
              kind: BalanceKind.of(role, after),
              amount: after,
              emphasised: true,
            ),
          ),
          if (excess.isPositive) ...[
            const SizedBox(height: AppSpacing.sm),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: AppRadius.control,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: AppSizes.iconSm,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.entryExcessAdvance(MoneyFormatter.format(excess)),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A balance as a small label-and-amount pair, right aligned.
class _BalanceChip extends StatelessWidget {
  const _BalanceChip({
    required this.kind,
    required this.amount,
    this.emphasised = false,
  });

  final BalanceKind kind;
  final Money amount;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: l10n.amountSemantics(
        l10n.balanceLabel(kind),
        MoneyFormatter.format(amount.abs()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          MoneyText(
            amount.abs(),
            style: emphasised
                ? theme.textTheme.titleLarge
                : theme.textTheme.titleSmall,
          ),
          Text(
            l10n.balanceLabel(kind),
            textAlign: TextAlign.end,
            style: theme.textTheme.labelSmall?.copyWith(
              color: balanceColor(context, kind),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.state});

  final EntryFormState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final failure = state.failure;
    return FormActionBar(
      children: [
        if (failure != null) ...[
          InlineError(message: l10n.failureMessage(failure)),
          const SizedBox(height: AppSpacing.md),
        ],
        AppPrimaryButton(
          label: l10n.actionSave,
          icon: Icons.check_rounded,
          isLoading: state.status == SubmitStatus.submitting,
          onPressed: state.party == null
              ? null
              : () => context.read<EntryFormBloc>().add(
                  const EntryFormSubmitted(),
                ),
        ),
      ],
    );
  }
}
