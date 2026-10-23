import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../providers/providers.dart';
import '../../utils/l10n.dart';
import '../../widgets/common.dart';

/// "Delete my account" (required by Google Play). Explains what happens, needs an explicit "I understand" and a
/// final confirmation. The API keeps the data for the records but marks the account deleted; this number can then
/// never sign in or register again. Afterwards the app is signed out.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  bool _understood = false;
  bool _deleting = false;
  String? _error;

  Future<void> _delete() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccountConfirmTitle),
        content: Text(l10n.deleteAccountConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(
            key: const Key('deleteAccountConfirmButton'),
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(l10n.deleteAccountButton),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false) || !mounted) return;

    setState(() {
      _deleting = true;
      _error = null;
    });
    try {
      // Signs out; the router then shows the welcome screen with "Your account has been deleted".
      await ref.read(sessionProvider.notifier).deleteAccount();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = describeError(l10n, e));
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final members = ref.watch(sessionProvider.select((s) => s.account?.members.length ?? 0));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deleteAccountTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveBody(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.person_remove_outlined, size: 56, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(l10n.deleteAccountIntro, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
                _Point(icon: Icons.group_off_outlined, text: l10n.deleteAccountPointMembers(members)),
                _Point(icon: Icons.block_outlined, text: l10n.deleteAccountPointNumber),
                _Point(icon: Icons.inventory_2_outlined, text: l10n.deleteAccountPointRecords),
                _Point(icon: Icons.logout, text: l10n.deleteAccountPointSignOut),
                const SizedBox(height: 16),
                CheckboxListTile(
                  key: const Key('deleteAccountUnderstood'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _understood,
                  title: Text(l10n.deleteAccountUnderstood),
                  onChanged: _deleting ? null : (v) => setState(() => _understood = v ?? false),
                ),
                if (_error != null) ...[const SizedBox(height: 8), ErrorBanner(message: _error!)],
                const SizedBox(height: 24),
                FilledButton.icon(
                  key: const Key('deleteAccountButton'),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: _understood && !_deleting ? _delete : null,
                  icon: _deleting
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.delete_forever_outlined),
                  label: Text(l10n.deleteAccountButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
