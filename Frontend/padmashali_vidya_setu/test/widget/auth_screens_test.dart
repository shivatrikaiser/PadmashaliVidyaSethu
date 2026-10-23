import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padmashali_vidya_setu/app.dart';
import 'package:padmashali_vidya_setu/screens/auth/phone_screen.dart';
import 'package:padmashali_vidya_setu/widgets/app_footer.dart';
import 'package:padmashali_vidya_setu/widgets/brand.dart';
import 'package:padmashali_vidya_setu/widgets/code_input.dart';

import '../helpers.dart';

void main() {
  testWidgets('signed-out start: splash → welcome → phone number', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(overrides: testOverrides(), child: const PvsApp()));
    await tester.pumpAndSettle();

    // Logo, then the sponsor's name, organisation and address from the admin portal, then the welcome text - all
    // on one screen, above the footer with the sponsor and "Powered by".
    expect(find.byType(BrandLogo), findsOneWidget);
    expect(find.byKey(const Key('welcomeSponsor')), findsOneWidget);
    expect(find.text('Test Textiles Pvt Ltd'), findsOneWidget);
    expect(find.text('12, Car Street\nUdupi 576101'), findsOneWidget);
    expect(find.byKey(const Key('welcomePoweredBy')), findsOneWidget);
    expect(find.byKey(const Key('footerSponsor')), findsOneWidget);
    expect(find.byKey(const Key('footerPoweredBy')), findsOneWidget);
    expect(
      tester.getBottomLeft(find.byKey(const Key('getStartedButton'))).dy,
      lessThan(tester.getTopLeft(find.byType(AppFooter)).dy),
    );
    expect(find.byKey(const Key('getStartedButton')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('getStartedButton')));
    await tester.tap(find.byKey(const Key('getStartedButton')));
    await tester.pumpAndSettle();

    expect(find.text('Phone Number'), findsWidgets);
    expect(find.text('Send Verification Code'), findsOneWidget);
    expect(find.textContaining('OTP'), findsNothing);
  });

  testWidgets('Privacy Policy and Terms open from the welcome screen without signing in', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(overrides: testOverrides(), child: const PvsApp()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('privacyPolicyLink')));
    await tester.tap(find.byKey(const Key('privacyPolicyLink')));
    await tester.pumpAndSettle();
    expect(find.text('Who we are'), findsOneWidget);
    expect(find.text('How long we keep it, and deleting your account'), findsOneWidget);
    expect(find.byKey(const Key('legalDraftNote')), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('termsLink')));
    await tester.tap(find.byKey(const Key('termsLink')));
    await tester.pumpAndSettle();
    expect(find.text('Your account'), findsOneWidget);
    expect(find.text('Acceptable use'), findsOneWidget);
  });

  testWidgets('phone number is validated before sending', (tester) async {
    await pumpLocalized(tester, const SizedBox(height: 800, child: PhoneScreen()));

    await tester.ensureVisible(find.byKey(const Key('sendCodeButton')));
    await tester.tap(find.byKey(const Key('sendCodeButton')));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your mobile number.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('mobileField')), '12345');
    await tester.tap(find.byKey(const Key('sendCodeButton')));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid 10-digit mobile number.'), findsOneWidget);
  });

  testWidgets('number outside India: country code picked, WhatsApp note shown, length checked for that country', (
    tester,
  ) async {
    await pumpLocalized(tester, const SizedBox(height: 900, child: PhoneScreen()));
    expect(find.byKey(const Key('whatsAppNote')), findsNothing);

    await tester.tap(find.byKey(const Key('countryCodePicker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+971  United Arab Emirates').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('whatsAppNote')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('mobileField')), '1234');
    await tester.ensureVisible(find.byKey(const Key('sendCodeButton')));
    await tester.tap(find.byKey(const Key('sendCodeButton')));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid mobile number for the selected country code.'), findsOneWidget);
    expect(find.byKey(const Key('emailField')), findsNothing); // sign-in needs only the phone number
  });

  testWidgets('verification code input accepts exactly 4 digits', (tester) async {
    final controller = TextEditingController();
    String? completed;
    await pumpLocalized(
      tester,
      CodeInput(controller: controller, semanticLabel: 'code', onCompleted: (c) => completed = c),
    );

    await tester.enterText(find.byKey(const Key('codeInputField')), '12a34567');
    await tester.pump();

    expect(controller.text, '1234');
    expect(completed, '1234');
    expect(find.text('1'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });
}
