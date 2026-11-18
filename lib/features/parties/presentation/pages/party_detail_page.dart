import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/contact_text.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/load_state.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_colors.dart';
import 'package:smart_khata/core/theme/app_theme.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_cards.dart';
import 'package:smart_khata/core/widgets/dialogs.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/ledger/domain/entry_type.dart';
import 'package:smart_khata/features/ledger/domain/ledger.dart';
import 'package:smart_khata/features/ledger/presentation/party_ledger.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_use_cases.dart';
import 'package:smart_khata/features/parties/presentation/bloc/party_detail_cubit.dart';
import 'package:smart_khata/features/parties/presentation/widgets/opening_balance_sheet.dart';

/// WF-022: one party. A dual-role party has a role switcher; its customer
/// and supplier balances are shown separately and never netted.
class PartyDetailPage extends StatelessWidget {
  const PartyDetailPage({
    required this.postOpeningBalance,
    required this.newOperationId,
    required this.ledger,
    super.key,
  });

  final PostOpeningBalance postOpeningBalance;

  /// Creates the operation ID when a financial form opens.
  final String Function() newOperationId;

  /// Source of the entries list on the page.
  final LedgerRepository ledger;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<PartyDetailCubit, PartyDetailState>(
      listenWhen: (a, b) =>
          a.actionFailure != b.actionFailure && b.actionFailure != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failureMessage(state.actionFailure!))),
        );
        context.read<PartyDetailCubit>().clearActionFailure();
      },
      builder: (context, state) {
        final cubit = context.read<PartyDetailCubit>();
        return switch (state.details) {
          Loading() => Scaffold(appBar: AppBar(), body: const LoadingView()),
          LoadFailed() => Scaffold(
            appBar: AppBar(),
            body: ErrorView(
              message: l10n.errorLoadFailed,
              onRetry: cubit.retry,
            ),
          ),
          Loaded(value: null) => Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icon: Icons.person_off_outlined,
              title: l10n.errorNotFound,
            ),
          ),
          Loaded(value: final party?) => _Loaded(
            party: party,
            role: state.role ?? party.accounts.first.role,
            isUpdating: state.isUpdating,
            postOpeningBalance: postOpeningBalance,
            newOperationId: newOperationId,
            ledger: ledger,
          ),
        };
      },
    );
  }
}

enum _MenuAction { archive, reactivate }

class _Loaded extends StatelessWidget {
  const _Loaded({
    required this.party,
    required this.role,
    required this.isUpdating,
    required this.postOpeningBalance,
    required this.newOperationId,
    required this.ledger,
  });

  final PartyDetails party;
  final PartyRole role;
  final bool isUpdating;
  final PostOpeningBalance postOpeningBalance;
  final String Function() newOperationId;

  /// Source of the entries list on the page.
  final LedgerRepository ledger;

