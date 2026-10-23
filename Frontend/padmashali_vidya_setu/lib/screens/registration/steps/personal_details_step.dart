import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/master_data_item.dart';
import '../../../models/registration_draft.dart';
import '../../../providers/providers.dart';
import '../../../utils/age.dart';
import '../../../utils/l10n.dart';
import '../../../utils/validators.dart';
import '../../../widgets/common.dart';
import '../../../widgets/master_data_choice.dart';
import '../widgets/member_email_field.dart';
import '../widgets/member_mobile_field.dart';
import 'step_base.dart';

class PersonalDetailsStep extends RegistrationStep {
  const PersonalDetailsStep({
    super.key,
    required super.draft,
    required super.serverErrors,
    required super.onFieldChanged,
  });

  @override
  State<PersonalDetailsStep> createState() => _PersonalDetailsStepState();
}

class _PersonalDetailsStepState extends State<PersonalDetailsStep> {
  late final _fullName = TextEditingController(text: widget.draft.fullName);
  late final _fatherName = TextEditingController(text: widget.draft.fatherName);
  late final _motherName = TextEditingController(text: widget.draft.motherName);
  late final _dob = TextEditingController(text: _formatDate(widget.draft.dateOfBirth));

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  static String _formatDate(DateTime? d) => d == null ? '' : _dateFormat.format(d);

  @override
  void dispose() {
    for (final c in [_fullName, _fatherName, _motherName, _dob]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = today();
    final latest = DateTime(now.year - RegistrationDraft.minimumAge, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.draft.dateOfBirth ?? DateTime(now.year - 12, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: latest,
      initialEntryMode: DatePickerEntryMode.calendar,
      helpText: context.l10n.selectDateOfBirth,
    );
    if (picked == null) return;
    // Rule 8: recalculate and display the age whenever the date changes.
    setState(() {
      widget.draft.dateOfBirth = picked;
      _dob.text = _formatDate(picked);
    });
    widget.onFieldChanged('dateOfBirth');
  }

  Widget _nameField(
    String key,
    String label,
    TextEditingController controller,
    ValueChanged<String> assign,
    IconData icon,
  ) {
    final l10n = context.l10n;
    return TextFormField(
      key: Key('${key}Field'),
      controller: controller,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      autofillHints: key == 'fullName' ? const [AutofillHints.name] : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        errorText: widget.serverErrors[key],
        errorMaxLines: 2,
      ),
      validator: (v) => Validators.personName(v)?.text(l10n),
      onChanged: (v) {
        assign(v);
        widget.onFieldChanged(key);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = widget.draft;
    final age = draft.ageToday();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _nameField('fullName', l10n.fullName, _fullName, (v) => draft.fullName = v, Icons.person_outline),
        const FieldGap(),
        _nameField('fatherName', l10n.fatherName, _fatherName, (v) => draft.fatherName = v, Icons.man_outlined),
        const FieldGap(),
        _nameField('motherName', l10n.motherName, _motherName, (v) => draft.motherName = v, Icons.woman_outlined),
        const FieldGap(),
        MemberMobileField(
          draft: draft,
          serverError: widget.serverErrors['mobileNumber'],
          onChanged: () => widget.onFieldChanged('mobileNumber'),
        ),
        const FieldGap(),
        MemberEmailField(
          draft: draft,
          serverError: widget.serverErrors['email'],
          onChanged: () => widget.onFieldChanged('email'),
        ),
        const FieldGap(),
        TextFormField(
          key: const Key('dateOfBirthField'),
          controller: _dob,
          readOnly: true,
          onTap: _pickDate,
          decoration: InputDecoration(
            labelText: l10n.dateOfBirth,
            hintText: 'DD/MM/YYYY',
            prefixIcon: const Icon(Icons.cake_outlined),
            suffixIcon: const Icon(Icons.calendar_month_outlined),
            errorText: widget.serverErrors['dateOfBirth'],
          ),
          validator: (_) {
            if (draft.dateOfBirth == null) return l10n.validationDobRequired;
            if ((draft.ageToday() ?? 0) < RegistrationDraft.minimumAge) {
              return l10n.validationMinAge(RegistrationDraft.minimumAge);
            }
            return null;
          },
        ),
        if (age != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              l10n.ageYears(age),
              key: const Key('ageText'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        const SizedBox(height: 24),
        MasterDataChoiceField(
          provider: masterDataProvider(MasterDataTypes.genders),
          label: l10n.gender,
          value: draft.genderId,
          errorText: widget.serverErrors['genderId'],
          onChanged: (g) {
            setState(() => draft.genderId = g.id);
            widget.onFieldChanged('genderId');
          },
        ),
      ],
    );
  }
}
