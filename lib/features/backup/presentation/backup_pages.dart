import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/theme/app_colors.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/core/widgets/dialogs.dart';
import 'package:smart_khata/core/widgets/formatters.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/backup/domain/backup.dart';
import 'package:smart_khata/features/backup/presentation/backup_cubits.dart';

Widget _note(BuildContext context, String text) => Padding(
  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
  child: Text(
    text,
    style: Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  ),
);

/// A boxed warning with an icon; the words carry the meaning.
class _Warning extends StatelessWidget {
  const _Warning(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final color = context.semanticColors.warning;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_outlined, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// WF-070: when the last backup was saved, and the two actions.
class BackupHomePage extends StatelessWidget {
  const BackupHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(l10n.backupLastLabel, style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          BlocBuilder<BackupStatusCubit, BackupStatusState>(
            builder: (context, state) {
              final at = state.lastBackupAt;
              if (!state.isLoaded) return const Text('');
              return at == null
                  ? _Warning(l10n.dashNoBackup)
                  : Text(
                      AppDateFormat.instant(context, at),
                      style: theme.textTheme.titleLarge,
                    );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            label: l10n.actionCreateBackup,
            icon: Icons.lock_outline,
            onPressed: () => unawaited(context.push(AppRoutes.backupCreate)),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSecondaryButton(
            label: l10n.actionRestoreBackup,
            icon: Icons.restore,
            onPressed: () => unawaited(context.push(AppRoutes.backupRestore)),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.backupIncludesTitle, style: theme.textTheme.titleSmall),
          _note(context, l10n.backupIncludesBody),
          _note(context, l10n.backupWhereNote),
          _note(context, l10n.backupNoCloudNote),
        ],
      ),
    );
  }
}

/// WF-071: choose a passphrase, make the backup, save it outside the app.
class CreateBackupPage extends StatefulWidget {
  const CreateBackupPage({super.key});

  @override
  State<CreateBackupPage> createState() => _CreateBackupPageState();
}

class _CreateBackupPageState extends State<CreateBackupPage> {
  String _passphrase = '';
  String _confirmation = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<CreateBackupCubit>();

    return BlocConsumer<CreateBackupCubit, CreateBackupState>(
      listenWhen: (before, after) =>
          after.status == SubmissionStatus.success || after.wasCancelled,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.status == SubmissionStatus.success) context.pop();
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                state.wasCancelled ? l10n.backupNotSaved : l10n.backupSaved,
              ),
            ),
          );
      },
      builder: (context, state) {
        String? error(String field) {
          final e = state.errors[field];
          return e == null ? null : l10n.validationMessage(e);
        }

        final failure = state.failure;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.actionCreateBackup)),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(l10n.backupCreateExplain),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.passphraseLabel,
                helperText: l10n.passphraseHelp,
                obscureText: true,
                isRequired: true,
                errorText: error(ExportBackup.passphraseField),
                onChanged: (value) => _passphrase = value,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l10n.passphraseAgainLabel,
                obscureText: true,
                isRequired: true,
                errorText: error(ExportBackup.confirmationField),
                onChanged: (value) => _confirmation = value,
              ),
              _Warning(l10n.passphraseForgetWarning),
              if (failure != null) ...[
                InlineError(message: l10n.failureMessage(failure)),
                const SizedBox(height: AppSpacing.md),
              ],
              const SizedBox(height: AppSpacing.md),
              AppPrimaryButton(
                label: l10n.actionCreateAndSave,
                isLoading: state.status.isSubmitting,
                onPressed: () => unawaited(
                  cubit.create(
                    passphrase: _passphrase,
                    confirmation: _confirmation,
                  ),
                ),
              ),
              _note(context, l10n.backupWhereNote),
            ],
          ),
        );
      },
    );
  }
}

/// WF-072: choose a backup file, unlock it, see what it holds, and only
/// then replace the records on this phone.
class RestoreBackupPage extends StatefulWidget {
  const RestoreBackupPage({super.key});

  @override
  State<RestoreBackupPage> createState() => _RestoreBackupPageState();
}

class _RestoreBackupPageState extends State<RestoreBackupPage> {
  String _passphrase = '';

  Future<void> _confirmInstall(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<RestoreCubit>();
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.restoreConfirmTitle,
      message: l10n.restoreConfirmBody,
      confirmLabel: l10n.actionReplaceRecords,
      cancelLabel: l10n.actionCancel,
    );
    if (confirmed) await cubit.install();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cubit = context.read<RestoreCubit>();

    return BlocBuilder<RestoreCubit, RestoreState>(
      builder: (context, state) {
        final failure = state.failure;
        final staged = state.staged;
        // While the database is being replaced there is nothing to go
        // back to; the app restarts by itself.
        return PopScope(
          canPop: state.step != RestoreStep.installing,
          child: Scaffold(
            appBar: AppBar(title: Text(l10n.actionRestoreBackup)),
            body: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(l10n.restoreExplain),
                const SizedBox(height: AppSpacing.lg),
                if (failure != null) ...[
                  InlineError(message: l10n.failureMessage(failure)),
                  const SizedBox(height: AppSpacing.md),
                ],
                switch (state.step) {
                  RestoreStep.chooseFile => AppPrimaryButton(
                    label: l10n.actionChooseBackupFile,
                    icon: Icons.folder_open,
                    isLoading: state.isBusy,
                    onPressed: () => unawaited(cubit.chooseFile()),
                  ),
                  RestoreStep.enterPassphrase => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: l10n.passphraseLabel,
                        helperText: l10n.restorePassphraseHelp,
                        obscureText: true,
                        isRequired: true,
                        onChanged: (value) => _passphrase = value,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppPrimaryButton(
                        label: l10n.actionCheckBackup,
                        isLoading: state.isBusy,
                        onPressed: () => unawaited(cubit.check(_passphrase)),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppSecondaryButton(
                        label: l10n.actionChooseAnotherFile,
                        onPressed: state.isBusy
                            ? null
                            : () => unawaited(cubit.reset()),
                      ),
                    ],
                  ),
                  RestoreStep.preview || RestoreStep.installing => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (staged != null) _Preview(manifest: staged.manifest),
                      _Warning(l10n.restoreReplaceWarning),
                      const SizedBox(height: AppSpacing.md),
                      AppPrimaryButton(
                        label: l10n.actionReplaceRecords,
                        isLoading: state.isBusy,
                        onPressed: () => unawaited(_confirmInstall(context)),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppSecondaryButton(
                        label: l10n.actionChooseAnotherFile,
                        onPressed: state.isBusy
                            ? null
                            : () => unawaited(cubit.reset()),
                      ),
                    ],
                  ),
                },
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.restoreSafetyNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// What the checked backup holds (FR-BKP-005).
class _Preview extends StatelessWidget {
  const _Preview({required this.manifest});

  final BackupManifest manifest;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final counts = manifest.recordCounts;

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.restoreCheckedTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            row(l10n.shopNameLabel, manifest.shopName),
            row(
              l10n.restoreBackupDate,
              AppDateFormat.instant(context, manifest.createdAt),
            ),
            row(
              l10n.restoreParties,
              (counts['parties'] ?? 0).toString(),
            ),
            row(
              l10n.restoreEntries,
              (counts['financial_transactions'] ?? 0).toString(),
            ),
            row(l10n.restoreAppVersion, manifest.appVersion),
          ],
        ),
      ),
    );
  }
}
