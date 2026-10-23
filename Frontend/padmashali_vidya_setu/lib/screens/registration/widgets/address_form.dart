import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../models/master_data_item.dart';
import '../../../models/registration_draft.dart';
import '../../../providers/providers.dart';
import '../../../utils/l10n.dart';
import '../../../utils/validators.dart';
import '../../../widgets/common.dart';
import '../../../widgets/master_data_dropdown.dart';

/// One address (permanent or current). Country comes first (India by default):
///
/// India: PIN code → the places linked to it (India Post) are offered as City / Village choices, and District, State,
/// Country are filled automatically. "My place is not listed" lets the member type the City / Village instead.
/// Taluk is a dropdown filtered by district (pre-selected when the PIN data suggests one), with
/// "My taluk is not listed" for anything missing. If the PIN lookup fails, State and District can be
/// chosen manually — the user is never blocked by the PIN service.
///
/// Any other country: the member types the City / Town and an optional postal code, and picks the State / Province
/// from that country's list — or types it when it is not listed.
class AddressForm extends ConsumerStatefulWidget {
  const AddressForm({
    super.key,
    required this.address,
    required this.fieldPrefix,
    required this.serverErrors,
    required this.onFieldChanged,
  });

  final AddressDraft address;

  /// `permanentAddress` or `currentAddress` — prefix of server error keys and widget keys.
  final String fieldPrefix;
  final Map<String, String> serverErrors;
  final ValueChanged<String> onFieldChanged;

  @override
  ConsumerState<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<AddressForm> {
  late final _line1 = TextEditingController(text: widget.address.addressLine1);
  late final _line2 = TextEditingController(text: widget.address.addressLine2);
  late final _pin = TextEditingController(text: widget.address.pinCode);
  late final _city = TextEditingController(text: widget.address.cityVillageName);
  late final _newTaluk = TextEditingController(text: widget.address.newTalukName);
  late final _newState = TextEditingController(text: widget.address.newStateName);

  bool _lookingUp = false;
  String? _lookupMessage;
  String? _lastLookedUpPin;

  AddressDraft get _a => widget.address;
  String? _err(String field) => widget.serverErrors['${widget.fieldPrefix}.$field'];
  Key _key(String field) => Key('${widget.fieldPrefix}.$field');

  @override
  void dispose() {
    for (final c in [_line1, _line2, _pin, _city, _newTaluk, _newState]) {
      c.dispose();
    }
    super.dispose();
  }

  void _changed(String field) => widget.onFieldChanged('${widget.fieldPrefix}.$field');

  Future<void> _onPinChanged(String value) async {
    _a.pinCode = value;
    _changed('pinCode');
    if (!Validators.isCompletePin(value) || value == _lastLookedUpPin) return;

    _lastLookedUpPin = value;
    setState(() {
      _lookingUp = true;
      _lookupMessage = null;
    });
    try {
      final result = await ref.read(masterDataRepositoryProvider).lookupPinCode(value);
      if (!mounted || _pin.text != value) return;
      setState(() {
        _a.applyLookup(result);
        _city.text = _a.cityVillageName;
      });
      // The lookup may have taught the server new taluks for this district.
      ref.invalidate(taluksProvider(result.district.id));
      for (final f in ['cityVillageName', 'stateId', 'districtId', 'talukId']) {
        _changed(f);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _a.clearLookup();
        _lookupMessage = e.kind == ApiErrorKind.notFound ? context.l10n.pinNotFound : describeError(context.l10n, e);
      });
    } finally {
      if (mounted) setState(() => _lookingUp = false);
    }
  }

  void _pickCountry(MasterDataItem country) {
    if (country.id == _a.country?.id) return;
    setState(() {
      _a.selectCountry(country);
      for (final c in [_pin, _city, _newTaluk, _newState]) {
        c.clear();
      }
      _lastLookedUpPin = null;
      _lookupMessage = null;
    });
    for (final f in ['countryId', 'pinCode', 'cityVillageName', 'stateId', 'districtId', 'talukId']) {
      _changed(f);
    }
  }

  static const _placeNotListed = -1;

