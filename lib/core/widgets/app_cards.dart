import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_colors.dart';
import 'package:smart_khata/core/theme/app_theme.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/money_text.dart';

/// A rounded, borderless surface for one group of content.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        // A soft shadow lifts the card in light mode; in dark mode the card
        // is already lighter than the page.
        boxShadow: isLight ? AppShadows.card : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: AppRadius.card,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// A gradient surface with soft decorative circles: the "hero" look used
/// by the Home header, balance cards and onboarding. Content on it must be
/// white ([AppGradients.onGradient]).
class GradientSurface extends StatelessWidget {
  const GradientSurface({
    required this.child,
    this.gradient = AppGradients.customers,
    this.borderRadius = AppRadius.card,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.raised = true,
    super.key,
  });

  final Widget child;
  final Gradient gradient;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool raised;

  @override
  Widget build(BuildContext context) {
    final glow = AppGradients.onGradient.withValues(alpha: 0.07);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
        boxShadow: raised ? AppShadows.raised : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            // Decorative rings, purely visual.
            Positioned(
              right: -60,
              top: -70,
              child: _Ring(size: 200, color: glow),
            ),
            Positioned(
              right: 40,
              bottom: -90,
              child: _Ring(size: 160, color: glow),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                child: Padding(padding: padding, child: child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    ),
  );
}

/// A frosted tile on a gradient: a label in words and an amount.
class GlassTile extends StatelessWidget {
  const GlassTile({
    required this.icon,
    required this.label,
    required this.value,
    this.semanticsLabel,
    this.footnote,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  /// A small line under the amount, e.g. "Advance ₹200".
  final String? footnote;
  final VoidCallback? onTap;

  /// What a screen reader says for the whole tile.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      excludeSemantics: semanticsLabel != null,
      label: semanticsLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppGradients.onGradient.withValues(alpha: 0.13),
          borderRadius: AppRadius.control,
          border: Border.all(
            color: AppGradients.onGradient.withValues(alpha: 0.18),
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.control,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppGradients.onGradient.withValues(
                            alpha: 0.2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          child: Icon(
                            icon,
                            size: AppSizes.iconSm,
                            color: AppGradients.onGradient,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (onTap != null)
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: AppSpacing.md,
                          color: AppGradients.onGradientMuted,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    label,
                    style: text.labelMedium?.copyWith(
                      color: AppGradients.onGradientMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: AppTheme.amountStyle(
                        text.titleLarge,
                      )?.copyWith(color: AppGradients.onGradient),
                    ),
                  ),
                  if (footnote != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      footnote!,
                      style: text.labelSmall?.copyWith(
                        color: AppGradients.onGradientMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A round icon button with its label underneath, as in payment apps.
/// [comingSoon] dims it and adds the badge; tapping it explains why.
class CircleAction extends StatelessWidget {
  const CircleAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.comingSoon = false,
    this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool comingSoon;

  /// Icon and tint colour; defaults to the brand colour.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = comingSoon
        ? theme.colorScheme.onSurfaceVariant
        : color ?? theme.colorScheme.primary;
    return Semantics(
      button: true,
      label: comingSoon ? '$label, ${context.l10n.badgeComingSoon}' : label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.control,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: AppSizes.circleAction,
                    height: AppSizes.circleAction,
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: tint),
                  ),
                  if (comingSoon)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: AppSpacing.md,
                        height: AppSpacing.md,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surfaceContainerLowest,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: comingSoon
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A section title with an optional text action on the right.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.xl,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

/// Which side of the business a hero card shows.
enum HeroTone { customers, suppliers }

/// A secondary figure under the hero amount, e.g. "Advance ₹200".
class HeroStat {
  const HeroStat({required this.label, required this.value});

  final String label;
  final String value;
}

/// The large gradient card at the top of a screen: a direction label in
/// words, the amount as the hero, and a few supporting figures.
///
/// The label and amount are read as one screen-reader node
/// ("Customer owes: ₹1,800"); the amount is always shown as a magnitude.
class BalanceHeroCard extends StatelessWidget {
  const BalanceHeroCard({
    required this.title,
    required this.kind,
    required this.amount,
    required this.tone,
    this.stats = const [],
    this.onTap,
    super.key,
  });

  final String title;
  final BalanceKind kind;
  final Money amount;
  final HeroTone tone;
  final List<HeroStat> stats;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final label = l10n.balanceLabel(kind);
    final formatted = MoneyFormatter.format(amount.abs());
    const fg = AppGradients.onGradient;
    const muted = AppGradients.onGradientMuted;

    return GradientSurface(
      gradient: switch (tone) {
        HeroTone.customers => AppGradients.customers,
        HeroTone.suppliers => AppGradients.suppliers,
      },
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                tone == HeroTone.customers
                    ? Icons.people_alt_outlined
                    : Icons.local_shipping_outlined,
                color: muted,
                size: AppSizes.iconSm,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: muted,
                  ),
                ),
              ),
              if (onTap != null) const Icon(Icons.chevron_right, color: muted),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Semantics(
            label: l10n.amountSemantics(label, formatted),
            container: true,
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: fg,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatted,
                    style: AppTheme.amountStyle(
                      theme.textTheme.displaySmall,
                    )?.copyWith(color: fg),
                  ),
                ),
              ],
            ),
          ),
          if (stats.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final stat in stats) _HeroStatPill(stat: stat),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroStatPill extends StatelessWidget {
  const _HeroStatPill({required this.stat});

  final HeroStat stat;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppGradients.onGradient.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '${stat.label}  '),
              TextSpan(
                text: stat.value,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          style: text.labelMedium?.copyWith(color: AppGradients.onGradient),
        ),
      ),
    );
  }
}

