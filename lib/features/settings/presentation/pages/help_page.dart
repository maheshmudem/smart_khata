import 'package:flutter/material.dart';
import 'package:smart_khata/core/app_info.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';

/// WF-083: short how-to notes, where the records are kept, and the
/// version and licences.
///
/// No support contact or privacy-policy link is shown until real ones
/// are configured in [AppInfo]; the app never shows made-up ones.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(text, style: theme.textTheme.titleMedium),
    );

    Widget paragraph(String text) => Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Text(text),
    );

    const support = AppInfo.supportContact;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          heading(l10n.helpHowToTitle),
          for (final step in [
            l10n.helpStepParties,
            l10n.helpStepCredit,
            l10n.helpStepPayment,
            l10n.helpStepMistake,
            l10n.helpStepClosing,
            l10n.helpStepBackup,
          ])
            paragraph('•  $step'),
          heading(l10n.helpDataTitle),
          paragraph(l10n.helpDataOnPhone),
          paragraph(l10n.helpDataNoNetwork),
          paragraph(l10n.helpDataUninstall),
          paragraph(l10n.helpDataNotEncrypted),
          if (support != null) ...[
            heading(l10n.helpSupportTitle),
            paragraph(support),
          ],
          heading(l10n.helpAboutTitle),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.appTitle),
            subtitle: Text(l10n.helpVersion(AppInfo.version)),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.helpLicences),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(
              context: context,
              applicationName: l10n.appTitle,
              applicationVersion: AppInfo.version,
            ),
          ),
        ],
      ),
    );
  }
}
