import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/domain/contact_text.dart';
import 'package:smart_khata/core/errors/load_state.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_cards.dart';
import 'package:smart_khata/core/widgets/dialogs.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/language_options.dart';
import 'package:smart_khata/features/settings/presentation/more_cubit.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';

/// The More tab (WF-080): shop profile, language, and "Reset app data".
///
/// There is no account, so there is no sign-out. Reset is the one way to
/// start over, and it is guarded by two confirmations (ADR-022).
class MorePage extends StatelessWidget {
  const MorePage({required this.onAppReset, super.key});

  /// Restarts the app after the data has been erased.
  final VoidCallback onAppReset;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.watch<LocaleCubit>().state;
    return BlocConsumer<MoreCubit, MoreState>(
      listenWhen: (a, b) => a.resetStatus != b.resetStatus,
      listener: (context, state) {
        if (state.resetStatus == SubmitStatus.success) onAppReset();
        if (state.resetFailure case final failure?) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.failureMessage(failure))),
          );
        }
      },
      builder: (context, state) {
        final shop = state.shop.valueOrNull;
        final erasing =
            state.resetStatus == SubmitStatus.submitting ||
            state.resetStatus == SubmitStatus.success;
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(title: Text(l10n.navMore)),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                children: [
                  if (shop != null) _ShopCard(shop: shop),
                  SectionHeader(title: l10n.moreSectionShop),
                  _Group(
                    children: [
                      _Row(
                        icon: Icons.storefront_outlined,
                        title: l10n.shopProfileTitle,
                        onTap: () => context.push(AppRoutes.shopProfile),
                      ),
                    ],
                  ),
                  SectionHeader(title: l10n.moreSectionApp),
                  _Group(
                    children: [
                      _Row(
                        icon: Icons.translate,
                        title: l10n.settingsLanguage,
                        subtitle: locale == AppLocales.telugu
                            ? l10n.languageTelugu
                            : l10n.languageEnglish,
                        onTap: () => unawaited(_showLanguageSheet(context)),
                      ),
                      _Row(
                        icon: Icons.wifi_off_rounded,
                        title: l10n.offlineReady,
                      ),
                      if (kDebugMode)
                        _Row(
                          icon: Icons.widgets_outlined,
                          // Debug-only developer tool; not translated.
                          title: 'Widget gallery (debug)',
                          onTap: () => context.push(AppRoutes.gallery),
                        ),
                    ],
                  ),
                  SectionHeader(title: l10n.moreSectionDanger),
                  _Group(
                    children: [
                      _Row(
                        icon: Icons.delete_forever_outlined,
                        title: l10n.resetTitle,
                        subtitle: l10n.resetSubtitle,
                        isDestructive: true,
                        onTap: shop == null
                            ? null
                            : () => unawaited(_confirmReset(context, shop)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (erasing) _ErasingOverlay(label: l10n.resetInProgress),
          ],
        );
      },
    );
  }

  /// Two separate confirmations: a plain warning, then typing the shop name.
  Future<void> _confirmReset(BuildContext context, Shop shop) async {
    final l10n = context.l10n;
    final cubit = context.read<MoreCubit>();
    final first = await showConfirmDialog(
      context,
      title: l10n.resetStep1Title,
      message: l10n.resetStep1Body,
      confirmLabel: l10n.actionContinue,
      cancelLabel: l10n.actionCancel,
      isDestructive: true,
    );
    if (!first || !context.mounted) return;
    final second = await showDialog<bool>(
      context: context,
      builder: (_) => _TypeShopNameDialog(shopName: shop.name),
    );
    if (second ?? false) await cubit.eraseAllData();
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

class _ShopCard extends StatelessWidget {
  const _ShopCard({required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = [
      ?shop.profile.ownerName,
      if (shop.profile.phone case final phone?) ContactText.displayPhone(phone),
    ].join(' · ');
    return AppCard(
      onTap: () => context.push(AppRoutes.shopProfile),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: AppRadius.control,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Icon(
                Icons.storefront_rounded,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shop.name, style: theme.textTheme.titleMedium),
                if (details.isNotEmpty)
                  Text(
                    details,
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
    );
  }
}

/// Rows grouped in one rounded card, separated by thin dividers.
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0)
              const Divider(indent: AppSpacing.xxxl + AppSpacing.lg),
            child,
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isDestructive ? scheme.error : scheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: isDestructive ? scheme.error : scheme.primary),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// Second confirmation: "Erase everything" is enabled only when the shop
/// name is typed exactly (case and extra spaces ignored).
class _TypeShopNameDialog extends StatefulWidget {
  const _TypeShopNameDialog({required this.shopName});

  final String shopName;

  @override
  State<_TypeShopNameDialog> createState() => _TypeShopNameDialogState();
}

class _TypeShopNameDialogState extends State<_TypeShopNameDialog> {
  String _typed = '';

  bool get _matches =>
      ContactText.searchKey(_typed) == ContactText.searchKey(widget.shopName);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(l10n.resetStep2Title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.resetStep2Body(widget.shopName)),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.shopNameLabel),
              onChanged: (v) => setState(() => _typed = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: _matches ? () => Navigator.of(context).pop(true) : null,
          child: Text(l10n.actionEraseEverything),
        ),
      ],
    );
  }
}

class _ErasingOverlay extends StatelessWidget {
  const _ErasingOverlay({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: ColoredBox(
        color: theme.colorScheme.scrim.withValues(alpha: 0.5),
        child: Center(
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.lg),
                Text(label, style: theme.textTheme.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
