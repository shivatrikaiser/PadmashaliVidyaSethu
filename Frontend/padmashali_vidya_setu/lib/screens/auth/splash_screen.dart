import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../utils/l10n.dart';
import '../../widgets/brand.dart';
import '../../widgets/common.dart';
import '../../widgets/splash_artwork.dart';

/// Splash artwork (logo, tagline, students) with the sponsor card and "Powered by" line underneath, shown at
/// least [splashMinimumDisplayProvider] while the stored session is checked. The sponsor and "Powered by" are
/// managed by Super Admins (admin portal) and drawn as text, so they change without a new app release.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap(ref.read(splashMinimumDisplayProvider)));
  }

  Future<void> _bootstrap([Duration minimumDisplay = Duration.zero]) async {
    setState(() => _error = null);
    try {
      await ref.read(sessionProvider.notifier).bootstrap(minimumDuration: minimumDisplay);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: SplashColors.cream,
      body: Column(
        // Stretch so the footer's waves span the full width.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // When space is short (e.g. tall sponsor card), trim the empty glow at the top rather than the students.
                Image.asset(
                  BrandAssets.splash,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, 0.6),
                  semanticLabel: l10n.appTitle,
                ),
                const SplashArtworkFade(),
                SafeArea(
                  child: Column(
                    children: [
                      if (_error == null)
                        const LinearProgressIndicator(minHeight: 3, backgroundColor: Colors.transparent)
                      else ...[
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: ErrorBanner(message: describeError(l10n, _error!), onRetry: _bootstrap),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SplashFooter(),
        ],
      ),
    );
  }
}
