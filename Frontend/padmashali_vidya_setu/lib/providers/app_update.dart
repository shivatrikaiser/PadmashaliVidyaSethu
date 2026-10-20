import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/app_version.dart';
import '../repositories/repositories.dart';
import 'providers.dart';

/// 'android' / 'ios' for the store builds; null elsewhere (web, desktop), where no update check runs.
final appPlatformProvider = Provider<String?>((ref) {
  if (kIsWeb) return null;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    _ => null,
  };
});

/// The installed app's version name (pubspec.yaml `version:` without the build number).
final installedVersionProvider = FutureProvider<String>((ref) async => (await PackageInfo.fromPlatform()).version);

enum AppUpdateStatus { upToDate, optional, required }

class AppUpdateState {
  const AppUpdateState({this.status = AppUpdateStatus.upToDate, this.latest, this.dismissed = false});
  final AppUpdateStatus status;
  final AppVersionInfo? latest;

  /// The member closed the optional "update available" bar (until a newer version appears).
  final bool dismissed;
}

final appUpdateProvider = StateNotifierProvider<AppUpdateNotifier, AppUpdateState>(
  (ref) => AppUpdateNotifier(ref, ref.watch(masterDataRepositoryProvider)),
);

/// Compares the installed version with the current release (table PVS_AppVersions). Called on every screen and
/// whenever the app returns to the foreground. When the check cannot run (offline, server trouble) the last known
/// state stays, so members are never locked out by a weak signal.
class AppUpdateNotifier extends StateNotifier<AppUpdateState> {
  AppUpdateNotifier(this._ref, this._repository) : super(const AppUpdateState());

  final Ref _ref;
  final MasterDataRepository _repository;
  bool _checking = false;

  Future<void> check() async {
    final platform = _ref.read(appPlatformProvider);
    if (platform == null || _checking) return;
    _checking = true;
    try {
      final installed = await _ref.read(installedVersionProvider.future);
      final latest = await _repository.appVersion(platform);
      if (!mounted) return;
      final outdated = compareVersions(installed, latest.latestVersion) < 0;
      final status = !outdated
          ? AppUpdateStatus.upToDate
          : latest.isMandatory
          ? AppUpdateStatus.required
          : AppUpdateStatus.optional;
      final sameRelease = state.latest?.latestVersion == latest.latestVersion;
      state = AppUpdateState(status: status, latest: latest, dismissed: sameRelease && state.dismissed);
    } catch (_) {
      // Keep the last known state.
    } finally {
      _checking = false;
    }
  }

  void dismiss() => state = AppUpdateState(status: state.status, latest: state.latest, dismissed: true);
}
