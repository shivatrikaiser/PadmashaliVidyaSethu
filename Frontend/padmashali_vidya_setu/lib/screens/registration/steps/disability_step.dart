import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/master_data_item.dart';
import '../../../providers/providers.dart';
import '../../../routing/routes.dart';
import '../../../utils/l10n.dart';
import '../../../utils/validators.dart';
import '../../../widgets/common.dart';
import '../../legal/legal_document_screen.dart';
import 'step_base.dart';

/// "Is Disabled?" (default No). Type of Disability appears only for Yes; "Other" asks to specify.
/// Also collects the privacy-policy and (for minors) guardian consent.
class DisabilityStep extends RegistrationStep {
  const DisabilityStep({super.key, required super.draft, required super.serverErrors, required super.onFieldChanged});

  @override
  State<DisabilityStep> createState() => _DisabilityStepState();
}

class _DisabilityStepState extends State<DisabilityStep> {
  late final _other = TextEditingController(text: widget.draft.otherDisabilityDescription);

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final draft = widget.draft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.isDisabled, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          key: const Key('isDisabledField'),
          segments: [
            ButtonSegment(value: false, label: Text(l10n.no), icon: const Icon(Icons.close)),
            ButtonSegment(value: true, label: Text(l10n.yes), icon: const Icon(Icons.check)),
          ],
          selected: {draft.isDisabled},
          onSelectionChanged: (s) {
            setState(() => draft.setDisabled(s.first));
            widget.onFieldChanged('isDisabled');
            widget.onFieldChanged('disabilityTypeIds');
          },
        ),
        if (draft.isDisabled) ...[
          const SizedBox(height: 20),
          _DisabilityTypesField(
            key: const Key('disabilityTypesField'),
            selected: draft.disabilityTypeIds,
            serverError: widget.serverErrors['disabilityTypeIds'],
            onToggle: (id, on) {
              setState(() => on ? draft.disabilityTypeIds.add(id) : draft.disabilityTypeIds.remove(id));
              widget.onFieldChanged('disabilityTypeIds');
            },
            otherField: (otherId) => draft.disabilityTypeIds.contains(otherId)
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: TextFormField(
                      key: const Key('otherDisabilityField'),
                      controller: _other,
                      maxLength: 150,
                      decoration: InputDecoration(
                        labelText: l10n.pleaseSpecify,
                        errorText: widget.serverErrors['otherDisabilityDescription'],
                        counterText: '',
                      ),
                      validator: (v) => Validators.requiredText(v)?.text(l10n),
                      onChanged: (v) {
                        draft.otherDisabilityDescription = v;
                        widget.onFieldChanged('otherDisabilityDescription');
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
          InfoNote(text: l10n.disabilityPrivacyNote, icon: Icons.lock_outline),
        ],
        const SizedBox(height: 28),
        Text(l10n.consentHeading, style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        _ConsentCheckbox(
          key: const Key('privacyConsent'),
          value: draft.acceptPrivacyPolicy,
          label: l10n.privacyAgree,
          requiredMessage: l10n.validationPrivacy,
          serverError: widget.serverErrors['acceptPrivacyPolicy'],
          onChanged: (v) {
            setState(() => draft.acceptPrivacyPolicy = v);
            widget.onFieldChanged('acceptPrivacyPolicy');
          },
        ),
        LegalLinks(
          alignment: WrapAlignment.start,
          onPrivacy: () => context.push(Routes.privacy),
          onTerms: () => context.push(Routes.terms),
        ),
        if (draft.needsGuardianConsent)
          _ConsentCheckbox(
            key: const Key('guardianConsent'),
            value: draft.guardianConsent,
            label: l10n.guardianConsent,
            requiredMessage: l10n.validationGuardian,
            serverError: widget.serverErrors['guardianConsent'],
            onChanged: (v) {
              setState(() => draft.guardianConsent = v);
              widget.onFieldChanged('guardianConsent');
            },
          ),
      ],
    );
  }
}

/// Multi-select chips over the disability-types master list (which also contains types other
/// members added via "Other").
class _DisabilityTypesField extends ConsumerWidget {
  const _DisabilityTypesField({
    super.key,
    required this.selected,
    required this.onToggle,
    required this.otherField,
    this.serverError,
  });

  final Set<int> selected;
  final void Function(int id, bool selected) onToggle;
  final Widget Function(int? otherId) otherField;
  final String? serverError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final provider = masterDataProvider(MasterDataTypes.disabilityTypes);

    return ref
        .watch(provider)
        .when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => ErrorBanner(message: describeError(l10n, e), onRetry: () => ref.invalidate(provider)),
          data: (types) {
            final otherId = types.where((t) => t.code == MasterCodes.disabilityOther).firstOrNull?.id;
            return FormField<Set<int>>(
              validator: (_) => selected.isEmpty ? l10n.validationDisabilityType : null,
              builder: (field) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.typeOfDisability, style: theme.textTheme.titleSmall),
                  Text(
                    l10n.typeOfDisabilityHelp,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in types)
                        FilterChip(
                          key: Key('disability-${t.code}'),
                          label: Text(t.name),
                          selected: selected.contains(t.id),
                          onSelected: (on) {
                            onToggle(t.id, on);
                            field.didChange(selected);
                          },
                        ),
                    ],
                  ),
                  if (field.errorText != null || serverError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        field.errorText ?? serverError!,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                      ),
                    ),
                  otherField(otherId),
                ],
              ),
            );
          },
        );
  }
}

class _ConsentCheckbox extends StatelessWidget {
  const _ConsentCheckbox({
    super.key,
    required this.value,
    required this.label,
    required this.requiredMessage,
    required this.onChanged,
    this.serverError,
  });

  final bool value;
  final String label;
  final String requiredMessage;
  final ValueChanged<bool> onChanged;
  final String? serverError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FormField<bool>(
      initialValue: value,
      validator: (_) => value ? null : requiredMessage,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: value,
            title: Text(label),
            onChanged: (v) {
              onChanged(v ?? false);
              field.didChange(v);
            },
          ),
          if (field.errorText != null || serverError != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Text(
                field.errorText ?? serverError!,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
}
