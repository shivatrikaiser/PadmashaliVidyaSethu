import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/master_data_item.dart';
import '../utils/l10n.dart';
import 'common.dart';

/// Single choice from a short master-data list (gender, current status), shown as chips so
/// every option is visible without opening a menu.
class MasterDataChoiceField extends ConsumerWidget {
  const MasterDataChoiceField({
    super.key,
    required this.provider,
    required this.label,
    required this.value,
    required this.onChanged,
    this.helperText,
    this.errorText,
    this.onLoaded,
  });

  final ProviderBase<AsyncValue<List<MasterDataItem>>> provider;
  final String label;
  final int? value;
  final ValueChanged<MasterDataItem> onChanged;
  final String? helperText;
  final String? errorText;

  /// Called after the list loads, e.g. to apply a default selection.
  final ValueChanged<List<MasterDataItem>>? onLoaded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final async = ref.watch(provider);

    return async.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => ErrorBanner(message: describeError(l10n, e), onRetry: () => ref.invalidate(provider)),
      data: (items) {
        if (onLoaded != null) WidgetsBinding.instance.addPostFrameCallback((_) => onLoaded!(items));
        return FormField<int>(
          key: ValueKey('$label-$value'),
          initialValue: value,
          validator: (v) => v == null ? l10n.validationSelect : null,
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.titleSmall),
              if (helperText != null) ...[
                const SizedBox(height: 2),
                Text(
                  helperText!,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in items)
                    ChoiceChip(
                      key: Key('choice-${item.code}'),
                      label: Text(item.name),
                      selected: item.id == value,
                      onSelected: (_) {
                        field.didChange(item.id);
                        onChanged(item);
                      },
                    ),
                ],
              ),
              if (field.errorText != null || errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    field.errorText ?? errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
