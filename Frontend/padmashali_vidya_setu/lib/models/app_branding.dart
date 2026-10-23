/// One sponsor credited in the footer (active ones only, in display order).
class FooterSponsor {
  const FooterSponsor({required this.name, this.designation, this.companyName});

  final String name;
  final String? designation;
  final String? companyName;

  /// "Name, Designation, Company" - the parts that are set.
  String get text => [
    name,
    if (designation?.isNotEmpty ?? false) designation!,
    if (companyName?.isNotEmpty ?? false) companyName!,
  ].join(', ');

  factory FooterSponsor.fromJson(Object? json) {
    final m = json! as Map<String, Object?>;
    return FooterSponsor(
      name: m['name']! as String,
      designation: m['designation'] as String?,
      companyName: m['companyName'] as String?,
    );
  }
}

/// Sponsor (name, organisation, address), footer sponsors and "Technology Powered by", managed by Super Admins in
/// the admin portal. The single sponsor is shown on the splash and welcome screens; the footer of every screen shows
/// [footerSponsors] and [poweredBy].
class AppBranding {
  const AppBranding({
    this.sponsorName,
    this.sponsorOrganisation,
    this.sponsorAddress,
    this.poweredBy,
    this.sponsorLogoVersion,
    this.poweredByUrl,
    this.footerSponsors = const [],
  });

  final String? sponsorName;
  final String? sponsorOrganisation;

  /// Up to four lines separated by '\n'.
  final String? sponsorAddress;
  final String? poweredBy;

  /// Opened when [poweredBy] is tapped (the IQ Explore app on Google Play).
  final String? poweredByUrl;

  final List<FooterSponsor> footerSponsors;

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
      poweredByUrl: m['poweredByUrl'] as String?,
      footerSponsors: ((m['footerSponsors'] as List<Object?>?) ?? const []).map(FooterSponsor.fromJson).toList(),
    );
  }
}
