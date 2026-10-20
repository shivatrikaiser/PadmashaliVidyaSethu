/// The current app release for this platform (table PVS_AppVersions), see `GET /api/v1/app/version`.
class AppVersionInfo {
  const AppVersionInfo({required this.latestVersion, required this.isMandatory, this.storeUrl});

  /// major.minor.patch, e.g. "1.0.3" - the version name in pubspec.yaml.
  final String latestVersion;

  /// True: an older app cannot be used until updated. False: the update is offered but optional.
  final bool isMandatory;

  /// Play Store / App Store page; null hides the "Update now" button.
  final String? storeUrl;

  factory AppVersionInfo.fromJson(Object? json) {
    final m = json! as Map<String, Object?>;
    return AppVersionInfo(
      latestVersion: m['latestVersion']! as String,
      isMandatory: m['isMandatory'] == true,
      storeUrl: m['storeUrl'] as String?,
    );
  }
}

/// Compares "major.minor.patch" versions numerically ("1.0.10" > "1.0.9"). A "+build" suffix and missing parts
/// are ignored / treated as 0. Negative when [a] is older than [b].
int compareVersions(String a, String b) {
  List<int> parts(String v) => v.split('+').first.split('.').map((p) => int.tryParse(p.trim()) ?? 0).toList();
  final x = parts(a);
  final y = parts(b);
  for (var i = 0; i < 3; i++) {
    final diff = (i < x.length ? x[i] : 0) - (i < y.length ? y[i] : 0);
    if (diff != 0) return diff;
  }
  return 0;
}
