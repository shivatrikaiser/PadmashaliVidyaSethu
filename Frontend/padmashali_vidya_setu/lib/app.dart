import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/generated/app_localizations.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';
import 'widgets/app_footer.dart';
import 'widgets/tablet_scale.dart';

class PvsApp extends ConsumerWidget {
  const PvsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
      // English now; Kannada (kn) and Hindi (hi) are added by dropping app_kn.arb / app_hi.arb into lib/l10n.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Respect the user's font size, but cap extreme scales that would break layouts. Only the maximum is
      // clamped: a minimum here conflicts with widgets that apply their own tighter cap (e.g. the date picker).
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: media.textScaler.clamp(maxScaleFactor: 1.6)),
          // Tablets: the whole interface is enlarged to fill the screen (phones and web unchanged).
          // Sponsor / "Powered by" footer under every screen.
          child: TabletScale(child: AppFrame(router: router, child: child!)),
        );
      },
    );
  }
}
