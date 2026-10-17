import 'package:flutter/material.dart';

import '../../../models/master_data_item.dart';
import '../../../providers/providers.dart';
import '../../../utils/l10n.dart';
import '../../../utils/validators.dart';
import '../../../widgets/master_data_choice.dart';
import '../../../widgets/master_data_dropdown.dart';
import 'step_base.dart';

/// Current Status comes before Class Studying.
/// Student → "Class Studying"; Working / Unemployed → "Highest Education".
class CurrentStatusStep extends RegistrationStep {
  const CurrentStatusStep({
    super.key,
    required super.draft,
    required super.serverErrors,
    required super.onFieldChanged,
  });

  @override
  State<CurrentStatusStep> createState() => _CurrentStatusStepState();
}

class _CurrentStatusStepState extends State<CurrentStatusStep> {
  late final _educationOther = TextEditingController(text: widget.draft.highestEducationLevelOtherText);

  @override
  void dispose() {
    _educationOther.dispose();
    super.dispose();
  }

  void _applyDefault(List<MasterDataItem> statuses) {
    // Rule 1: Current Status defaults to Student.
    if (widget.draft.memberStatus != null || !mounted) return;
    final student = statuses.where((s) => s.code == MasterCodes.statusStudent).firstOrNull;
    if (student != null) setState(() => widget.draft.selectStatus(student));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = widget.draft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MasterDataChoiceField(
          key: const Key('memberStatusField'),
          provider: masterDataProvider(MasterDataTypes.memberStatuses),
          label: l10n.currentStatus,
          helperText: l10n.currentStatusHelp,
          value: draft.memberStatus?.id,
          errorText: widget.serverErrors['memberStatusId'],
          onLoaded: _applyDefault,
          onChanged: (status) {
            setState(() => draft.selectStatus(status));
            widget.onFieldChanged('memberStatusId');
          },
        ),
        const SizedBox(height: 24),
        if (draft.showsClassStudying)
          MasterDataDropdown(
            fieldKey: const Key('classStudyingField'),
            provider: masterDataProvider(MasterDataTypes.classes),
            label: l10n.classStudying,
            icon: Icons.school_outlined,
            value: draft.classId,
            errorText: widget.serverErrors['classId'],
            onChanged: (c) {
              setState(() => draft.classId = c.id);
              widget.onFieldChanged('classId');
            },
          )
        else
          MasterDataDropdown(
            fieldKey: const Key('highestEducationField'),
            provider: masterDataProvider(MasterDataTypes.educationLevels),
            label: l10n.highestEducation,
            icon: Icons.workspace_premium_outlined,
            value: draft.highestEducationLevelId,
            errorText: widget.serverErrors['highestEducationLevelId'],
            onChanged: (e) {
              setState(() {
                draft.highestEducationLevelId = e.id;
                draft.highestEducationLevelCode = e.code;
              });
              widget.onFieldChanged('highestEducationLevelId');
            },
          ),
        if (draft.highestEducationIsOther)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextFormField(
              key: const Key('highestEducationOtherField'),
              controller: _educationOther,
              maxLength: 150,
              decoration: InputDecoration(
                labelText: l10n.pleaseSpecify,
                errorText: widget.serverErrors['highestEducationLevelOtherText'],
                counterText: '',
              ),
              validator: (v) => Validators.requiredText(v)?.text(l10n),
              onChanged: (v) {
                draft.highestEducationLevelOtherText = v;
                widget.onFieldChanged('highestEducationLevelOtherText');
              },
            ),
          ),
      ],
    );
  }
}
