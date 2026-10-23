import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/app_update.dart';
import '../providers/providers.dart';
import '../routing/routes.dart';
import '../utils/l10n.dart';
import 'app_update_views.dart';
import 'marquee_text.dart';

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

/// Footer of every screen, from the admin portal ([appBrandingProvider]); nothing while it loads or when empty:
/// * "Sponsored by:" stays fixed and the active sponsors ("Name, Designation, Company", one after another) scroll
///   beside it when they do not fit;
/// * "Technology Powered by IQ Explore" - tapping the name opens its link (the IQ Explore app on Google Play).
class AppFooter extends ConsumerWidget {
  const AppFooter({super.key});

  static const _separator = '   \u2022   ';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(appBrandingProvider).valueOrNull;
    final sponsors = branding?.footerSponsors ?? const [];
    final poweredBy = branding?.poweredBy;
    final poweredByUrl = branding?.poweredByUrl;
    final hasSponsors = sponsors.isNotEmpty;
    final hasPoweredBy = poweredBy != null && poweredBy.isNotEmpty;
    if (!hasSponsors && !hasPoweredBy) return const SizedBox.shrink();

    final l10n = context.l10n;
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final nameStyle = labelStyle?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary);

    return Material(
      color: theme.colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasSponsors)
              Row(
                key: const Key('footerSponsor'),
                children: [
                  Text(l10n.sponsoredBy, style: labelStyle),
                  const SizedBox(width: 6),
                  Expanded(
                    child: MarqueeText(
                      key: const Key('footerSponsorNames'),
                      sponsors.map((s) => s.text).join(_separator),
                      style: nameStyle,
                    ),
                  ),
                ],
              ),
            if (hasSponsors && hasPoweredBy) const SizedBox(height: 4),
            if (hasPoweredBy)
              Row(
                key: const Key('footerPoweredBy'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // On a narrow screen the label gives way ("...") so the name stays readable and tappable.
                  Flexible(
                    child: Text(
                      '${l10n.technologyPoweredBy} ',
                      style: labelStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (poweredByUrl != null && poweredByUrl.isNotEmpty)
                    Semantics(
                      link: true,
                      child: InkWell(
                        key: const Key('footerPoweredByLink'),
                        onTap: () => _open(poweredByUrl),
                        child: Text(
                          poweredBy,
                          style: nameStyle?.copyWith(decoration: TextDecoration.underline),
                          maxLines: 1,
                        ),
                      ),
                    )
                  else
                    Text(poweredBy, style: nameStyle, maxLines: 1),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Opens the link outside the app, so a Google Play link opens the Play Store app.
  static Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
