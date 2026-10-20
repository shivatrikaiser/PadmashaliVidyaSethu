/// Sponsor (name, organisation, address) and "Powered by", managed by Super Admins in the admin portal. Shown on
/// the splash and welcome screens and in the footer of every screen.
class AppBranding {
  const AppBranding({
    this.sponsorName,
    this.sponsorOrganisation,
    this.sponsorAddress,
    this.poweredBy,
    this.sponsorLogoVersion,
  });

  final String? sponsorName;
  final String? sponsorOrganisation;

  /// Up to four lines separated by '\n'.
  final String? sponsorAddress;
  final String? poweredBy;

  /// Set when a sponsor logo exists; changes with every edit (used in the logo URL so caches refresh).
  final String? sponsorLogoVersion;

  bool get hasSponsor => (sponsorName?.isNotEmpty ?? false) || sponsorLogoVersion != null;

  List<String> get sponsorAddressLines =>
      (sponsorAddress ?? '').split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

  factory AppBranding.fromJson(Object? json) {
    final m = json! as Map<String, Object?>;
    return AppBranding(
      sponsorName: m['sponsorName'] as String?,
      sponsorOrganisation: m['sponsorOrganisation'] as String?,
      sponsorAddress: m['sponsorAddress'] as String?,
      poweredBy: m['poweredBy'] as String?,
      sponsorLogoVersion: m['hasSponsorLogo'] == true ? m['sponsorLogoVersion'] as String? : null,
    );
  }
}
