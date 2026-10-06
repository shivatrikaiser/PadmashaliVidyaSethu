import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../utils/l10n.dart';
import '../../widgets/common.dart';
import '../../widgets/brand.dart';

/// Shown while a stored session is checked. Offers a retry if the server cannot be reached.
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    setState(() => _error = null);
    try {
      await ref.read(sessionProvider.notifier).bootstrap();
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ResponsiveBody(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandMark(size: 88),
                const SizedBox(height: 24),
                Text(l10n.appTitle, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: 32),
                if (_error == null)
                  const CircularProgressIndicator()
                else
                  ErrorBanner(message: describeError(l10n, _error!), onRetry: _bootstrap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