  void _pickPlace(int? cityId) {
    if (cityId == null) return;
    setState(() {
      if (cityId == _placeNotListed) {
        _a.selectPlaceNotListed();
      } else {
        _a.selectLocality(_a.localities.firstWhere((l) => l.cityId == cityId));
      }
      _city.text = _a.cityVillageName;
    });
    _changed('cityId');
    _changed('cityVillageName');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final countries = ref.watch(masterDataProvider(MasterDataTypes.countries));
    // India is the default; the member changes it for an address abroad.
    final india = countries.valueOrNull?.where((c) => c.code == MasterCodes.countryIndia).firstOrNull;
    if (india != null && _a.country == null) _a.country = india;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MasterDataDropdown(
          fieldKey: _key('countryId'),
          provider: masterDataProvider(MasterDataTypes.countries),
          label: l10n.country,
          helperText: l10n.countryHelp,
          icon: Icons.public,
          value: _a.country?.id,
          errorText: _err('countryId'),
          onChanged: _pickCountry,
        ),
        const FieldGap(),
        TextFormField(
          key: _key('addressLine1'),
          controller: _line1,
          textCapitalization: TextCapitalization.words,
          maxLength: 200,
          decoration: InputDecoration(
            labelText: l10n.addressLine1,
            prefixIcon: const Icon(Icons.home_outlined),
            errorText: _err('addressLine1'),
            counterText: '',
          ),
          validator: (v) => Validators.addressLine(v)?.text(l10n),
          onChanged: (v) {
            _a.addressLine1 = v;
            _changed('addressLine1');
          },
        ),
        const FieldGap(),
        TextFormField(
          key: _key('addressLine2'),
          controller: _line2,
          textCapitalization: TextCapitalization.words,
          maxLength: 200,
          decoration: InputDecoration(
            labelText: l10n.addressLine2,
            prefixIcon: const Icon(Icons.signpost_outlined),
            counterText: '',
          ),
          onChanged: (v) => _a.addressLine2 = v,
        ),
        const FieldGap(),
        if (_a.isIndia) ..._indianFields(context) else ..._fieldsOutsideIndia(context),
      ],
    );
  }

  /// PIN code → City / Village, State, District, Taluk.
  List<Widget> _indianFields(BuildContext context) {
    final l10n = context.l10n;
    return [
      TextFormField(
        key: _key('pinCode'),
        controller: _pin,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
        decoration: InputDecoration(
          labelText: l10n.pinCode,
          helperText: l10n.pinCodeHelp,
          prefixIcon: const Icon(Icons.pin_drop_outlined),
          errorText: _err('pinCode'),
          suffixIcon: _lookingUp
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : null,
        ),
        validator: (v) => Validators.pinCode(v)?.text(l10n),
        onChanged: _onPinChanged,
      ),
      if (_lookingUp) ...[const SizedBox(height: 8), Text(l10n.lookingUpPin)],
      if (_lookupMessage != null) ...[
        const SizedBox(height: 8),
        InfoNote(text: _lookupMessage!, icon: Icons.travel_explore),
      ],
      const FieldGap(),
      if (_a.localities.isNotEmpty)
        KeyedSubtree(
          key: _key('cityId'),
          child: DropdownButtonFormField<int>(
            // Re-created when a new PIN lookup changes the places or the selection.
            key: ValueKey((_a.pinCode, _a.cityNotListed ? _placeNotListed : _a.cityId)),
            initialValue: _a.cityNotListed ? _placeNotListed : _a.cityId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.cityVillage,
              helperText: l10n.cityVillageHelp,
              prefixIcon: const Icon(Icons.location_city_outlined),
              errorText: _a.cityNotListed ? null : _err('cityId') ?? _err('cityVillageName'),
            ),
            items: [
              for (final l in _a.localities)
                DropdownMenuItem(
                  value: l.cityId,
                  child: Text(l.name, overflow: TextOverflow.ellipsis),
                ),
              DropdownMenuItem(value: _placeNotListed, child: Text(l10n.cityNotListed)),
            ],
            validator: (v) => v == null ? l10n.validationSelect : null,
            onChanged: _pickPlace,
          ),
        ),
      if (_a.localities.isEmpty || _a.cityNotListed) ...[
        if (_a.localities.isNotEmpty) const FieldGap(),
        _cityField(_a.cityNotListed ? l10n.pleaseSpecify : l10n.cityVillage),
      ],
      const FieldGap(),
      if (_a.country != null)
        MasterDataDropdown(
          fieldKey: _key('stateId'),
          provider: statesProvider(_a.country!.id),
          label: l10n.state,
          icon: Icons.map_outlined,
          value: _a.state?.id,
          errorText: _err('stateId'),
          onChanged: (s) {
            setState(() {
              if (_a.state?.id != s.id) {
                _a.district = null;
                _a.talukId = null;
              }
              _a.state = s;
            });
            _changed('stateId');
          },
        ),
      if (_a.state != null) ...[
        const FieldGap(),
        MasterDataDropdown(
          fieldKey: _key('districtId'),
          provider: districtsProvider(_a.state!.id),
          label: l10n.district,
          icon: Icons.location_on_outlined,
          value: _a.district?.id,
          errorText: _err('districtId'),
          onChanged: (d) {
            setState(() {
              if (_a.district?.id != d.id) _a.talukId = null;
              _a.district = d;
            });
            _changed('districtId');
          },
        ),
      ],
      if (_a.district != null) ..._talukFields(context),
    ];
  }

  /// City / Town, State / Province (from the country's list, or typed) and an optional postal code.
  List<Widget> _fieldsOutsideIndia(BuildContext context) {
    final l10n = context.l10n;
    final states = ref.watch(statesProvider(_a.country!.id));
    // No states known yet for this country: the member types it (and it is added to the list for everyone).
    final noStatesListed = states.valueOrNull?.isEmpty ?? false;
    if (noStatesListed) _a.stateNotListed = true;

    return [
      _cityField(l10n.cityTown),
      const FieldGap(),
      if (!_a.stateNotListed)
        MasterDataDropdown(
          fieldKey: _key('stateId'),
          provider: statesProvider(_a.country!.id),
          label: l10n.stateProvince,
          icon: Icons.map_outlined,
          value: _a.state?.id,
          errorText: _err('stateId'),
          onChanged: (s) {
            setState(() => _a.state = s);
            _changed('stateId');
          },
        )
      else
        TextFormField(
          key: _key('newStateName'),
          controller: _newState,
          textCapitalization: TextCapitalization.words,
          maxLength: 100,
          decoration: InputDecoration(
            labelText: l10n.stateProvince,
            prefixIcon: const Icon(Icons.map_outlined),
            errorText: _err('newStateName') ?? _err('stateId'),
            counterText: '',
          ),
          validator: (v) => Validators.personName(v)?.text(l10n),
          onChanged: (v) {
            _a.newStateName = v;
            _changed('newStateName');
            _changed('stateId');
          },
        ),
      if (!noStatesListed)
        CheckboxListTile(
          key: _key('stateNotListed'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _a.stateNotListed,
          title: Text(l10n.stateNotListed),
          onChanged: (v) => setState(() => _a.stateNotListed = v ?? false),
        )
      else
        const FieldGap(),
      TextFormField(
        key: _key('pinCode'),
        controller: _pin,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: [LengthLimitingTextInputFormatter(10)],
        decoration: InputDecoration(
          labelText: l10n.postalCode,
          prefixIcon: const Icon(Icons.markunread_mailbox_outlined),
          errorText: _err('pinCode'),
        ),
        validator: (v) => Validators.postalCode(v)?.text(l10n),
        onChanged: (v) {
          _a.pinCode = v;
          _changed('pinCode');
        },
      ),
    ];
  }

  Widget _cityField(String label) {
    final l10n = context.l10n;
    return TextFormField(
      key: _key('cityVillageName'),
      controller: _city,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.location_city_outlined),
        errorText: _err('cityVillageName'),
      ),
      validator: (v) => Validators.requiredText(v)?.text(l10n),
      onChanged: (v) {
        _a.cityVillageName = v;
        _changed('cityVillageName');
      },
    );
  }

  List<Widget> _talukFields(BuildContext context) {
    final l10n = context.l10n;
    return [
      const FieldGap(),
      if (!_a.talukNotListed)
        MasterDataDropdown(
          fieldKey: _key('talukId'),
          provider: taluksProvider(_a.district!.id),
          label: l10n.taluk,
          icon: Icons.account_tree_outlined,
          value: _a.talukId,
          errorText: _err('talukId'),
          onChanged: (t) {
            setState(() => _a.talukId = t.id);
            _changed('talukId');
          },
        )
      else
        TextFormField(
          key: _key('newTalukName'),
          controller: _newTaluk,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.talukName,
            prefixIcon: const Icon(Icons.account_tree_outlined),
            errorText: _err('newTalukName'),
          ),
          validator: (v) => Validators.personName(v)?.text(l10n),
          onChanged: (v) {
            _a.newTalukName = v;
            _changed('newTalukName');
          },
        ),
      CheckboxListTile(
        key: _key('talukNotListed'),
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        value: _a.talukNotListed,
        title: Text(l10n.talukNotListed),
        onChanged: (v) => setState(() => _a.talukNotListed = v ?? false),
      ),
    ];
  }
}
