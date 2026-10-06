import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padmashali_vidya_setu/app.dart';
import 'package:padmashali_vidya_setu/screens/auth/phone_screen.dart';
import 'package:padmashali_vidya_setu/widgets/code_input.dart';

import '../helpers.dart';

void main() {
  testWidgets('signed-out start: splash → welcome → phone number', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(overrides: testOverrides(), child: const PvsApp()));
    await tester.pumpAndSettle();

    expect(find.text('Padmashali Vidya Setu'), findsWidgets);
    expect(find.byKey(const Key('getStartedButton')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('getStartedButton')));
    await tester.tap(find.byKey(const Key('getStartedButton')));
    await tester.pumpAndSettle();

    expect(find.text('Phone Number'), findsWidgets);
    expect(find.text('Send Verification Code'), findsOneWidget);
    expect(find.textContaining('OTP'), findsNothing);
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
