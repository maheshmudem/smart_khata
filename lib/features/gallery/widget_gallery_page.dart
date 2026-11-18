// Developer tool, reachable in debug builds only. Its headings are plain
// English on purpose; everything it shows is a real, translated component.
import 'package:flutter/material.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_theme.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_cards.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/core/widgets/dialogs.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/money_text.dart';
import 'package:smart_khata/core/widgets/state_views.dart';

/// Shows every design-system component so it can be checked in both themes
/// and both languages (switch language from the More tab).
class WidgetGalleryPage extends StatefulWidget {
  const WidgetGalleryPage({super.key});

  @override
  State<WidgetGalleryPage> createState() => _WidgetGalleryPageState();
}

class _WidgetGalleryPageState extends State<WidgetGalleryPage> {
  late bool _dark = Theme.of(context).brightness == Brightness.dark;
  Money? _amount;
  bool _dirty = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Theme(
      data: _dark ? AppTheme.dark : AppTheme.light,
      child: Builder(
        builder: (context) => DiscardChangesGuard(
          isDirty: _dirty,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Widget gallery'),
              actions: [
                IconButton(
                  tooltip: 'Toggle light / dark',
                  icon: Icon(_dark ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () => setState(() => _dark = !_dark),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                const _Section('Hero cards'),
                BalanceHeroCard(
                  title: l10n.roleCustomers,
                  kind: BalanceKind.customerOwes,
                  amount: Money.fromPaise(4500000),
                  tone: HeroTone.customers,
                  onTap: () {},
                  stats: [
                    HeroStat(
                      label: l10n.statAdvance,
                      value: MoneyFormatter.format(Money.fromPaise(20000)),
                    ),
                    HeroStat(label: l10n.statWithDues, value: '12'),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                BalanceHeroCard(
                  title: l10n.roleSuppliers,
                  kind: BalanceKind.youOweSupplier,
                  amount: Money.fromPaise(1500000),
                  tone: HeroTone.suppliers,
                ),
                const _Section('Cards, avatars, badges'),
                AppCard(
                  child: Row(
                    children: [
                      for (final name in ['Ravi Kumar', 'Suresh', 'ABC'])
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: PartyAvatar(name: name),
                        ),
                      const Spacer(),
                      const ComingSoonBadge(),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          label: l10n.todayCredit,
                          amount: Money.fromPaise(500000),
                          icon: Icons.south_west,
                        ),
                      ),
                      Expanded(
                        child: StatTile(
                          label: l10n.todayCollected,
                          amount: Money.fromPaise(350000),
                          icon: Icons.payments_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PartySearchField(
                  hintText: l10n.partiesSearchHint,
                  onChanged: (_) {},
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: InfoRow(
                    icon: Icons.phone_outlined,
                    label: l10n.phoneLabel,
                    value: '98765 43210',
                  ),
                ),
                const _Section('Balances'),
                for (final kind in BalanceKind.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: BalanceSummary(
                          kind: kind,
                          amount: kind == BalanceKind.settled
                              ? Money.zero
                              : Money.fromPaise(12500050),
                        ),
                      ),
                    ),
                  ),
                const _Section('Fields'),
                MoneyAmountField(
                  label: l10n.amountLabel,
                  errorText: _dirty && _amount == null
                      ? l10n.validationAmountPositive
                      : null,
                  onChanged: (value) => setState(() {
                    _amount = value;
                    _dirty = true;
                  }),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: l10n.settingsLanguage,
                  errorText: l10n.validationRequired,
                  isRequired: true,
                ),
                const _Section('Buttons'),
                AppPrimaryButton(label: l10n.actionSave, onPressed: () {}),
                const SizedBox(height: AppSpacing.sm),
                AppPrimaryButton(
                  label: l10n.actionSave,
                  onPressed: () {},
                  isLoading: true,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppSecondaryButton(
                  label: l10n.actionCancel,
                  onPressed: () => showConfirmDialog(
                    context,
                    title: l10n.discardTitle,
                    message: l10n.discardBody,
                    confirmLabel: l10n.actionDiscard,
                    cancelLabel: l10n.actionKeepEditing,
                    isDestructive: true,
                  ),
                ),
                const _Section('Inline error'),
                InlineError(message: l10n.errorSaveFailed),
                const _Section('Empty state'),
                SizedBox(
                  height: 280,
                  child: EmptyState(
                    title: l10n.featureNotReadyTitle,
                    message: l10n.featureNotReadyBody,
                    actionLabel: l10n.actionContinue,
                    onAction: () {},
                  ),
                ),
                const _Section('Error view'),
                SizedBox(
                  height: 260,
                  child: ErrorView(
                    message: l10n.errorLoadFailed,
                    onRetry: () {},
                  ),
                ),
                const _Section('Loading'),
                const SizedBox(height: 96, child: LoadingView()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.md),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
