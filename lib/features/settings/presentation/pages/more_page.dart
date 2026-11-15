import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/language_options.dart';

/// The More tab (WF-080). Only the language setting exists so far; the
/// remaining rows arrive with their features.
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.watch<LocaleCubit>().state;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMore)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.settingsLanguage),
            subtitle: Text(
              locale == AppLocales.telugu
                  ? l10n.languageTelugu
                  : l10n.languageEnglish,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageSheet(context),
          ),
          const Divider(),
          for (final (icon, title, route) in [
            (
              Icons.account_balance_wallet_outlined,
              l10n.moreCashBook,
              AppRoutes.cashBook,
            ),
            (
              Icons.account_balance_outlined,
              l10n.moreMoneyAccounts,
              AppRoutes.moneyAccounts,
            ),
            (
              Icons.category_outlined,
              l10n.moreExpenseCategories,
              AppRoutes.expenseCategories,
            ),
            (Icons.history, l10n.moreClosingHistory, AppRoutes.closingHistory),
          ])
            ListTile(
              leading: Icon(icon),
              title: Text(title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(route),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.cloud_off_outlined),
            title: Text(l10n.offlineReady),
          ),
          if (kDebugMode) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.widgets_outlined),
              // Debug-only developer tool; not translated on purpose.
              title: const Text('Widget gallery (debug)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.gallery),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showLanguageSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                sheetContext.l10n.languageTitle,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              BlocBuilder<LocaleCubit, Locale>(
                builder: (context, selected) => LanguageOptions(
                  selected: selected,
                  onSelected: (locale) async {
                    await context.read<LocaleCubit>().setLocale(locale);
                    if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
