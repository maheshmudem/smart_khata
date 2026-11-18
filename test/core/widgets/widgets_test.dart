import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/core/widgets/dialogs.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/money_text.dart';
import 'package:smart_khata/core/widgets/state_views.dart';

import '../../helpers/pump_app.dart';

void main() {
  final en = l10nFor(AppLocales.english);
  final te = l10nFor(AppLocales.telugu);

  group('MoneyAmountField', () {
    Future<List<Money?>> pumpField(WidgetTester tester) async {
      final changes = <Money?>[];
      await tester.pumpApp(
        MoneyAmountField(label: 'Amount', onChanged: changes.add),
      );
      return changes;
    }

    testWidgets('reports typed text as paise', (tester) async {
      final changes = await pumpField(tester);
      await tester.enterText(find.byType(TextFormField), '1250.5');
      expect(changes.last, Money.fromPaise(125050));
    });

    testWidgets('reports null while the field is empty', (tester) async {
      final changes = await pumpField(tester);
      await tester.enterText(find.byType(TextFormField), '5');
      await tester.enterText(find.byType(TextFormField), '');
      expect(changes.last, isNull);
    });

    testWidgets('refuses a third decimal, letters and a minus', (tester) async {
      final changes = await pumpField(tester);
      await tester.enterText(find.byType(TextFormField), '12.34');
      for (final bad in ['12.345', '12a', '-12']) {
        await tester.enterText(find.byType(TextFormField), bad);
        expect(find.text('12.34'), findsOneWidget, reason: 'after "$bad"');
      }
      expect(changes.last, Money.fromPaise(1234));
    });

    testWidgets('opens the decimal keypad and shows the rupee prefix', (
      tester,
    ) async {
      await pumpField(tester);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(
        field.keyboardType,
        const TextInputType.numberWithOptions(decimal: true),
      );
      expect(field.decoration?.prefixText, '₹ ');
    });

    testWidgets('starts from an initial amount and shows an error', (
      tester,
    ) async {
      await tester.pumpApp(
        MoneyAmountField(
          label: 'Amount',
          initialValue: Money.fromPaise(50050),
          errorText: en.validationAmountPositive,
          onChanged: (_) {},
        ),
      );
      expect(find.text('500.50'), findsOneWidget);
      expect(find.text(en.validationAmountPositive), findsOneWidget);
    });
  });

  group('BalanceSummary', () {
    testWidgets('names the direction in words for every kind', (tester) async {
      final labels = {
        BalanceKind.customerOwes: en.balanceCustomerOwes,
        BalanceKind.customerAdvance: en.balanceCustomerAdvance,
        BalanceKind.youOweSupplier: en.balanceYouOweSupplier,
        BalanceKind.supplierAdvance: en.balanceSupplierAdvance,
        BalanceKind.settled: en.balanceSettled,
      };
      for (final MapEntry(key: kind, value: label) in labels.entries) {
        await tester.pumpApp(
          BalanceSummary(kind: kind, amount: Money.fromPaise(180000)),
        );
        expect(find.text(label), findsOneWidget);
        expect(find.byType(Icon), findsOneWidget);
      }
    });

    testWidgets('an advance shows the magnitude, never a minus sign', (
      tester,
    ) async {
      await tester.pumpApp(
        BalanceSummary(
          kind: BalanceKind.customerAdvance,
          amount: Money.fromPaise(-20000),
        ),
      );
      expect(find.text('₹200'), findsOneWidget);
      expect(find.textContaining('-'), findsNothing);
    });

    testWidgets('is announced as one labelled amount', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        BalanceSummary(
          kind: BalanceKind.youOweSupplier,
          amount: Money.fromPaise(1500000),
        ),
      );
      expect(
        find.bySemanticsLabel('${en.balanceYouOweSupplier}: ₹15,000'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('buttons', () {
    testWidgets('a loading button ignores taps and shows progress', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPrimaryButton(
              label: 'Save',
              isLoading: true,
              onPressed: () => taps++,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(AppPrimaryButton), warnIfMissed: false);
      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('are at least 48dp tall', (tester) async {
      await tester.pumpApp(
        Column(
          children: [
            AppPrimaryButton(label: en.actionSave, onPressed: () {}),
            AppSecondaryButton(label: en.actionCancel, onPressed: () {}),
          ],
        ),
      );
      for (final type in [FilledButton, OutlinedButton]) {
        expect(
          tester.getSize(find.byType(type)).height,
          greaterThanOrEqualTo(AppSizes.minTouchTarget),
        );
      }
    });
  });

  group('state views', () {
    testWidgets('EmptyState offers its one action', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        EmptyState(
          title: 'No customers yet',
          message: 'Add one to start.',
          actionLabel: 'Add customer',
          onAction: () => taps++,
        ),
      );
      await tester.tap(find.text('Add customer'));
      expect(taps, 1);
    });

    testWidgets('ErrorView offers a translated retry', (tester) async {
      var retries = 0;
      await tester.pumpApp(
        ErrorView(message: te.errorLoadFailed, onRetry: () => retries++),
        locale: AppLocales.telugu,
      );
      await tester.tap(find.text(te.actionRetry));
      expect(retries, 1);
    });

    testWidgets('LoadingView appears only after a short delay', (tester) async {
      double opacity() =>
          tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;

      // The spinner never settles, so pump by hand.
      await tester.pumpApp(const LoadingView(), settle: false);
      expect(opacity(), 0);

      await tester.pump(const Duration(milliseconds: 250));
      expect(opacity(), 1);
      expect(
        tester
            .widget<CircularProgressIndicator>(
              find.byType(CircularProgressIndicator),
            )
            .semanticsLabel,
        en.loadingLabel,
      );
    });

    testWidgets('InlineError shows its message', (tester) async {
      await tester.pumpApp(InlineError(message: en.errorSaveFailed));
      expect(find.text(en.errorSaveFailed), findsOneWidget);
    });
  });

  group('large text and Telugu do not overflow', () {
    // A layout overflow is reported as a test exception, so pumping without
    // an exception is the assertion.
    for (final locale in AppLocales.supported) {
      final l10n = l10nFor(locale);
      testWidgets('${locale.languageCode} at 2x text on a 320dp phone', (
        tester,
      ) async {
        await tester.pumpApp(
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                for (final kind in BalanceKind.values)
                  BalanceSummary(kind: kind, amount: Money.fromPaise(12500050)),
                MoneyAmountField(
                  label: l10n.amountLabel,
                  errorText: l10n.validationAmountInvalid,
                  onChanged: (_) {},
                ),
                AppTextField(
                  label: l10n.settingsLanguage,
                  errorText: l10n.validationRequired,
                  isRequired: true,
                ),
                InlineError(message: l10n.errorSaveFailed),
                AppPrimaryButton(
                  label: l10n.quickAddSupplierPurchase,
                  onPressed: () {},
                ),
                AppSecondaryButton(
                  label: l10n.quickAddReceivePayment,
                  onPressed: () {},
                  icon: Icons.payments_outlined,
                ),
                SizedBox(
                  height: 400,
                  child: ErrorView(
                    title: l10n.errorStartupTitle,
                    message: l10n.errorStartupBody,
                    onRetry: () {},
                  ),
                ),
              ],
            ),
          ),
          locale: locale,
          textScale: 2,
          narrow: true,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('confirm dialog and discard guard', () {
    testWidgets('confirm returns true, cancel and dismiss return false', (
      tester,
    ) async {
      bool? result;
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await showConfirmDialog(
              context,
              title: en.discardTitle,
              confirmLabel: en.actionDiscard,
              cancelLabel: en.actionKeepEditing,
            ),
            child: const Text('open'),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.actionDiscard));
      await tester.pumpAndSettle();
      expect(result, isTrue);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.actionKeepEditing));
      await tester.pumpAndSettle();
      expect(result, isFalse);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5)); // outside the dialog
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    Future<void> pumpGuardedPage(WidgetTester tester, {required bool dirty}) =>
        tester.pumpApp(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DiscardChangesGuard(
                    isDirty: dirty,
                    child: const Scaffold(body: Text('form')),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        );

    testWidgets('back from a dirty form asks before discarding', (
      tester,
    ) async {
      await pumpGuardedPage(tester, dirty: true);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text(en.discardTitle), findsOneWidget);

      await tester.tap(find.text(en.actionKeepEditing));
      await tester.pumpAndSettle();
      expect(find.text('form'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.actionDiscard));
      await tester.pumpAndSettle();
      expect(find.text('form'), findsNothing);
    });

    testWidgets('back from an untouched form just leaves', (tester) async {
      await pumpGuardedPage(tester, dirty: false);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('form'), findsNothing);
      expect(find.text(en.discardTitle), findsNothing);
    });
  });

  group('failure messages', () {
    test('every failure has owner-facing text', () {
      const failures = <Failure>[
        ValidationFailure({'amount': ValidationError.amountMustBePositive}),
        DuplicateOperationFailure(),
        NotFoundFailure('party'),
        ConstraintFailure(ConstraintKind.trigger),
        StorageFullFailure(),
        DatabaseFailure(),
        UnexpectedFailure(),
      ];
      for (final l10n in [en, te]) {
        for (final failure in failures) {
          expect(l10n.failureMessage(failure), isNotEmpty);
        }
      }
    });

    test('each business rule has its own explanation', () {
      expect(
        en.failureMessage(
          const BusinessRuleFailure(BusinessRule.partyArchived),
        ),
        en.errorPartyArchived,
      );
      expect(
        en.failureMessage(
          const BusinessRuleFailure(BusinessRule.openingBalanceAlreadySet),
        ),
        en.errorOpeningBalanceExists,
      );
      for (final rule in BusinessRule.values) {
        expect(te.failureMessage(BusinessRuleFailure(rule)), isNotEmpty);
      }
    });

    test('a database failure is worded for saving or loading', () {
      const failure = DatabaseFailure();
      expect(en.failureMessage(failure), en.errorSaveFailed);
      expect(
        en.failureMessage(failure, context: FailureContext.loading),
        en.errorLoadFailed,
      );
    });

    test('a validation failure shows its field message', () {
      expect(
        en.failureMessage(
          const ValidationFailure({
            'split': ValidationError.splitMustEqualTotal,
          }),
        ),
        en.validationSplitMismatch,
      );
      for (final error in ValidationError.values) {
        expect(te.validationMessage(error), isNotEmpty);
      }
    });
  });
}
