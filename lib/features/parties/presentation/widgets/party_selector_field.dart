import 'package:flutter/material.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';

/// The party of an entry form: shows the chosen customer or supplier, or a
/// hint, and opens the party picker when tapped.
class PartySelectorField extends StatelessWidget {
  const PartySelectorField({
    required this.label,
    required this.hint,
    required this.partyName,
    required this.onTap,
    this.isLoading = false,
    this.errorText,
    super.key,
  });

  final String label;
  final String hint;
  final String? partyName;
  final bool isLoading;
  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: AppRadius.control,
      onTap: isLoading ? null : onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: '$label *',
          errorText: errorText,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          partyName ?? hint,
          style: partyName == null
              ? theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )
              : theme.textTheme.titleMedium,
        ),
      ),
    );
  }
}
