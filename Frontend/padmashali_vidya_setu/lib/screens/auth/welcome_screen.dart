import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/app_branding.dart';
import '../../providers/providers.dart';
import '../../routing/routes.dart';
import '../../utils/l10n.dart';
import '../../widgets/brand.dart';
import '../../widgets/common.dart';

/// Logo, the sponsor's name, organisation and address (from the admin portal), a divider, then the welcome text -
/// filling the full screen height above the app footer (which shows the sponsor and "Powered by" on every screen): the logo scales with the height and "Get Started" sits at the bottom (it scrolls instead on very
/// small screens or with large text).
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final expired = ref.watch(sessionProvider.select((s) => s.expired));
    final branding = ref.watch(appBrandingProvider).valueOrNull;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: ResponsiveBody(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      // About a quarter of the available height, so everything below still fits without scrolling.
                      Center(
                        child: BrandLogo(
                          semanticLabel: l10n.appTitle,
                          height: (constraints.maxHeight * 0.24).clamp(130.0, 360.0),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        child: branding == null ? const SizedBox(width: double.infinity) : _Sponsor(branding: branding),
                      ),
                      const Spacer(),
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
                      const Spacer(flex: 2),
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
          ),
        ),
      ),
    );
  }
}

/// "Sponsored by:", then the sponsor's name (highlighted), organisation and address - each line only when set.
class _Sponsor extends StatelessWidget {
  const _Sponsor({required this.branding});
  final AppBranding branding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final name = branding.sponsorName;
    final organisation = branding.sponsorOrganisation;
    final address = branding.sponsorAddressLines;
    final hasName = name != null && name.isNotEmpty;
    final hasOrganisation = organisation != null && organisation.isNotEmpty;
    if (!hasName && !hasOrganisation && address.isEmpty) return const SizedBox(width: double.infinity);

    return Column(
      key: const Key('welcomeSponsor'),
      children: [
        Text(
          context.l10n.sponsoredBy,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
        if (hasName)
          Text(
            name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: theme.colorScheme.primary),
          ),
        if (hasOrganisation)
          Text(
            organisation,
            key: const Key('welcomeSponsorOrganisation'),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall,
          ),
        if (address.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              address.join('\n'),
              key: const Key('welcomeSponsorAddress'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ),
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
