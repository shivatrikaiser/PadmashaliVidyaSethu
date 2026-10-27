import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Enlarges the whole interface on tablets, so the phone-sized screens fill the display - full height, with the width
/// growing in proportion - instead of a phone-sized column surrounded by empty space.
///
/// The app is laid out on a smaller logical canvas (the real size divided by [scaleFor]) and drawn scaled up, so text,
/// fields, buttons and spacing all grow together and stay readable. Phones (shortest side under 600) are left exactly
/// as they are; large browser windows (the web version, pvs.vidyasethu.co.in) are enlarged a little less ([maxWebScale]).
class TabletScale extends StatelessWidget {
  const TabletScale({super.key, required this.child});

  final Widget child;

  /// Shortest side, in logical pixels, from which a device counts as a tablet.
  static const tabletShortestSide = 600.0;

  /// Width of the phone layout the screens are designed for; a tablet is scaled so its shortest side matches it.
  static const designShortestSide = 430.0;

  static const maxScale = 1.8;

  /// Large browser windows: enough to read comfortably without the page looking oversized on a desktop monitor.
  static const maxWebScale = 1.5;

  /// 1.0 on phones and small windows; between ~1.4 (7" tablet) and [maxScale] (10" and larger) on tablets; at most
  /// [maxWebScale] in a browser.
  static double scaleFor(Size size, {bool isWeb = kIsWeb}) {
    final shortest = size.shortestSide;
    if (shortest < tabletShortestSide) return 1;
    return math.min(shortest / designShortestSide, isWeb ? maxWebScale : maxScale);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final scale = scaleFor(media.size);
    if (scale == 1) return child;

    EdgeInsets shrink(EdgeInsets e) => e / scale;
    final logical = media.size / scale;
    return FittedBox(
      fit: BoxFit.fill,
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: logical.width,
        height: logical.height,
        child: MediaQuery(
          // Everything inside sees the smaller canvas: system bars and the keyboard shrink in step.
          data: media.copyWith(
            size: logical,
            padding: shrink(media.padding),
            viewPadding: shrink(media.viewPadding),
            viewInsets: shrink(media.viewInsets),
            systemGestureInsets: shrink(media.systemGestureInsets),
            devicePixelRatio: media.devicePixelRatio * scale,
          ),
          child: child,
        ),
      ),
    );
  }
}