/// A small labelled amount, used in a row of daily figures.
class StatTile extends StatelessWidget {
  const StatTile({
    required this.label,
    required this.amount,
    required this.icon,
    super.key,
  });

  final String label;
  final Money amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: context.l10n.amountSemantics(
        label,
        MoneyFormatter.format(amount),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs + AppSpacing.xxs),
              child: Icon(
                icon,
                size: AppSizes.iconSm,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: MoneyText(amount, style: theme.textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}

/// Marks an action that arrives in a later update, so a button never looks
/// broken.
class ComingSoonBadge extends StatelessWidget {
  const ComingSoonBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        // One line, never broken mid-word ("Comin / g soon").
        child: Text(
          context.l10n.badgeComingSoon,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: scheme.onTertiaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// A party's initials on a tonal circle. The colour is stable for a name so
/// the same party always looks the same.
class PartyAvatar extends StatelessWidget {
  const PartyAvatar({
    required this.name,
    this.size = AppSizes.avatar,
    super.key,
  });

  final String name;
  final double size;

  static String initialsOf(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final letters = [
      for (final word in words.take(2)) word.characters.first.toUpperCase(),
    ];
    return letters.isEmpty ? '?' : letters.join();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = [
      (scheme.primaryContainer, scheme.onPrimaryContainer),
      (scheme.secondaryContainer, scheme.onSecondaryContainer),
      (scheme.surfaceContainerHighest, scheme.onSurface),
    ];
    final hash = name.codeUnits.fold<int>(
      0,
      (h, c) => (h * 31 + c) & 0x7fffffff,
    );
    final (bg, fg) = palette[hash % palette.length];
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Text(
          initialsOf(name),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: fg),
        ),
      ),
    );
  }
}

/// Local search box with a clear button. Reports text after a short pause
/// so a list is not re-queried on every keystroke.
class PartySearchField extends StatefulWidget {
  const PartySearchField({
    required this.hintText,
    required this.onChanged,
    this.debounce = const Duration(milliseconds: 250),
    super.key,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final Duration debounce;

  @override
  State<PartySearchField> createState() => _PartySearchFieldState();
}

class _PartySearchFieldState extends State<PartySearchField> {
  final TextEditingController _controller = TextEditingController();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _changed(String text) {
    setState(() {});
    _timer?.cancel();
    _timer = Timer(widget.debounce, () => widget.onChanged(text));
  }

  void _clear() {
    _timer?.cancel();
    _controller.clear();
    setState(() {});
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _changed,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: context.l10n.actionClearSearch,
                icon: const Icon(Icons.close),
                onPressed: _clear,
              ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(AppRadius.pill),
          ),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}

/// A plain row inside a card: label on the left, value on the right.
class InfoRow extends StatelessWidget {
  const InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: AppSizes.iconMd,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
