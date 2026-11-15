import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/core/widgets/dialogs.dart';
import 'package:smart_khata/core/widgets/formatters.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';
import 'package:smart_khata/features/parties/presentation/cubit/party_form_cubit.dart';

/// WF-021: add or edit a party.
class PartyFormPage extends StatelessWidget {
  const PartyFormPage({this.returnOnSave = false, super.key});

  /// Pop with the saved party ID instead of opening its page. Used when a
  /// party is created from inside an entry form.
  final bool returnOnSave;

  static final List<TextInputFormatter> _phoneFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[\d+ ]')),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PartyFormCubit>();

    return BlocConsumer<PartyFormCubit, PartyFormState>(
      listenWhen: (previous, current) =>
          (current.status == SubmissionStatus.success &&
              previous.status != SubmissionStatus.success) ||
          (current.duplicates.isNotEmpty && previous.duplicates.isEmpty),
      listener: (context, state) async {
        if (state.status == SubmissionStatus.success) {
          final partyId = state.savedPartyId!;
          if (returnOnSave) {
            context.pop(partyId);
          } else if (state.isEditing) {
            context.pop();
          } else {
            // Replace the form with the new party's page.
            context.pushReplacement(AppRoutes.partyDetail(partyId));
          }
          return;
        }
        await _showDuplicateDialog(context, state.duplicates.first);
      },
      builder: (context, state) {
        final title = state.isEditing
            ? l10n.partyFormEditTitle
            : l10n.partyFormAddTitle;

        if (state.loadStatus != LoadStatus.loaded) {
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: state.loadStatus == LoadStatus.loading
                ? const LoadingView()
                : ErrorView(
                    message: l10n.failureMessage(
                      state.failure ?? const UnexpectedFailure(),
                      context: FailureContext.loading,
                    ),
                    onRetry: null,
                  ),
          );
        }

        String? error(String field) => switch (state.errors[field]) {
          final ValidationError e => l10n.validationMessage(e),
          null => null,
        };
        final rolesError = error(SavePartyCommand.rolesField);

        return DiscardChangesGuard(
          isDirty: state.isDirty && !state.status.isSubmitting,
          child: Scaffold(
            appBar: AppBar(title: Text(title)),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: [
                        AppTextField(
                          label: l10n.partyNameLabel,
                          initialValue: state.displayName,
                          isRequired: true,
                          autofocus: !state.isEditing,
                          errorText: error(SavePartyCommand.nameField),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          maxLength: SavePartyCommand.maxNameLength,
                          onChanged: cubit.nameChanged,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: l10n.mobileNumberLabel,
                          initialValue: state.primaryPhone,
                          errorText: error(SavePartyCommand.primaryPhoneField),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          inputFormatters: _phoneFormatters,
                          maxLength: 15,
                          onChanged: cubit.primaryPhoneChanged,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: l10n.alternateNumberLabel,
                          initialValue: state.alternatePhone,
                          errorText: error(
                            SavePartyCommand.alternatePhoneField,
                          ),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          inputFormatters: _phoneFormatters,
                          maxLength: 15,
                          onChanged: cubit.alternatePhoneChanged,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          '${l10n.partyRoleLabel} *',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          children: [
                            for (final role in PartyRole.values)
                              FilterChip(
                                label: Text(l10n.roleLabel(role)),
                                selected: state.roles.contains(role),
                                onSelected: state.lockedRoles.contains(role)
                                    ? null
                                    : (selected) => cubit.roleToggled(
                                        role,
                                        selected: selected,
                                      ),
                              ),
                          ],
                        ),
                        if (rolesError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: Text(
                              rolesError,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ),
                        if (state.lockedRoles.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: Text(
                              l10n.roleLockedHelp,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        if (state.roles.contains(PartyRole.customer)) ...[
                          const SizedBox(height: AppSpacing.lg),
                          MoneyAmountField(
                            label: l10n.creditLimitLabel,
                            isRequired: false,
                            emphasized: false,
                            helperText: l10n.creditLimitHelp,
                            initialValue: state.creditLimit,
                            textInputAction: TextInputAction.next,
                            onChanged: cubit.creditLimitChanged,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: l10n.addressLabel,
                          initialValue: state.address,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          maxLines: 2,
                          onChanged: cubit.addressChanged,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: l10n.localityLabel,
                          initialValue: state.locality,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          onChanged: cubit.localityChanged,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: l10n.notesLabel,
                          initialValue: state.notes,
                          errorText: error(SavePartyCommand.notesField),
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 3,
                          maxLength: SavePartyCommand.maxNotesLength,
                          onChanged: cubit.notesChanged,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state.failure case final Failure failure) ...[
                          InlineError(message: l10n.failureMessage(failure)),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        AppPrimaryButton(
                          label: l10n.actionSave,
                          isLoading: state.status.isSubmitting,
                          onPressed: cubit.submit,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// FR-PAR-004: warn, offer the existing party, never merge and never
  /// block creating a separate one (families share phones).
  Future<void> _showDuplicateDialog(
    BuildContext context,
    Party existing,
  ) async {
    final l10n = context.l10n;
    final cubit = context.read<PartyFormCubit>();
    final router = GoRouter.of(context);

    final choice = await showDialog<_DuplicateChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.duplicateTitle),
        content: Text(l10n.duplicateBody(existing.displayName)),
        actionsOverflowButtonSpacing: AppSpacing.sm,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(_DuplicateChoice.createSeparate),
            child: Text(l10n.actionCreateSeparate),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_DuplicateChoice.openExisting),
            child: Text(l10n.actionOpenExisting(existing.displayName)),
          ),
        ],
      ),
    );

    switch (choice) {
      case _DuplicateChoice.openExisting:
        unawaited(
          router.pushReplacement(AppRoutes.partyDetail(existing.id)),
        );
      case _DuplicateChoice.createSeparate:
        unawaited(cubit.submit(allowDuplicatePhone: true));
      case null:
        cubit.duplicatesDismissed();
    }
  }
}

enum _DuplicateChoice { openExisting, createSeparate }
