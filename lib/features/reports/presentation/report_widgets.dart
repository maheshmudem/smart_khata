import 'package:flutter/material.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/date_range.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_theme.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/form_fields.dart';
import 'package:smart_khata/core/widgets/formatters.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/features/reports/presentation/report_cubits.dart';
import 'package:smart_khata/l10n/generated/app_localizations.dart';

/// The earliest date a report can start from.
final BusinessDate reportEpoch = BusinessDate(2000, 1, 1);

extension ReportLabelsX on AppLocalizations {
  /// A period in words: one day, two dates, or everything up to [today].
  String periodText(BuildContext context, DateRange range, BusinessDate today) {
    final start = range.start;
    final end = range.end ?? today;
    if (start == null) return periodUpTo(AppDateFormat.date(context, end));
    if (start == end) return AppDateFormat.date(context, start);
    return periodBetween(
      AppDateFormat.date(context, start),
      AppDateFormat.date(context, end),
    );
  }
}

/// A label on the left and an amount on the right. The amount shrinks
/// rather than overflow at large text sizes.
class AmountRow extends StatelessWidget {
  const AmountRow({
    required this.label,
    required this.amount,
    this.strong = false,
    super.key,
  });

  final String label;
  final Money amount;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: strong ? theme.textTheme.titleSmall : null,
            ),
          ),
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
  }
}

/// A card with a title and rows under it.
class ReportCard extends StatelessWidget {
  const ReportCard({required this.children, this.title, super.key});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Small grey explanatory text under a report (FR-REP-008).
class ReportNote extends StatelessWidget {
  const ReportNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// WF-053: period shortcuts, or two dates of the owner's choice. The
/// chosen period is always written out underneath, with the note that
/// both days are included.
class PeriodFilter extends StatelessWidget {
  const PeriodFilter({
    required this.period,
    required this.today,
    required this.onChanged,
    this.presets = reportPresets,
    super.key,
  });

  static const List<DateRangePreset> reportPresets = [
    DateRangePreset.today,
    DateRangePreset.yesterday,
    DateRangePreset.thisWeek,
    DateRangePreset.thisMonth,
    DateRangePreset.lastMonth,
  ];

  final PeriodSelection period;
  final BusinessDate today;
  final ValueChanged<PeriodSelection> onChanged;
  final List<DateRangePreset> presets;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final range = period.range;
    final start = range.start ?? today;
    final end = range.end ?? today;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              for (final preset in presets)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(l10n.rangeName(preset)),
                    selected: period.preset == preset,
                    onSelected: (_) =>
                        onChanged(PeriodSelection.preset(preset, today)),
                  ),
                ),
              ChoiceChip(
                label: Text(l10n.rangeCustom),
                selected: period.isCustom,
                // Starts from the dates already showing.
                onSelected: (_) => onChanged(
                  PeriodSelection.custom(DateRange(start: start, end: end)),
                ),
              ),
            ],
          ),
        ),
        if (period.isCustom)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            // One under the other: two date fields do not fit side by
            // side at large text on a small phone.
            child: Column(
              children: [
                DateField(
                  label: l10n.fromDateLabel,
                  value: start,
                  firstDate: reportEpoch,
                  // The pickers cannot produce an end before the start.
                  lastDate: end,
                  onChanged: (date) => onChanged(
                    PeriodSelection.custom(DateRange(start: date, end: end)),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DateField(
                  label: l10n.toDateLabel,
                  value: end,
                  firstDate: start,
                  lastDate: today,
                  onChanged: (date) => onChanged(
                    PeriodSelection.custom(DateRange(start: start, end: date)),
                  ),
                ),
              ],
            ),
          ),
        ReportNote(
          '${l10n.periodLabel(l10n.periodText(context, range, today))} '
          '${l10n.periodBothIncluded}',
        ),
      ],
    );
  }
}
