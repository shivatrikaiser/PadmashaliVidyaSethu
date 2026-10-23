import 'package:flutter/material.dart';

import '../utils/phone_countries.dart';

/// Compact "+91 ▾" picker used as the prefix of a mobile number field.
class CountryCodePicker extends StatelessWidget {
  const CountryCodePicker({super.key, required this.value, required this.onChanged, this.enabled = true});

  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          // The closed picker shows only the code; the open list names the country.
          selectedItemBuilder: (_) => [for (final d in DialCodes.all) Center(child: Text('+${d.code}'))],
          items: [
            for (final d in DialCodes.all) DropdownMenuItem(value: d.code, child: Text('+${d.code}  ${d.label}')),
          ],
          onChanged: enabled ? (code) => code == null ? null : onChanged(code) : null,
        ),
      ),
    );
  }
}
