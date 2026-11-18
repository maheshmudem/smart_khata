import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/load_state.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_cards.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/money_text.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/ledger/domain/ledger.dart';

final class PartyLedgerState extends Equatable {
  const PartyLedgerState({
    this.lines = const Loading(),
    this.limit = PartyLedgerCubit.pageSize,
    this.hasMore = false,
  });

  final LoadState<List<LedgerLine>> lines;
  final int limit;
  final bool hasMore;

  @override
  List<Object?> get props => [lines, limit, hasMore];
}

/// WF-023: one account's entries, newest first, paginated and live.
class PartyLedgerCubit extends Cubit<PartyLedgerState> {
  PartyLedgerCubit(this._ledger, this.accountId)
    : super(const PartyLedgerState()) {
    _subscribe();
  }

  static const int pageSize = 20;

  final LedgerRepository _ledger;
  final String accountId;
  StreamSubscription<Result<List<LedgerLine>>>? _subscription;

  void _subscribe() {
    unawaited(_subscription?.cancel());
    final limit = state.limit;
    // One extra row tells whether a next page exists.
    _subscription = _ledger.watchLedger(accountId, limit + 1).listen((result) {
      switch (result) {
        case Ok(:final value):
          emit(
            PartyLedgerState(
              lines: Loaded(value.take(limit).toList()),
              limit: limit,
              hasMore: value.length > limit,
            ),
          );
        case Err(:final failure):
          emit(
            PartyLedgerState(
              lines: LoadFailed(failure),
              limit: limit,
              hasMore: state.hasMore,
            ),
          );
      }
    });
  }

  void loadMore() {
    emit(
      PartyLedgerState(
        lines: state.lines,
        limit: state.limit + pageSize,
        hasMore: state.hasMore,
      ),
    );
    _subscribe();
  }

  void retry() {
    emit(PartyLedgerState(limit: state.limit));
    _subscribe();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

/// The entries card on the party page.
class PartyLedgerSection extends StatelessWidget {
  const PartyLedgerSection({required this.role, super.key});

  final PartyRole role;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = context.watch<PartyLedgerCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.ledgerTitle),
        switch (state.lines) {
          Loading() => const SizedBox(height: 120, child: LoadingView()),
          LoadFailed() => SizedBox(
            height: 260,
            child: ErrorView(
              message: l10n.errorLoadFailed,
              onRetry: context.read<PartyLedgerCubit>().retry,
            ),
          ),
          Loaded(value: final lines) when lines.isEmpty => AppCard(
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l10n.ledgerEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Loaded(value: final lines) => AppCard(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Column(
              children: [
                for (final (index, line) in lines.indexed) ...[
                  if (index > 0)
                    const Divider(
                      indent: AppSpacing.lg,
                      endIndent: AppSpacing.lg,
                    ),
                  _LedgerRow(line: line, role: role),
                ],
              ],
            ),
          ),
        },
        if (state.hasMore) ...[
          const SizedBox(height: AppSpacing.sm),
          AppSecondaryButton(
            label: l10n.actionLoadMore,
            onPressed: context.read<PartyLedgerCubit>().loadMore,
          ),
        ],
      ],
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.line, required this.role});

  final LedgerLine line;
  final PartyRole role;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final zone = ShopTimeZone.resolve(ShopTimeZone.defaultName);
    String dayText(DateTime instant) {
      final day = BusinessDate.fromInstant(instant, zone);
      return DateFormat.MMMd(
        locale,
      ).format(DateTime.utc(day.year, day.month, day.day));
    }

    final isCharge = line.signedAmount.isPositive;
    final details = [
      dayText(line.effectiveAt),
      if (line.method case final method?) l10n.methodLabel(method),
      if (line.dueAt case final due?) l10n.ledgerDue(dayText(due)),
    ].join(' · ');
    final runningKind = BalanceKind.of(role, line.runningBalance);
    final description = line.description;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isCharge
                  ? scheme.surfaceContainerHigh
                  : scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCharge ? Icons.north_east_rounded : Icons.south_west_rounded,
              size: AppSizes.iconSm,
              color: isCharge ? scheme.onSurfaceVariant : scheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.transactionLabel(line.type),
                  style: theme.textTheme.titleSmall,
                ),
                if (description != null)
                  Text(description, style: theme.textTheme.bodyMedium),
                Text(
                  details,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // The entry's effect, signed as on a statement; the type
                // label on the left says what it was.
                Text(
                  '${isCharge ? '+' : '−'}'
                  '${MoneyFormatter.format(line.signedAmount.abs())}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  l10n.ledgerBalanceAfter(
                    MoneyFormatter.format(line.runningBalance.abs()),
                  ),
                  textAlign: TextAlign.end,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  l10n.balanceLabel(runningKind),
                  textAlign: TextAlign.end,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: balanceColor(context, runningKind),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
