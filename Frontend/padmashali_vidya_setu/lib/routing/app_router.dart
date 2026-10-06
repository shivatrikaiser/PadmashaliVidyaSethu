import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/providers.dart';
import '../screens/auth/phone_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/verify_code_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/registration/registration_complete_screen.dart';
import '../screens/registration/registration_screen.dart';
import 'routes.dart';

/// Navigation follows the session:
/// * unknown → splash (checking stored tokens)
/// * signed out → welcome / phone / verify only
/// * signed in, no member registered yet → registration
/// * signed in with members → home (registration stays reachable for adding family members)
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<SessionState>(ref.read(sessionProvider));
  ref.listen(sessionProvider, (_, next) => refresh.value = next);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => redirectFor(refresh.value, state.matchedLocation),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.welcome, builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: Routes.phone, builder: (_, _) => const PhoneScreen()),
      GoRoute(path: Routes.verify, builder: (_, _) => const VerifyCodeScreen()),
      GoRoute(path: Routes.register, builder: (_, _) => const RegistrationScreen()),
      GoRoute(
        path: Routes.registrationComplete,
        builder: (_, state) => RegistrationCompleteScreen(args: state.extra as RegistrationCompleteArgs?),
      ),
      GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: Routes.profilePattern,
        builder: (_, state) => ProfileScreen(registrationId: state.pathParameters['registrationId']!),
      ),
    ],
  );
});

/// Pure redirect rule, unit-tested separately.
@visibleForTesting
String? redirectFor(SessionState session, String location) {
  switch (session.status) {
    case SessionStatus.unknown:
      return location == Routes.splash ? null : Routes.splash;
    case SessionStatus.signedOut:
      return Routes.public.contains(location) ? null : Routes.welcome;
    case SessionStatus.signedIn:
      if (!session.hasMembers) {
        return location == Routes.register ? null : Routes.register;
      }
      if (location == Routes.splash || Routes.public.contains(location)) return Routes.home;
      return null;
  }
}
