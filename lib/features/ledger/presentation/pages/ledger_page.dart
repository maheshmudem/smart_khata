import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/formatters.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/money_text.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/ledger/presentation/cubit/ledger_cubits.dart';
import 'package:smart_khata/features/ledger/presentation/widgets/ledger_line_tile.dart';

/// WF-023: one role's full history with a running balance.
class LedgerPage extends StatelessWidget {
  const LedgerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<LedgerCubit>();

    return BlocBuilder<LedgerCubit, LedgerState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state.partyName.isEmpty ? l10n.ledgerTitle : state.partyName,
            ),
          ),
          body: switch (state.status) {
            LoadStatus.loading => const LoadingView(),
            LoadStatus.failure => ErrorView(
              message: l10n.failureMessage(
                state.failure ?? const UnexpectedFailure(),
                context: FailureContext.loading,
              ),
              onRetry: state.failure is NotFoundFailure ? null : cubit.retry,
            ),
            LoadStatus.loaded => _LedgerList(
              state: state,
              onLoadMore: cubit.loadMore,
            ),
          },
        );
      },
    );
  }
}

/// The balance header scrolls with the lines, so at large text sizes the
/// whole page still scrolls as one.
class _LedgerList extends StatelessWidget {
  const _LedgerList({required this.state, required this.onLoadMore});

  final LedgerState state;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final role = state.role;
    final kind = state.balanceKind;
    final lines = state.lines;

    // Row 0 is the header; then the lines; then "nothing yet" or "more".
    final hasFooter = lines.isEmpty || state.hasMore;
    return ListView.separated(
      itemCount: 1 + lines.length + (hasFooter ? 1 : 0),
      separatorBuilder: (context, index) =>
          index == 0 ? const SizedBox.shrink() : const Divider(),
      itemBuilder: (context, index) {
        if (index == 0) {
          if (role == null || kind == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.roleLabel(role),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    BalanceSummary(kind: kind, amount: state.balance),
                  ],
                ),
              ),
            ),
          );
        }

        final lineIndex = index - 1;
        if (lineIndex == lines.length) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: lines.isEmpty
                ? Text(
                    l10n.ledgerEmptyTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                // Older lines are never silently left out.
                : TextButton(
                    onPressed: onLoadMore,
                    child: Text(l10n.actionLoadMore),
                  ),
          );
        }

        final line = lines[lineIndex];
        return LedgerLineTile(
          transactionType: line.transactionType,
          amount: line.amount,
          effectiveAt: line.effectiveAt,
          description: line.description,
          dueAt: line.dueAt,
          isReversed: line.isReversed,
          runningBalance: role == null ? null : (role, line.runningBalance),
          onTap: () => unawaited(
            context.push(AppRoutes.transaction(line.transactionId)),
          ),
        );
      },
    );
  }
}
