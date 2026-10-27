import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padmashali_vidya_setu/widgets/portrait_frame.dart';

void main() {
  group('PortraitFrame.frameFor', () {
    test('wide windows get a full-height 9:16 frame', () {
      expect(PortraitFrame.frameFor(const Size(1920, 1080)), const Size(607.5, 1080));
      expect(PortraitFrame.frameFor(const Size(1280, 560)), const Size(315, 560));
    });

    test('windows narrower than 9:16 (phones) are unchanged', () {
      expect(PortraitFrame.frameFor(const Size(392, 872)), const Size(392, 872));
      expect(PortraitFrame.frameFor(const Size(450, 800)), const Size(450, 800));
    });
  });

  testWidgets('in a wide window the screen is laid out in a centred, full-height frame', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Size? seen;
    await tester.pumpWidget(
      MaterialApp(
        home: PortraitFrame(
          enabled: true,
          child: Builder(
            builder: (context) {
              seen = MediaQuery.sizeOf(context);
              return const Scaffold(body: SizedBox.expand(key: Key('screen')));
            },
          ),
        ),
      ),
    );

    expect(seen, const Size(607.5, 1080));
    final rect = tester.getRect(find.byKey(const Key('screen')));
    expect(rect.height, 1080);
    expect(rect.center.dx, closeTo(960, 0.01));
  });

  testWidgets('when disabled (Android / iOS) nothing changes', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Size? seen;
    await tester.pumpWidget(
      MaterialApp(
        home: PortraitFrame(
          enabled: false,
          child: Builder(
            builder: (context) {
              seen = MediaQuery.sizeOf(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(seen, const Size(1920, 1080));
  });
}