  /// Opens an entry form for this party. An archived party takes no new
  /// entries until reactivated (FR-PAR-007), so say so instead.
  void _openEntry(BuildContext context, EntryType type) {
    if (party.isArchived) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.errorPartyArchived)),
        );
      return;
    }
    unawaited(context.push(AppRoutes.entry(type, partyId: party.id)));
  }

  Future<void> _onMenu(BuildContext context, _MenuAction action) async {
    final l10n = context.l10n;
    final cubit = context.read<PartyDetailCubit>();
    switch (action) {
      case _MenuAction.archive:
        final confirmed = await showConfirmDialog(
          context,
          title: l10n.archiveTitle,
          message: l10n.archiveBody,
          confirmLabel: l10n.actionArchive,
          cancelLabel: l10n.actionCancel,
        );
        if (confirmed) await cubit.setArchived(archived: true);
      case _MenuAction.reactivate:
        await cubit.setArchived(archived: false);
    }
  }

  Future<void> _addOpening(
    BuildContext context,
    PartyAccountSummary account,
  ) async {
    final saved = await showOpeningBalanceSheet(
      context,
      postOpeningBalance: postOpeningBalance,
      accountId: account.accountId,
      operationId: newOperationId(),
      role: account.role,
      currentBalance: account.balance,
    );
    if (saved && context.mounted) {
      showSavedMessage(context, context.l10n.openingBalanceSaved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cubit = context.read<PartyDetailCubit>();
    final account = party.account(role) ?? party.accounts.first;
    final isCustomer = account.role == PartyRole.customer;
    final canAddOpening = !account.hasOpeningBalance && !party.isArchived;

    return Scaffold(
      // The gradient header runs under a transparent, white app bar.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppGradients.onGradient,
        scrolledUnderElevation: 0,
        actions: [
          PopupMenuButton<_MenuAction>(
            tooltip: l10n.tooltipMoreActions,
            enabled: !isUpdating,
            iconColor: AppGradients.onGradient,
            onSelected: (action) => unawaited(_onMenu(context, action)),
            itemBuilder: (_) => [
              if (party.isArchived)
                PopupMenuItem(
                  value: _MenuAction.reactivate,
                  child: Text(l10n.actionReactivate),
                )
              else
                PopupMenuItem(
                  value: _MenuAction.archive,
                  child: Text(l10n.actionArchive),
                ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _ProfileHeader(
            party: party,
            account: account,
            onRoleSelected: cubit.selectRole,
          ),
          Transform.translate(
            offset: const Offset(0, -AppSpacing.xxl),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CircleAction(
                        icon: isCustomer
                            ? Icons.south_west_rounded
                            : Icons.inventory_2_rounded,
                        label: isCustomer
                            ? l10n.actionGiveCredit
                            : l10n.actionAddPurchase,
                        onTap: () => _openEntry(
                          context,
                          EntryType.chargeFor(account.role),
                        ),
                      ),
                    ),
                    Expanded(
                      child: CircleAction(
                        icon: isCustomer
                            ? Icons.payments_rounded
                            : Icons.north_east_rounded,
                        label: isCustomer
                            ? l10n.actionReceivePayment
                            : l10n.actionPaySupplier,
                        onTap: () => _openEntry(
                          context,
                          EntryType.paymentFor(account.role),
                        ),
                      ),
                    ),
                    if (canAddOpening)
                      Expanded(
                        child: CircleAction(
                          icon: Icons.playlist_add_rounded,
                          label: l10n.openingBalanceTitle,
                          onTap: () => unawaited(_addOpening(context, account)),
                        ),
                      ),
                    Expanded(
                      child: CircleAction(
                        icon: Icons.edit_rounded,
                        label: l10n.actionEdit,
                        onTap: () =>
                            context.push(AppRoutes.partyEdit(party.id)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (party.isArchived) ...[
                  _Notice(
                    icon: Icons.archive_outlined,
                    text: l10n.archivedBanner,
                    actionLabel: l10n.actionReactivate,
                    onAction: isUpdating
                        ? null
                        : () => unawaited(cubit.setArchived(archived: false)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (account.hasOpeningBalance)
                  _Notice(
                    icon: Icons.check_circle_rounded,
                    text: l10n.openingBalanceRecorded,
                  )
                else if (canAddOpening)
                  AppCard(
                    onTap: () => unawaited(_addOpening(context, account)),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: AppRadius.control,
                          ),
                          child: Icon(
                            Icons.playlist_add_rounded,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.openingBalanceAction,
                                style: theme.textTheme.titleSmall,
                              ),
                              Text(
                                l10n.openingBalanceIntro,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                // One list per account: switching role shows that role's
                // own entries, never a merged view.
                BlocProvider(
                  key: ValueKey(account.accountId),
                  create: (_) => PartyLedgerCubit(ledger, account.accountId),
                  child: PartyLedgerSection(role: account.role),
                ),
                SectionHeader(title: l10n.partyContactSection),
                _ContactCard(party: party),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The gradient top of the page: who the party is, which role is shown,
/// and that role's balance with its direction in words.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.party,
    required this.account,
    required this.onRoleSelected,
  });

  final PartyDetails party;
  final PartyAccountSummary account;
  final ValueChanged<PartyRole> onRoleSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final phone = party.phone;
    final rolesText = party.accounts.length > 1
        ? l10n.partyBothRoles
        : l10n.roleLabel(party.accounts.first.role);
    final isCustomer = account.role == PartyRole.customer;
    final kind = BalanceKind.of(account.role, account.balance);
    final label = l10n.balanceLabel(kind);
    final amount = MoneyFormatter.format(account.balance.abs());
    final limit = party.creditLimit;
    final topInset = MediaQuery.paddingOf(context).top + kToolbarHeight;

    return GradientSurface(
      raised: false,
      gradient: isCustomer ? AppGradients.customers : AppGradients.suppliers,
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(AppRadius.xl + AppSpacing.xs),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        topInset,
        AppSpacing.lg,
        AppSpacing.xxl + AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSizes.circleAction + AppSpacing.sm,
                height: AppSizes.circleAction + AppSpacing.sm,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppGradients.onGradient.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppGradients.onGradient.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
                child: ExcludeSemantics(
                  child: Text(
                    PartyAvatar.initialsOf(party.name),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppGradients.onGradient,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        party.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppGradients.onGradient,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      [
                        rolesText,
                        if (phone != null) ContactText.displayPhone(phone),
                      ].join(' · '),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppGradients.onGradientMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (party.accounts.length > 1) ...[
            const SizedBox(height: AppSpacing.lg),
            _RoleToggle(
              roles: [for (final a in party.accounts) a.role],
              selected: account.role,
              onSelected: onRoleSelected,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Semantics(
            container: true,
            excludeSemantics: true,
            label: l10n.amountSemantics(label, amount),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppGradients.onGradientMuted,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    amount,
                    style: AppTheme.amountStyle(
                      theme.textTheme.displayMedium,
                    )?.copyWith(color: AppGradients.onGradient),
                  ),
                ),
              ],
            ),
          ),
          if (isCustomer && limit != null)
            Text(
              l10n.partyCreditLimitValue(MoneyFormatter.format(limit)),
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppGradients.onGradientMuted,
              ),
            ),
        ],
      ),
    );
  }
}

/// Customer / Supplier switch drawn as glass pills on the gradient.
class _RoleToggle extends StatelessWidget {
  const _RoleToggle({
    required this.roles,
    required this.selected,
    required this.onSelected,
  });

  final List<PartyRole> roles;
  final PartyRole selected;
  final ValueChanged<PartyRole> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppGradients.onGradient.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Row(
          children: [
            for (final role in roles)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: role == selected,
                  child: Material(
                    color: role == selected
                        ? AppGradients.onGradient
                        : Colors.transparent,
                    shape: const StadiumBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => onSelected(role),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: AppSizes.minTouchTarget - AppSpacing.sm,
                        ),
                        child: Center(
                          child: Text(
                            l10n.roleLabel(role),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: role == selected
                                  ? (role == PartyRole.customer
                                        ? AppColors.brandEmerald
                                        : AppColors.brandSlate)
                                  : AppGradients.onGradient,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: theme.colorScheme.onSecondaryContainer),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            if (actionLabel != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.party});

  final PartyDetails party;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = [
      if (party.phone case final phone?)
        InfoRow(
          icon: Icons.phone_outlined,
          label: l10n.phoneLabel,
          value: ContactText.displayPhone(phone),
        ),
      if (party.alternatePhone case final phone?)
        InfoRow(
          icon: Icons.phone_forwarded_outlined,
          label: l10n.partyAltPhoneLabel,
          value: ContactText.displayPhone(phone),
        ),
      if (party.address case final address?)
        InfoRow(
          icon: Icons.home_outlined,
          label: l10n.addressLabel,
          value: address,
        ),
      if (party.locality case final locality?)
        InfoRow(
          icon: Icons.place_outlined,
          label: l10n.localityLabel,
          value: locality,
        ),
      if (party.notes case final notes?)
        InfoRow(
          icon: Icons.notes_outlined,
          label: l10n.partyNotesLabel,
          value: notes,
        ),
    ];
    return AppCard(
      child: rows.isEmpty
          ? Text(
              l10n.partyNoContact,
              style: Theme.of(context).textTheme.bodyMedium,
            )
          : Column(children: rows),
    );
  }
}
