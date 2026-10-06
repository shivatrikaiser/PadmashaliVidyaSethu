import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padmashali_vidya_setu/screens/registration/registration_screen.dart';

import '../helpers.dart';

void main() {
  // Regression: the bottom button bar once expanded to the full screen height and squeezed the form.
  testWidgets('wizard form area uses most of the screen and the button bar stays compact', (tester) async {
    await pumpLocalized(tester, const SizedBox(height: 870, child: RegistrationScreen()));

    final scroll = tester.getSize(find.byType(SingleChildScrollView).last);
    final next = tester.getSize(find.byKey(const Key('nextButton')));
    expect(scroll.height, greaterThan(400));
    expect(next.height, lessThan(80));
    expect(find.text('Step 1 of 5 · Personal Details'), findsOneWidget);
  });

  testWidgets('Next is blocked until the step is valid', (tester) async {
    await pumpLocalized(tester, const SizedBox(height: 870, child: RegistrationScreen()));

    await tester.tap(find.byKey(const Key('nextButton')));
    await tester.pumpAndSettle();

    expect(find.text('Step 1 of 5 · Personal Details'), findsOneWidget);
    expect(find.text('Please correct the highlighted fields.'), findsOneWidget);
  });
}
