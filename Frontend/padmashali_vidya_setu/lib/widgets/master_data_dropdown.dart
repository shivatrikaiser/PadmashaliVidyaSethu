import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/master_data_item.dart';
import '../utils/l10n.dart';
import 'common.dart';

/// Dropdown bound to a master-data list loaded from the API. Handles loading and error states,
/// so screens never hard-code the options.
class MasterDataDropdown extends ConsumerWidget {
  const MasterDataDropdown({
    super.key,
    required this.provider,
    required this.label,
    required this.value,
    required this.onChanged,
    this.helperText,
    this.icon,
    this.errorText,
    this.validate = true,
    this.fieldKey,
  });

  final ProviderBase<AsyncValue<List<MasterDataItem>>> provider;
  final String label;
  final int? value;
  final ValueChanged<MasterDataItem> onChanged;
  final String? helperText;
  final IconData? icon;

  /// Error returned by the server for this field, shown until the value changes.
  final String? errorText;
  final bool validate;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(provider);
    return async.when(
      loading: () => InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: icon == null ? null : Icon(icon)),
        child: const LinearProgressIndicator(),
      ),
      error: (e, _) => ErrorBanner(message: describeError(l10n, e), onRetry: () => ref.invalidate(provider)),
      data: (items) {
        final selected = items.any((i) => i.id == value) ? value : null;
        // Keyed by the value so the field follows changes made outside it (e.g. a PIN lookup).
        return KeyedSubtree(
          key: fieldKey,
          child: DropdownButtonFormField<int>(
            key: ValueKey(selected),
            initialValue: selected,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: label,
              helperText: helperText,
              helperMaxLines: 3,
              errorText: errorText,
              prefixIcon: icon == null ? null : Icon(icon),
            ),
            items: [
              for (final item in items)
                DropdownMenuItem(
                  value: item.id,
                  child: Text(item.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            validator: validate ? (v) => v == null ? l10n.validationSelect : null : null,
            onChanged: (id) {
              if (id != null) onChanged(items.firstWhere((i) => i.id == id));
            },
          ),
        );
      },
    );
  }
}
