import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/export/csv_writer.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/widgets/form_fields.dart';
import 'package:smart_khata/core/widgets/formatters.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/features/reports/domain/reports.dart';
import 'package:smart_khata/l10n/generated/app_localizations.dart';

/// Turns a report into the text or CSV that is handed to the share sheet.
///
/// The wording comes from the translations, so a statement is shared in
/// the language the owner is using. Only what is on the screen is
/// exported: one party's statement never carries another party's data.
abstract final class ReportExports {
  /// A column of amounts names its currency by ISO code.
  static String _inr(String name) => '$name (INR)';

  static BusinessDate _day(DateTime instantUtc) =>
      BusinessDate.fromInstant(instantUtc, ShopTimeZone.resolve(null));

  /// A statement as plain text for a chat or SMS app.
  static String statementText({
    required AppLocalizations l10n,
    required PartyStatement statement,
    required String shopName,
    required String periodText,
    required String Function(BusinessDate date) formatDate,
  }) {
    final role = statement.role;
    String balance(StatementLine? line) {
      final amount = line?.balanceAfter ?? statement.openingBalance;
      return l10n.balanceText(BalanceKind.of(role, amount), amount);
    }

    final closing = statement.closingBalance;
    final closingText = l10n.balanceText(
      BalanceKind.of(role, closing),
      closing,
    );
    return [
      if (shopName.isNotEmpty) shopName,
      '${statement.partyName} (${l10n.roleLabel(role)})',
      l10n.periodLabel(periodText),
      l10n.statementCurrencyNote,
      '',
      '${l10n.statementOpening}: ${balance(null)}',
      if (statement.isTruncated)
        l10n.statementTruncated(statement.lines.length),
      for (final line in statement.lines)
        [
          formatDate(_day(line.effectiveAt)),
          l10n.transactionTypeLabel(line.type),
          MoneyFormatter.format(line.amount.abs()),
          if (line.isReversed) l10n.ledgerReversedTag,
          if (line.description != null) line.description!,
          l10n.ledgerBalanceAfter(balance(line)),
        ].join(' · '),
      '${l10n.statementClosing}: $closingText',
    ].join('\n');
  }

  /// A statement as CSV. Dates are ISO (`2026-11-15`) and amounts plain
  /// numbers so a spreadsheet can sort and add them. A positive change
  /// raises what is owed; a negative one lowers it.
  static String statementCsv({
    required AppLocalizations l10n,
    required PartyStatement statement,
  }) {
    final role = statement.role;
    String meaning(Money balance) =>
        l10n.balanceLabel(BalanceKind.of(role, balance));

    return CsvWriter.build(
      [
        l10n.csvDate,
        l10n.csvType,
        l10n.descriptionLabel,
        _inr(l10n.csvChange),
        _inr(l10n.csvBalance),
        l10n.csvBalanceMeaning,
      ],
      [
        [
          statement.range.start?.toIso() ?? '',
          l10n.statementOpening,
          '',
          '',
          CsvWriter.amount(statement.openingBalance.paise),
          meaning(statement.openingBalance),
        ],
        for (final line in statement.lines)
          [
            _day(line.effectiveAt).toIso(),
            [
              l10n.transactionTypeLabel(line.type),
              if (line.isReversed) '(${l10n.ledgerReversedTag})',
            ].join(' '),
            line.description ?? '',
            CsvWriter.amount(line.amount.paise),
            CsvWriter.amount(line.balanceAfter.paise),
            meaning(line.balanceAfter),
          ],
        [
          statement.range.end?.toIso() ?? '',
          l10n.statementClosing,
          '',
          '',
          CsvWriter.amount(statement.closingBalance.paise),
          meaning(statement.closingBalance),
        ],
      ],
      amountColumns: const {3, 4},
    );
  }

  /// The dues-and-aging report as CSV, one party per row.
  static String outstandingCsv({
    required AppLocalizations l10n,
    required OutstandingReport report,
  }) => CsvWriter.build(
    [
      l10n.csvParty,
      _inr(l10n.csvTotalDue),
      _inr(l10n.agingUpTo7),
      _inr(l10n.aging8To15),
      _inr(l10n.aging16To30),
      _inr(l10n.agingOver30),
      l10n.csvOldestDate,
      l10n.csvOpenEntries,
    ],
    [
      for (final row in report.rows)
        [
          row.partyName,
          CsvWriter.amount(row.total.paise),
          CsvWriter.amount(row.aging.upTo7Days.paise),
          CsvWriter.amount(row.aging.days8To15.paise),
          CsvWriter.amount(row.aging.days16To30.paise),
          CsvWriter.amount(row.aging.over30Days.paise),
          _day(row.oldestAgingDate).toIso(),
          row.openEntryCount.toString(),
        ],
    ],
    amountColumns: const {1, 2, 3, 4, 5, 7},
  );
}
