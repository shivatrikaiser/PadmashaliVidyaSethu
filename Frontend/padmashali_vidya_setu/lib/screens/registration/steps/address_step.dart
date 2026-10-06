import 'package:flutter/material.dart';

import '../../../utils/l10n.dart';
import '../../../widgets/common.dart';
import '../widgets/address_form.dart';
import 'step_base.dart';

class AddressStep extends RegistrationStep {
  const AddressStep({super.key, required super.draft, required super.serverErrors, required super.onFieldChanged});

  @override
  State<AddressStep> createState() => _AddressStepState();
}

class _AddressStepState extends State<AddressStep> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = widget.draft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: l10n.permanentAddress,
          icon: Icons.home_work_outlined,
          children: [
            AddressForm(
              address: draft.permanentAddress,
              fieldPrefix: 'permanentAddress',
              serverErrors: widget.serverErrors,
              onFieldChanged: widget.onFieldChanged,
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Rule 7: when ticked, the current address is the permanent address.
        CheckboxListTile(
          key: const Key('sameAsPermanentCheckbox'),
          controlAffinity: ListTileControlAffinity.leading,
          value: draft.currentSameAsPermanent,
          title: Text(l10n.sameAsPermanent),
          onChanged: (v) {
            setState(() => draft.currentSameAsPermanent = v ?? false);
            widget.onFieldChanged('currentAddress');
          },
        ),
        if (!draft.currentSameAsPermanent) ...[
          const SizedBox(height: 8),
          SectionCard(
            title: l10n.currentAddress,
            icon: Icons.location_on_outlined,
            children: [
              AddressForm(
                address: draft.currentAddress,
                fieldPrefix: 'currentAddress',
                serverErrors: widget.serverErrors,
                onFieldChanged: widget.onFieldChanged,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
