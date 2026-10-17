import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../core/api/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/app_branding.dart';
import '../models/master_data_item.dart';
import '../models/member_models.dart';
import '../repositories/repositories.dart';
import 'session.dart';

export 'session.dart';

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());

/// How long the splash artwork stays on screen at start-up, at least (tests use zero).
final splashMinimumDisplayProvider = Provider<Duration>((ref) => const Duration(milliseconds: 1800));

final tokenStorageProvider = Provider<TokenStorage>((ref) => SecureTokenStorage());

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(
    baseUrl: ref.watch(appConfigProvider).apiBaseUrl,
    tokenStorage: ref.watch(tokenStorageProvider),
    // Read lazily: the session notifier itself depends on the API client.
    onSessionExpired: () => ref.read(sessionProvider.notifier).onSessionExpired(),
  ),
);

final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);
final Provider<MasterDataRepository> masterDataRepositoryProvider = Provider<MasterDataRepository>(
  (ref) => MasterDataRepository(ref.watch(apiClientProvider)),
);
final Provider<MemberRepository> memberRepositoryProvider = Provider<MemberRepository>(
  (ref) => MemberRepository(ref.watch(apiClientProvider)),
);

final StateNotifierProvider<SessionNotifier, SessionState> sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>(
      (ref) => SessionNotifier(
        tokens: ref.watch(tokenStorageProvider),
        auth: ref.watch(authRepositoryProvider),
        members: ref.watch(memberRepositoryProvider),
      ),
    );

/// Cached dropdown lists, keyed by master-data type (see [MasterDataTypes]).
/// Sponsor / "Powered by" for the splash screen.
final appBrandingProvider = FutureProvider<AppBranding>((ref) => ref.watch(masterDataRepositoryProvider).branding());

/// URL of the sponsor logo for [branding], or null when there is none.
String? sponsorLogoUrl(AppConfig config, AppBranding branding) => branding.sponsorLogoVersion == null
    ? null
    : '${config.apiBaseUrl}/api/v1/app/branding/sponsor-logo?v=${branding.sponsorLogoVersion}';

final masterDataProvider = FutureProvider.family<List<MasterDataItem>, String>(
  (ref, type) => ref.watch(masterDataRepositoryProvider).list(type),
);

final statesProvider = FutureProvider.family<List<MasterDataItem>, int>(
  (ref, countryId) => ref.watch(masterDataRepositoryProvider).states(countryId),
);

final districtsProvider = FutureProvider.family<List<MasterDataItem>, int>(
  (ref, stateId) => ref.watch(masterDataRepositoryProvider).districts(stateId),
);

final taluksProvider = FutureProvider.autoDispose.family<List<MasterDataItem>, int>(
  (ref, districtId) => ref.watch(masterDataRepositoryProvider).taluks(districtId),
);

final dashboardProvider = FutureProvider.autoDispose.family<MemberDashboard, String>(
  (ref, registrationId) => ref.watch(memberRepositoryProvider).dashboard(registrationId),
);

final profileProvider = FutureProvider.autoDispose.family<MemberProfile, String>(
  (ref, registrationId) => ref.watch(memberRepositoryProvider).profile(registrationId),
);

/// Phone verification in progress (mobile number + issued challenge).
final pendingVerificationProvider = StateProvider<PendingVerification?>((ref) => null);
