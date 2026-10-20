import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padmashali_vidya_setu/app.dart';
import 'package:padmashali_vidya_setu/core/api/api_exception.dart';
import 'package:padmashali_vidya_setu/models/app_version.dart';
import 'package:padmashali_vidya_setu/providers/app_update.dart';

import '../helpers.dart';

void main() {
  /// Starts the app as an Android build with version 1.0.0 installed.
  Future<FakeMasterDataRepository> start(WidgetTester tester, {AppVersionInfo? latest, Object? error}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final repo = FakeMasterDataRepository();
    if (latest != null) repo.version = latest;
    repo.versionError = error;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...testOverrides(masterData: repo),
          appPlatformProvider.overrideWithValue('android'),
          installedVersionProvider.overrideWith((ref) async => '1.0.0'),
        ],
        child: const PvsApp(),
      ),
    );
    await tester.pumpAndSettle();
    return repo;
  }

  test('versions compare numerically', () {
    expect(compareVersions('1.0.9', '1.0.10'), lessThan(0));
    expect(compareVersions('1.2.0', '1.1.9'), greaterThan(0));
    expect(compareVersions('1.0.0+7', '1.0.0'), 0);
    expect(compareVersions('1.0', '1.0.0'), 0);
  });

  testWidgets('same version: nothing shown; checked again on every screen', (tester) async {
    final repo = await start(tester);
    expect(find.byKey(const Key('updateRequired')), findsNothing);
    expect(find.byKey(const Key('updateAvailable')), findsNothing);

    final before = repo.versionChecks;
    await tester.tap(find.byKey(const Key('getStartedButton')));
    await tester.pumpAndSettle();
    expect(repo.versionChecks, greaterThan(before));
  });

  testWidgets('older than a mandatory release: the app is blocked with an update screen', (tester) async {
    await start(
      tester,
      latest: const AppVersionInfo(latestVersion: '1.0.1', isMandatory: true, storeUrl: 'https://example.org'),
    );
    expect(find.byKey(const Key('updateRequired')), findsOneWidget);
    expect(find.text('Update required'), findsOneWidget);
    expect(find.text('Your version: 1.0.0   Latest: 1.0.1'), findsOneWidget);
    expect(find.byKey(const Key('updateNowButton')), findsOneWidget);
  });

  testWidgets('older than an optional release: a dismissible bar', (tester) async {
    await start(tester, latest: const AppVersionInfo(latestVersion: '1.1.0', isMandatory: false));
    expect(find.byKey(const Key('updateRequired')), findsNothing);
    expect(find.byKey(const Key('updateAvailable')), findsOneWidget);

    await tester.tap(find.byKey(const Key('dismissUpdateButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('updateAvailable')), findsNothing);
  });

  testWidgets('version cannot be loaded (offline): the app stays usable', (tester) async {
    await start(tester, error: const ApiException(kind: ApiErrorKind.network, message: null));
    expect(find.byKey(const Key('updateRequired')), findsNothing);
    expect(find.byKey(const Key('getStartedButton')), findsOneWidget);
  });
}
