import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../routing/routes.dart';
import '../../utils/l10n.dart';
import '../../widgets/brand.dart';
import '../../widgets/common.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final expired = ref.watch(sessionProvider.select((s) => s.expired));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveBody(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: BrandMark(size: 80)),
                const SizedBox(height: 16),
                Text(
                  l10n.appTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.appTagline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.organisationName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                if (expired) ...[ErrorBanner(message: l10n.errorSessionExpired), const SizedBox(height: 16)],
                Text(l10n.welcomeHeading, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(l10n.welcomeBody, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 12),
                _Feature(icon: Icons.school_outlined, text: l10n.welcomeFeatureEducation),
                _Feature(icon: Icons.lightbulb_outline, text: l10n.welcomeFeatureCareer),
                _Feature(icon: Icons.workspace_premium_outlined, text: l10n.welcomeFeatureOpportunities),
                const SizedBox(height: 24),
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

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.titleMedium)),
      ],
    ),
  );
}
