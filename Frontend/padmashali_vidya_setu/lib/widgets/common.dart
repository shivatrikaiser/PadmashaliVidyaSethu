import 'package:flutter/material.dart';

import '../utils/l10n.dart';

/// Centres content and caps its width so forms stay readable on tablets.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({super.key, required this.child, this.maxWidth = 640, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    // Size to the child vertically; otherwise this fills all available height (e.g. as a Scaffold
    // bottomNavigationBar it would take the whole screen and squeeze the body).
    heightFactor: 1,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(padding: padding, child: child),
    ),
  );
}

/// A titled card grouping related fields or information.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, this.icon, this.subtitle, required this.children, this.trailing});

  final String title;
  final IconData? icon;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (icon != null) ...[Icon(icon, color: theme.colorScheme.primary), const SizedBox(width: 10)],
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ),
                ?trailing,
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Vertical spacing between form fields.
class FieldGap extends StatelessWidget {
  const FieldGap({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(height: 16);
}

/// Filled button that shows a spinner and ignores taps while [loading].
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.loading = false, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
        : Text(label);
    return icon == null || loading
        ? FilledButton(onPressed: loading ? null : onPressed, child: child)
        : FilledButton.icon(onPressed: onPressed, icon: Icon(icon), label: child);
  }
}

/// Inline error message with an optional retry action.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: scheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: scheme.onErrorContainer)),
            ),
            if (onRetry != null) TextButton(onPressed: onRetry, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }
}

/// Informational note (used for privacy and help text).
class InfoNote extends StatelessWidget {
  const InfoNote({super.key, required this.text, this.icon = Icons.info_outline});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
}
