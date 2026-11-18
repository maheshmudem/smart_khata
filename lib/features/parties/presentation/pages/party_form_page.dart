import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/load_state.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_cards.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/core/widgets/dialogs.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/parties/domain/party_use_cases.dart';
import 'package:smart_khata/features/parties/presentation/bloc/party_form_bloc.dart';

/// WF-021: add or edit a party. The opening balance is not a field here;
/// it is a separate financial action on the party page.
class PartyFormPage extends StatelessWidget {
  const PartyFormPage({this.returnPickedParty = false, super.key});

  /// Opened from inside an entry form: on save, return the new party's ID
  /// to the entry instead of opening its page.
  final bool returnPickedParty;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<PartyFormBloc>();
    return BlocConsumer<PartyFormBloc, PartyFormState>(
      listenWhen: (a, b) =>
          a.status != b.status || a.duplicates != b.duplicates,
      listener: (context, state) async {
        if (state.duplicates.isNotEmpty) {
          await _confirmDuplicate(context, state);
          return;
        }
        if (state.status == SubmitStatus.success) {
          final id = state.savedPartyId;
          if (returnPickedParty && id != null) {
            // Back in the entry form the new party shows as chosen; a
            // floating message there would cover its Save button.
            context.pop(id);
            return;
          }
          showSavedMessage(context, l10n.partySaved);
          if (bloc.isEditing || id == null) {
            context.pop();
          } else {
            context.pushReplacement(AppRoutes.partyDetail(id));
          }
        }
      },
      builder: (context, state) => DiscardChangesGuard(
        isDirty: state.isDirty && state.status != SubmitStatus.success,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              bloc.isEditing ? l10n.partyFormEditTitle : l10n.partyFormAddTitle,
            ),
          ),
          body: state.isLoading
              ? const LoadingView()
              : _FormBody(state: state, isEditing: bloc.isEditing),
        ),
      ),
    );
  }

  Future<void> _confirmDuplicate(
    BuildContext context,
    PartyFormState state,
  ) async {
    final l10n = context.l10n;
    final bloc = context.read<PartyFormBloc>();
    final saveAnyway = await showConfirmDialog(
      context,
      title: l10n.duplicatePhoneTitle,
      message: l10n.duplicatePhoneBody(
        state.duplicates.map((d) => d.name).join(', '),
      ),
      confirmLabel: l10n.actionSaveAnyway,
      cancelLabel: l10n.actionKeepEditing,
    );
    bloc.add(
      saveAnyway
          ? const PartyFormSubmitted(allowDuplicatePhone: true)
          : const PartyDuplicateDismissed(),
    );
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({required this.state, required this.isEditing});

  final PartyFormState state;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bloc = context.read<PartyFormBloc>();
    final input = state.input;
    String? errorFor(String field) {
      final error = state.errors[field];
      return error == null ? null : l10n.validationMessage(error);
    }

    void change(PartyInput next) => bloc.add(PartyFormChanged(next));
    final phoneFormatters = [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
    ];
    final failure = state.failure;
    final rolesError = state.errors[PartyFields.roles];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: l10n.partyNameLabel,
                      initialValue: input.name,
                      isRequired: true,
                      autofocus: !isEditing,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      maxLength: 80,
                      errorText: errorFor(PartyFields.name),
                      onChanged: (v) => change(input.copyWith(name: v)),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.partyRolesLabel,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final role in PartyRole.values)
                          FilterChip(
                            label: Text(l10n.roleLabel(role)),
                            // The checkmark marks the choice; an extra icon
                            // would sit under it.
                            selected: input.roles.contains(role),
                            onSelected: state.lockedRoles.contains(role)
                                ? null
                                : (selected) => change(
                                    input.copyWith(
                                      roles: selected
                                          ? {...input.roles, role}
                                          : ({...input.roles}..remove(role)),
                                    ),
                                  ),
                          ),
                      ],
                    ),
                    if (rolesError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          l10n.partyRolesRequired,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      )
                    else if (state.lockedRoles.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          l10n.partyRoleLocked,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SectionHeader(title: l10n.partyContactSection),
              AppCard(
                child: Column(
                  children: [
                    AppTextField(
                      label: l10n.phoneLabel,
                      initialValue: input.phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      maxLength: 16,
                      inputFormatters: phoneFormatters,
                      errorText: errorFor(PartyFields.phone),
                      onChanged: (v) => change(input.copyWith(phone: v)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: l10n.partyAltPhoneLabel,
                      initialValue: input.alternatePhone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      maxLength: 16,
                      inputFormatters: phoneFormatters,
                      errorText: errorFor(PartyFields.alternatePhone),
                      onChanged: (v) =>
                          change(input.copyWith(alternatePhone: v)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: l10n.addressLabel,
                      initialValue: input.address,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      maxLength: 200,
                      onChanged: (v) => change(input.copyWith(address: v)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: l10n.localityLabel,
                      initialValue: input.locality,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 80,
                      onChanged: (v) => change(input.copyWith(locality: v)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  children: [
                    if (input.roles.contains(PartyRole.customer)) ...[
                      AppTextField(
                        label: l10n.partyCreditLimitLabel,
                        initialValue: input.creditLimitText,
                        helperText: l10n.partyCreditLimitHelper,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: const [AmountInputFormatter()],
                        errorText: errorFor(PartyFields.creditLimit),
                        onChanged: (v) =>
                            change(input.copyWith(creditLimitText: v)),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    AppTextField(
                      label: l10n.partyNotesLabel,
                      initialValue: input.notes,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      maxLength: 500,
                      onChanged: (v) => change(input.copyWith(notes: v)),
                    ),
                  ],
                ),
              ),
              if (!isEditing)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: AppSizes.iconSm,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.partyOpeningHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        FormActionBar(
          children: [
            if (failure != null) ...[
              InlineError(message: l10n.failureMessage(failure)),
              const SizedBox(height: AppSpacing.md),
            ],
            AppPrimaryButton(
              label: l10n.actionSave,
              icon: Icons.check,
              isLoading: state.status == SubmitStatus.submitting,
              onPressed: () => bloc.add(const PartyFormSubmitted()),
            ),
          ],
        ),
      ],
    );
  }
}
