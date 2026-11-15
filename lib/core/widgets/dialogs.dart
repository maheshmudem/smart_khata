import 'package:flutter/material.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';

/// Asks the owner to confirm an action.
///
/// Both buttons say what they do ("Discard", "Keep editing"); a bare "OK" is
/// never used (UI spec 3.4). Returns `true` only when the owner confirms;
/// dismissing the dialog counts as cancel.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  required String cancelLabel,
  String? message,
  bool isDestructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final scheme = Theme.of(dialogContext).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

/// Stops system back from silently throwing away a form the owner has
/// started filling (wireframes 1.2). While [isDirty], back asks first.
class DiscardChangesGuard extends StatelessWidget {
  const DiscardChangesGuard({
    required this.isDirty,
    required this.child,
    super.key,
  });

  final bool isDirty;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final l10n = context.l10n;
        final discard = await showConfirmDialog(
          context,
          title: l10n.discardTitle,
          message: l10n.discardBody,
          confirmLabel: l10n.actionDiscard,
          cancelLabel: l10n.actionKeepEditing,
          isDestructive: true,
        );
        if (discard && context.mounted) Navigator.of(context).pop();
      },
      child: child,
    );
  }
}
