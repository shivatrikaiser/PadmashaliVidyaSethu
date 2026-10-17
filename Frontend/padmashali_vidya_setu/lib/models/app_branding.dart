/// Sponsor and "Powered by" for the splash screen, managed by Super Admins in the admin portal.
class AppBranding {
  const AppBranding({this.sponsorName, this.poweredBy, this.sponsorLogoVersion});

  final String? sponsorName;
  final String? poweredBy;

  /// Set when a sponsor logo exists; changes with every edit (used in the logo URL so caches refresh).
  final String? sponsorLogoVersion;

  bool get hasSponsor => (sponsorName?.isNotEmpty ?? false) || sponsorLogoVersion != null;

  factory AppBranding.fromJson(Object? json) {
    final m = json! as Map<String, Object?>;
    return AppBranding(
      sponsorName: m['sponsorName'] as String?,
      poweredBy: m['poweredBy'] as String?,
      sponsorLogoVersion: m['hasSponsorLogo'] == true ? m['sponsorLogoVersion'] as String? : null,
    );
  }
}
