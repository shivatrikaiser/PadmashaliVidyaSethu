import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padmashali_vidya_setu/models/app_branding.dart';
import 'package:padmashali_vidya_setu/providers/providers.dart';
import 'package:padmashali_vidya_setu/widgets/app_footer.dart';
import 'package:padmashali_vidya_setu/widgets/marquee_text.dart';

import '../helpers.dart';

class _Branding extends FakeMasterDataRepository {
  _Branding(this.value);
  final AppBranding value;

  @override
  Future<AppBranding> branding() async => value;
}

Future<void> _pumpFooter(WidgetTester tester, AppBranding branding) => pumpLocalized(
  tester,
  const Align(alignment: Alignment.bottomCenter, child: AppFooter()),
  overrides: [...testOverrides(), masterDataRepositoryProvider.overrideWithValue(_Branding(branding))],
);

double _scrollOffset(WidgetTester tester) {
  final transform = tester.widget<Transform>(
    find.descendant(of: find.byType(MarqueeText), matching: find.byType(Transform)),
  );
  return transform.transform.getTranslation().x;
}

void main() {
  group('AppFooter', () {
    testWidgets('"Sponsored by:" with the active sponsors; "Technology Powered by" with a link', (tester) async {
      await _pumpFooter(
        tester,
        const AppBranding(
          poweredBy: 'IQ Explore',
          poweredByUrl: 'https://play.google.com/store/apps/details?id=com.iqexplore.app',
          footerSponsors: [
            FooterSponsor(name: 'A'),
            FooterSponsor(name: 'B', companyName: 'C'),
          ],
        ),
      );

      expect(find.text('Sponsored by:'), findsOneWidget);
      expect(find.text('A   •   B, C'), findsOneWidget); // the part that scrolls when it does not fit
      expect(find.text('Technology Powered by '), findsOneWidget);
      expect(find.byKey(const Key('footerPoweredByLink')), findsOneWidget);
      expect(find.text('IQ Explore'), findsOneWidget);
    });

    test('a sponsor reads "Name, Designation, Company" (parts that are set)', () {
      expect(
        const FooterSponsor(name: 'Asha', designation: 'MD', companyName: 'Laxmi Silks').text,
        'Asha, MD, Laxmi Silks',
      );
      expect(const FooterSponsor(name: 'Ravi', companyName: 'Co').text, 'Ravi, Co');
      expect(const FooterSponsor(name: 'Ravi', designation: '').text, 'Ravi');
    });

    testWidgets('no sponsors: only the "Technology Powered by" line; no link without a URL', (tester) async {
      await _pumpFooter(tester, const AppBranding(poweredBy: 'IQ Explore'));

      expect(find.byKey(const Key('footerSponsor')), findsNothing);
      expect(find.byKey(const Key('footerPoweredBy')), findsOneWidget);
      expect(find.byKey(const Key('footerPoweredByLink')), findsNothing);
    });

    testWidgets('nothing set: no footer', (tester) async {
      await _pumpFooter(tester, const AppBranding());
      expect(find.byKey(const Key('footerSponsor')), findsNothing);
      expect(find.byKey(const Key('footerPoweredBy')), findsNothing);
    });
  });

  group('MarqueeText', () {
    Widget box(Widget child, {bool reduceMotion = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(body: SizedBox(width: 200, child: child)),
      ),
    );
    const long = 'Sri Laxmi Silks, Managing Director, Laxmi Textiles Private Limited';

    testWidgets('text that does not fit scrolls in a loop', (tester) async {
      await tester.pumpWidget(box(const MarqueeText(long)));
      await tester.pump(); // starts after the first frame
      final start = _scrollOffset(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(_scrollOffset(tester), lessThan(start));
      expect(find.text(long), findsNWidgets(2)); // the start follows the end
      await tester.pumpWidget(const SizedBox()); // stop the endless animation
    });

    testWidgets('text that fits stands still', (tester) async {
      await tester.pumpWidget(box(const MarqueeText('Asha')));
      await tester.pumpAndSettle();
      expect(find.descendant(of: find.byType(MarqueeText), matching: find.byType(Transform)), findsNothing);
      expect(find.text('Asha'), findsOneWidget);
    });

    testWidgets('reduced motion: stands still and is shortened', (tester) async {
      await tester.pumpWidget(box(const MarqueeText(long), reduceMotion: true));
      await tester.pumpAndSettle();
      expect(find.descendant(of: find.byType(MarqueeText), matching: find.byType(Transform)), findsNothing);
      expect(tester.widget<Text>(find.text(long)).overflow, TextOverflow.ellipsis);
    });
  });
}
