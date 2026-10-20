import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_version.dart';
import '../providers/app_update.dart';
import '../utils/l10n.dart';
import 'brand.dart';
import 'common.dart';

/// Opens the store page of the app; false when there is none or it cannot be opened.
Future<bool> openStore(AppVersionInfo latest) async {
  final url = latest.storeUrl;
  final uri = url == null ? null : Uri.tryParse(url);
  if (uri == null) return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

/// Covers the whole app when the installed version is older than a mandatory release.
class UpdateRequiredView extends ConsumerWidget {
  const UpdateRequiredView({super.key, required this.latest});
  final AppVersionInfo latest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final installed = ref.watch(installedVersionProvider).valueOrNull ?? '';

    return Material(
      key: const Key('updateRequired'),
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ResponsiveBody(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: BrandLogo(semanticLabel: l10n.appTitle, height: 140)),
                  const SizedBox(height: 24),
                  Icon(Icons.system_update, size: 48, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(l10n.updateRequiredTitle, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(l10n.updateRequiredBody, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text(
                    l10n.updateVersions(installed, latest.latestVersion),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  if (latest.storeUrl != null)
                    PrimaryButton(
                      key: const Key('updateNowButton'),
                      label: l10n.updateNow,
                      onPressed: () => openStore(latest),
                    )
                  else
                    Text(l10n.updateStoreHint, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.read(appUpdateProvider.notifier).check(),
                    child: Text(l10n.updateCheckAgain),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A dismissible bar above the footer when a newer, optional release exists.
class UpdateAvailableBar extends ConsumerWidget {
  const UpdateAvailableBar({super.key, required this.latest});
  final AppVersionInfo latest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Material(
      key: const Key('updateAvailable'),
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
        child: Row(
          children: [
            Icon(Icons.system_update, size: 20, color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.updateAvailable,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
            if (latest.storeUrl != null) TextButton(onPressed: () => openStore(latest), child: Text(l10n.updateNow)),
            // No tooltip: this sits above the Navigator, outside any Overlay.
            IconButton(
              key: const Key('dismissUpdateButton'),
              icon: Icon(Icons.close, size: 18, semanticLabel: l10n.dismiss),
              onPressed: () => ref.read(appUpdateProvider.notifier).dismiss(),
            ),
          ],
        ),
      ),
    );
  }
}
