import 'package:flutter/material.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';

/// Stand-in for a tab whose feature is built in a later phase. Delete each
/// use as the real screen lands; delete this file with the last one.
class FeatureNotReadyPage extends StatelessWidget {
  const FeatureNotReadyPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(
        icon: Icons.construction_outlined,
        title: l10n.featureNotReadyTitle,
        message: l10n.featureNotReadyBody,
      ),
    );
  }
}
