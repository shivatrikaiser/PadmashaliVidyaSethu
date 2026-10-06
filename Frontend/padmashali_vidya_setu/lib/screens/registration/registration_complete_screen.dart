import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/member_models.dart';
import '../../routing/routes.dart';
import '../../utils/l10n.dart';
import '../../widgets/common.dart';

class RegistrationCompleteArgs {
  const RegistrationCompleteArgs({required this.result, required this.isStudent});
  final RegistrationResult result;
  final bool isStudent;
}

class RegistrationCompleteScreen extends StatelessWidget {
  const RegistrationCompleteScreen({super.key, required this.args});

  final RegistrationCompleteArgs? args;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final result = args?.result;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ResponsiveBody(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.check_circle_rounded, size: 96, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    l10n.registrationSuccessTitle,
                    key: const Key('registrationSuccessTitle'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 24),
                  if (result != null)
                    Card(
                      color: theme.colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              args!.isStudent ? l10n.studentIdLabel : l10n.registrationIdLabel,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 6),
                            SelectableText(
                              result.registrationId,
                              key: const Key('registrationIdText'),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(result.fullName, style: theme.textTheme.titleMedium),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(l10n.welcomeToPvs, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(l10n.basicProfileCreated, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    key: const Key('continueToProfileButton'),
                    label: l10n.continueToProfile,
                    onPressed: () => context.go(Routes.home),
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
