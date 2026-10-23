import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padmashali_vidya_setu/core/api/api_client.dart';
import 'package:padmashali_vidya_setu/core/api/api_exception.dart';
import 'package:padmashali_vidya_setu/core/storage/token_storage.dart';
import 'package:padmashali_vidya_setu/l10n/generated/app_localizations.dart';
import 'package:padmashali_vidya_setu/models/app_branding.dart';
import 'package:padmashali_vidya_setu/models/app_version.dart';
import 'package:padmashali_vidya_setu/providers/app_update.dart';
import 'package:padmashali_vidya_setu/models/location_models.dart';
import 'package:padmashali_vidya_setu/models/master_data_item.dart';
import 'package:padmashali_vidya_setu/providers/providers.dart';
import 'package:padmashali_vidya_setu/repositories/repositories.dart';
import 'package:padmashali_vidya_setu/theme/app_theme.dart';

MasterDataItem item(int id, String name, String code) => MasterDataItem(id: id, name: name, code: code);

/// Master data shaped like the seeded backend lists.
final fakeLists = <String, List<MasterDataItem>>{
  MasterDataTypes.memberStatuses: [
    item(1, 'Student', 'STUDENT'),
    item(2, 'Working', 'WORKING'),
    item(3, 'Unemployed', 'UNEMPLOYED'),
  ],
  MasterDataTypes.genders: [
    item(1, 'Male', 'MALE'),
    item(2, 'Female', 'FEMALE'),
    item(3, 'Other / Prefer not to say', 'OTHER'),
  ],
  MasterDataTypes.classes: [item(1, 'LKG', 'LKG'), item(12, 'Class 10', 'CLASS_10'), item(13, 'PUC 1', 'PUC_1')],
  MasterDataTypes.educationLevels: [
    item(2, 'Class 10 / SSLC', 'SSLC'),
    item(6, 'Undergraduate Degree', 'UG'),
    item(14, 'Other', 'OTHER'),
  ],
  MasterDataTypes.temples: [item(1, 'Temple 01', '01'), item(2, 'Temple 02', '02')],
  MasterDataTypes.organisations: [item(1, 'DK District', 'DK'), item(6, 'Not Linked to Any Organisation', 'NONE')],
  MasterDataTypes.disabilityTypes: [
    item(1, 'Visual Impairment', 'VISUAL'),
    item(2, 'Hearing Impairment', 'HEARING'),
    item(8, 'Other', 'OTHER'),
  ],
  MasterDataTypes.countries: [
    item(1, 'India', 'IN'),
    item(2, 'United Arab Emirates', 'AE'),
    item(8, 'United States', 'US'),
  ],
};

class FakeMasterDataRepository implements MasterDataRepository {
  @override
  Future<AppBranding> branding() async => const AppBranding(
    sponsorName: 'Test Sponsor',
    sponsorOrganisation: 'Test Textiles Pvt Ltd',
    sponsorAddress: '12, Car Street\nUdupi 576101',
    poweredBy: 'IQ Explore',
    poweredByUrl: 'https://play.google.com/store/apps/details?id=com.iqexplore.app',
    // Short enough to fit the test screens, so the footer stands still (MarqueeText is tested on its own).
    footerSponsors: [FooterSponsor(name: 'Test Sponsor')],
  );

  int pinLookups = 0;

  /// What `GET /app/version` returns; [versionError] makes it fail (offline).
  AppVersionInfo version = const AppVersionInfo(latestVersion: '1.0.0', isMandatory: true);
  Object? versionError;
  int versionChecks = 0;

  @override
  Future<AppVersionInfo> appVersion(String platform) async {
    versionChecks++;
    if (versionError != null) throw versionError!;
    return version;
  }

  @override
  Future<List<MasterDataItem>> list(String type) async => fakeLists[type] ?? const [];

  @override
  Future<List<MasterDataItem>> states(int countryId) async => switch (countryId) {
    1 => [item(11, 'Karnataka', 'IN-KA'), item(14, 'Maharashtra', 'IN-MH')],
    8 => [item(40, 'California', 'US-CALIFORNIA')],
    _ => [], // no states known yet for the country
  };

  @override
  Future<List<MasterDataItem>> districts(int stateId) async => stateId == 11
      ? [item(11, 'Dakshina Kannada', 'KA-DK'), item(27, 'Udupi', 'KA-UDP')]
      : [item(32, 'Mumbai', 'IN-MH-MUMBAI')];

  @override
  Future<List<MasterDataItem>> taluks(int districtId) async =>
      districtId == 11 ? [item(1, 'Mangaluru', 'KA-DK-MANGALURU'), item(3, 'Puttur', 'KA-DK-PUTTUR')] : [];

  @override
  Future<PinLookupResult> lookupPinCode(String pinCode) async {
    pinLookups++;
    if (pinCode != '574201') {
      throw const ApiException(kind: ApiErrorKind.notFound, message: 'not found', statusCode: 404);
    }
    return PinLookupResult(
      pinCode: pinCode,
      country: item(1, 'India', 'IN'),
      state: item(11, 'Karnataka', 'IN-KA'),
      district: item(11, 'Dakshina Kannada', 'KA-DK'),
      localities: const [
        Locality(cityId: 1, name: 'Bolwar', talukId: 3),
        Locality(cityId: 2, name: 'Puttur(D.K.)', talukId: 3),
      ],
      taluks: [item(3, 'Puttur', 'KA-DK-PUTTUR')],
      suggestedTalukId: 3,
    );
  }
}

/// Provider overrides that keep widget tests offline.
List<Override> testOverrides({FakeMasterDataRepository? masterData}) => [
  splashMinimumDisplayProvider.overrideWithValue(Duration.zero),
  tokenStorageProvider.overrideWithValue(MemoryTokenStorage()),
  apiClientProvider.overrideWithValue(
    ApiClient(baseUrl: 'http://test.invalid', tokenStorage: MemoryTokenStorage(), onSessionExpired: () {}),
  ),
  masterDataRepositoryProvider.overrideWithValue(masterData ?? FakeMasterDataRepository()),
  // No version check unless a test opts in (see app_update_test.dart).
  appPlatformProvider.overrideWithValue(null),
];

/// Pumps [child] inside a localized, themed MaterialApp with test providers.
Future<void> pumpLocalized(WidgetTester tester, Widget child, {List<Override>? overrides}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides ?? testOverrides(),
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
