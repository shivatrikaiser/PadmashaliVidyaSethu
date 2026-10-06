import 'package:flutter/material.dart';

import '../../../models/master_data_item.dart';
import '../../../providers/providers.dart';
import '../../../utils/l10n.dart';
import '../../../widgets/common.dart';
import '../../../widgets/master_data_dropdown.dart';
import 'step_base.dart';

/// Temple and organisation link. Both lists come from master tables.
class CommunityStep extends RegistrationStep {
  const CommunityStep({super.key, required super.draft, required super.serverErrors, required super.onFieldChanged});

  @override
  State<CommunityStep> createState() => _CommunityStepState();
}

class _CommunityStepState extends State<CommunityStep> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = widget.draft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MasterDataDropdown(
          fieldKey: const Key('templeField'),
          provider: masterDataProvider(MasterDataTypes.temples),
          label: l10n.temple,
          helperText: l10n.templeHelp,
          icon: Icons.temple_hindu_outlined,
          value: draft.templeId,
          errorText: widget.serverErrors['templeId'],
          onChanged: (t) {
            setState(() => draft.templeId = t.id);
            widget.onFieldChanged('templeId');
          },
        ),
        const SizedBox(height: 28),
        Text(l10n.organisationQuestion, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        MasterDataDropdown(
          fieldKey: const Key('organisationField'),
          provider: masterDataProvider(MasterDataTypes.organisations),
          label: l10n.organisationLabel,
          icon: Icons.groups_outlined,
          value: draft.organisationId,
          errorText: widget.serverErrors['organisationId'],
          onChanged: (o) {
            setState(() => draft.organisationId = o.id);
            widget.onFieldChanged('organisationId');
          },
        ),
        const FieldGap(),
      ],
    );
  }
}
