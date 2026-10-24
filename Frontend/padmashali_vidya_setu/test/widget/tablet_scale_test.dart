import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padmashali_vidya_setu/widgets/tablet_scale.dart';

void main() {
  group('TabletScale.scaleFor', () {
    test('phones are not scaled', () {
      expect(TabletScale.scaleFor(const Size(392, 872), isWeb: false), 1);
      expect(TabletScale.scaleFor(const Size(872, 392), isWeb: false), 1); // landscape phone
    });

    test('tablets are scaled by their shortest side, at most 1.8', () {
      expect(TabletScale.scaleFor(const Size(600, 960), isWeb: false), closeTo(600 / 430, 0.001)); // 7"
      expect(TabletScale.scaleFor(const Size(800, 1280), isWeb: false), 1.8); // 10" portrait
      expect(TabletScale.scaleFor(const Size(1280, 800), isWeb: false), 1.8); // 10" landscape
    });

    test('large browser windows are enlarged a little less (at most 1.5); small ones not at all', () {
      expect(TabletScale.scaleFor(const Size(1920, 1080), isWeb: true), 1.5);
      expect(TabletScale.scaleFor(const Size(700, 640), isWeb: true), closeTo(640 / 430, 0.001));
      expect(TabletScale.scaleFor(const Size(1280, 560), isWeb: true), 1);
    });
  });

  testWidgets('on a tablet the screen is laid out on a smaller canvas and fills the display', (tester) async {
    tester.view.physicalSize = const Size(1600, 2560); // 800 x 1280 at 2x - a 10" tablet
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    Size? seen;
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: TabletScale(
          child: Builder(
            builder: (context) {
              seen = MediaQuery.sizeOf(context);
              return Scaffold(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(child: SizedBox()),
                    ElevatedButton(key: const Key('bottomButton'), onPressed: () => taps++, child: const Text('Go')),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(seen!.width, closeTo(800 / 1.8, 0.01));
    expect(seen!.height, closeTo(1280 / 1.8, 0.01));
    // Drawn scaled up: the button at the bottom of the canvas sits at the bottom of the real screen, full width.
    final rect = tester.getRect(find.byKey(const Key('bottomButton')));
    expect(rect.width, closeTo(800, 1));
    expect(rect.bottom, closeTo(1280, 2));
    // Taps land where the button is drawn.
    await tester.tap(find.byKey(const Key('bottomButton')));
    expect(taps, 1);
  });

  testWidgets('on a phone nothing changes', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    Size? seen;
    await tester.pumpWidget(
      MaterialApp(
        home: TabletScale(
          child: Builder(
            builder: (context) {
              seen = MediaQuery.sizeOf(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(seen, const Size(1080 / 2.75, 2400 / 2.75));
  });
}
