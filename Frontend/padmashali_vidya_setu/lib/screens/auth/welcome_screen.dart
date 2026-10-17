import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../routing/routes.dart';
import '../../utils/l10n.dart';
import '../../widgets/brand.dart';
import '../../widgets/common.dart';

/// Logo, sponsor and "Powered by" (both from the admin portal), a divider, then the welcome text - sized to fit a
/// phone screen without scrolling (it still scrolls on very small screens or with large text).
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final expired = ref.watch(sessionProvider.select((s) => s.expired));
    final branding = ref.watch(appBrandingProvider).valueOrNull;
    final sponsor = branding?.sponsorName;
    final poweredBy = branding?.poweredBy;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveBody(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // About a quarter of the screen height, so everything below still fits without scrolling.
                Center(
                  child: BrandLogo(
                    semanticLabel: l10n.appTitle,
                    height: (MediaQuery.sizeOf(context).height * 0.25).clamp(140.0, 220.0),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      if (sponsor != null && sponsor.isNotEmpty)
                        _Credit(key: const Key('welcomeSponsor'), label: l10n.sponsoredBy, name: sponsor, large: true),
                      if (poweredBy != null && poweredBy.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _Credit(key: const Key('welcomePoweredBy'), label: '${l10n.poweredBy}:', name: poweredBy),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 28),
                if (expired) ...[ErrorBanner(message: l10n.errorSessionExpired), const SizedBox(height: 12)],
                Text(l10n.welcomeHeading, style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(l10n.welcomeBody, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                _Feature(icon: Icons.school_outlined, text: l10n.welcomeFeatureEducation),
                _Feature(icon: Icons.lightbulb_outline, text: l10n.welcomeFeatureCareer),
                _Feature(icon: Icons.workspace_premium_outlined, text: l10n.welcomeFeatureOpportunities),
                const SizedBox(height: 16),
                PrimaryButton(
                  key: const Key('getStartedButton'),
                  label: l10n.getStarted,
                  onPressed: () => context.push(Routes.phone),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Sponsored by:" / "Powered by:" on one line, the name highlighted on the next.
class _Credit extends StatelessWidget {
  const _Credit({super.key, required this.label, required this.name, this.large = false});
  final String label;
  final String name;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nameStyle = (large ? theme.textTheme.titleLarge : theme.textTheme.titleMedium)?.copyWith(
      fontWeight: FontWeight.w800,
      color: theme.colorScheme.primary,
    );
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        Text(name, textAlign: TextAlign.center, style: nameStyle),
      ],
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.titleSmall)),
      ],
    ),
  );
}
