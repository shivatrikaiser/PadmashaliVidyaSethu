import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/master_data_item.dart';
import '../../../models/member_models.dart';
import '../../../models/registration_draft.dart';
import '../../../providers/providers.dart';
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
  /// Bumped when an address is copied, so the forms are rebuilt from the draft.
  int _copies = 0;

  void _copied() {
    setState(() => _copies++);
    widget.onFieldChanged('permanentAddress');
    widget.onFieldChanged('currentAddress');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = widget.draft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CopyAddressPanel(draft: draft, onCopied: _copied),
        SectionCard(
          title: l10n.permanentAddress,
          icon: Icons.home_work_outlined,
          children: [
            AddressForm(
              key: ValueKey(('permanent', _copies)),
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
                key: ValueKey(('current', _copies)),
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

/// Adding a family member: one button per member already on this mobile number, copying that member's addresses.
class _CopyAddressPanel extends ConsumerStatefulWidget {
  const _CopyAddressPanel({required this.draft, required this.onCopied});

  final RegistrationDraft draft;
  final VoidCallback onCopied;

  @override
  ConsumerState<_CopyAddressPanel> createState() => _CopyAddressPanelState();
}

class _CopyAddressPanelState extends ConsumerState<_CopyAddressPanel> {
  String? _loading;

  Future<void> _copy(MemberSummary member) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = member.registrationId);
    try {
      final profile = await ref.read(memberRepositoryProvider).profile(member.registrationId);
      final countries = await ref.read(masterDataProvider(MasterDataTypes.countries).future);
      final permanent = profile.addresses.where((a) => a.isPermanent).firstOrNull;
      if (permanent == null || !mounted) return;
      final current = profile.addresses.where((a) => !a.isPermanent).firstOrNull;

      MasterDataItem countryOf(AddressView a) => countries.firstWhere(
        (c) => c.id == a.countryId,
        orElse: () => MasterDataItem(id: a.countryId ?? 0, name: a.country, code: ''),
      );
      final draft = widget.draft..permanentAddress.copyFrom(permanent, countryOf(permanent));
      final differs = current != null && !AddressDraft.sameAddress(permanent, current);
      draft.currentSameAsPermanent = !differs;
      if (differs) draft.currentAddress.copyFrom(current, countryOf(current));
      widget.onCopied();
      messenger.showSnackBar(SnackBar(content: Text(l10n.addressCopied(member.fullName))));
    } catch (e) {
      if (mounted) messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e))));
    } finally {
      if (mounted) setState(() => _loading = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final members = ref.watch(sessionProvider.select((s) => s.account?.members ?? const <MemberSummary>[]));
    if (members.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SectionCard(
        title: l10n.copyAddressTitle,
        icon: Icons.family_restroom,
        subtitle: l10n.copyAddressHelp,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in members)
                OutlinedButton.icon(
                  key: Key('copyAddress.${m.registrationId}'),
                  onPressed: _loading == null ? () => _copy(m) : null,
                  icon: _loading == m.registrationId
                      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.content_copy, size: 18),
                  label: Text(l10n.copyAddressFrom(m.fullName)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
