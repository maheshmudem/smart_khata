import 'package:flutter/material.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';

/// The English / తెలుగు choice, used in first-run setup and in settings.
/// Each language is written in its own script so it is readable whichever
/// language is currently active.
class LanguageOptions extends StatelessWidget {
  const LanguageOptions({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final Locale selected;
  final ValueChanged<Locale> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = <(Locale, String)>[
      (const Locale('en'), l10n.languageEnglish),
      (const Locale('te'), l10n.languageTelugu),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (locale, name) in options) ...[
          _LanguageTile(
            name: name,
            isSelected: locale == selected,
            onTap: () => onSelected(locale),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: isSelected,
      button: true,
      child: Material(
        color: isSelected
            ? scheme.primaryContainer
            : scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.control,
          side: BorderSide(
            color: isSelected ? scheme.primary : scheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(name, style: theme.textTheme.titleMedium),
                  ),
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? scheme.primary : scheme.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
