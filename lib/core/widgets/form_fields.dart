import 'package:flutter/material.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/formatters.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/l10n/generated/app_localizations.dart';

/// A tappable field that shows a business date and opens the date picker.
///
/// [value] `null` shows [emptyText]; with [onCleared] a clear button
/// appears, for optional dates such as a due date.
class DateField extends StatelessWidget {
  const DateField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.emptyText,
    this.errorText,
    this.onCleared,
    this.clearTooltip,
    super.key,
  });

  final String label;
  final BusinessDate? value;
  final ValueChanged<BusinessDate> onChanged;
  final BusinessDate firstDate;
  final BusinessDate lastDate;
  final String? emptyText;
  final String? errorText;
  final VoidCallback? onCleared;
  final String? clearTooltip;

  static DateTime _toDateTime(BusinessDate d) =>
      DateTime(d.year, d.month, d.day);

  Future<void> _pick(BuildContext context) async {
    final initial = value ?? lastDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDateTime(
        initial.compareTo(firstDate) < 0
            ? firstDate
            : (initial.compareTo(lastDate) > 0 ? lastDate : initial),
      ),
      firstDate: _toDateTime(firstDate),
      lastDate: _toDateTime(lastDate),
    );
    if (picked != null) {
      onChanged(BusinessDate(picked.year, picked.month, picked.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = value;
    final showClear = date != null && onCleared != null;
    return InkWell(
      borderRadius: AppRadius.control,
      onTap: () => _pick(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          suffixIcon: showClear
              ? IconButton(
                  tooltip: clearTooltip,
                  icon: const Icon(Icons.close),
                  onPressed: onCleared,
                )
              : const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          date == null ? (emptyText ?? '') : AppDateFormat.date(context, date),
        ),
      ),
    );
  }
}

/// The Review box of a financial form: label/value rows, the last one
/// emphasised, with an optional note (wireframes 1.4).
class ReviewCard extends StatelessWidget {
  const ReviewCard({required this.rows, this.note, this.warning, super.key});

  /// Label → value. The final row is the resulting balance.
  final List<(String, String)> rows;
  final String? note;

  /// Shown in the warning colour, e.g. a crossed credit limit.
  final String? warning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.reviewTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            for (final (index, (label, value)) in rows.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(label)),
                    const SizedBox(width: AppSpacing.md),
                    Flexible(
                      child: Text(
                        value,
                        textAlign: TextAlign.end,
                        style: index == rows.length - 1
                            ? theme.textTheme.titleMedium
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            if (warning != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: theme.colorScheme.error,
                    size: AppSizes.iconMd,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      warning!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (note != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(note!, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

extension BalanceTextX on AppLocalizations {
  /// A balance in words: "Customer owes ₹1,800", or "Nothing due".
  String balanceText(BalanceKind kind, Money balance) =>
      kind == BalanceKind.settled
      ? balanceLabel(kind)
      : '${balanceLabel(kind)} ${MoneyFormatter.format(balance.abs())}';
}
