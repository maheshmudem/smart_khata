import 'package:flutter/material.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';

/// Stand-in for a tab whose feature is built in a later phase. Delete each
/// use as the real screen lands; delete this file with the last one.
class FeatureNotReadyPage extends StatelessWidget {
  const FeatureNotReadyPage({
    required this.title,
    this.heading,
    this.body,
    this.icon = Icons.construction_outlined,
    super.key,
  });

  /// App bar title.
  final String title;

  /// What is coming; defaults to the generic "not available" text.
  final String? heading;
  final String? body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(
        icon: icon,
        title: heading ?? l10n.featureNotReadyTitle,
        message: body ?? l10n.featureNotReadyBody,
      ),
    );
  }
}
