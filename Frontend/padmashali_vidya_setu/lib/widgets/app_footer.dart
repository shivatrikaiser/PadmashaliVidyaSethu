import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_update.dart';
import '../providers/providers.dart';
import '../routing/routes.dart';
import '../utils/l10n.dart';
import 'app_update_views.dart';

/// Wraps every screen (used from `MaterialApp.builder`):
/// * [AppFooter] at the bottom - hidden on the splash screen, which shows its own sponsor card, and while the
///   keyboard is open so forms keep their space;
/// * the app version check on every screen change and whenever the app returns to the foreground - an outdated
///   app shows [UpdateRequiredView] over everything, or [UpdateAvailableBar] when the update is optional.
class AppFrame extends ConsumerStatefulWidget {
  const AppFrame({super.key, required this.router, required this.child});
  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<AppFrame> createState() => _AppFrameState();
}

class _AppFrameState extends ConsumerState<AppFrame> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    widget.router.routerDelegate.addListener(_routeChanged);
    WidgetsBinding.instance.addObserver(this);
    _routeChanged();
  }

  @override
  void didUpdateWidget(AppFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.router != widget.router) {
      oldWidget.router.routerDelegate.removeListener(_routeChanged);
      widget.router.routerDelegate.addListener(_routeChanged);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.router.routerDelegate.removeListener(_routeChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ref.read(appUpdateProvider.notifier).check();
  }

  /// The router notifies while the app is building (first route, redirects), so act after the current frame.
  void _routeChanged() {
    SchedulerBinding.instance
      ..addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {});
        ref.read(appUpdateProvider.notifier).check();
      })
      ..ensureVisualUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final update = ref.watch(appUpdateProvider);
    final onSplash = widget.router.routerDelegate.currentConfiguration.uri.path == Routes.splash;
    final show = !onSplash && MediaQuery.viewInsetsOf(context).bottom == 0;
    final offerUpdate = show && update.status == AppUpdateStatus.optional && !update.dismissed;
    // Same widget tree whatever is shown, so the screens keep their state.
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              // The footer takes the bottom safe area, so the screens above must not pad for it again.
              child: MediaQuery.removePadding(context: context, removeBottom: show, child: widget.child),
            ),
            if (offerUpdate) UpdateAvailableBar(latest: update.latest!),
            if (show) const AppFooter(),
          ],
        ),
        if (update.status == AppUpdateStatus.required)
          Positioned.fill(child: UpdateRequiredView(latest: update.latest!)),
      ],
    );
  }
}

/// "Sponsored by" and "Powered by" from the admin portal ([appBrandingProvider]); nothing while they load or when
/// both are empty.
class AppFooter extends ConsumerWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(appBrandingProvider).valueOrNull;
    final sponsor = branding?.sponsorName;
    final poweredBy = branding?.poweredBy;
    final hasSponsor = sponsor != null && sponsor.isNotEmpty;
    final hasPoweredBy = poweredBy != null && poweredBy.isNotEmpty;
    if (!hasSponsor && !hasPoweredBy) return const SizedBox.shrink();

    final l10n = context.l10n;
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final nameStyle = labelStyle?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary);
    Widget credit(Key key, String label, String name) => Text.rich(
      key: key,
      TextSpan(
        text: '$label ',
        style: labelStyle,
        children: [TextSpan(text: name, style: nameStyle)],
      ),
      textAlign: TextAlign.center,
      // Each credit on its own single line; a very long name is shortened with "...".
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return Material(
      color: theme.colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasSponsor) credit(const Key('footerSponsor'), l10n.sponsoredBy, sponsor),
            if (hasSponsor && hasPoweredBy) const SizedBox(height: 2),
            if (hasPoweredBy) credit(const Key('footerPoweredBy'), '${l10n.poweredBy}:', poweredBy),
          ],
        ),
      ),
    );
  }
}
