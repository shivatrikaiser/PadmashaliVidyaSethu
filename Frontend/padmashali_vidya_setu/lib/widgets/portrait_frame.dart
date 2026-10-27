import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Web version (pvs.vidyasethu.co.in): wide browser windows show the app as a portrait screen that fills the full height, centred,
/// instead of stretching every screen across the full width (which also crops the portrait splash artwork).
///
/// The width follows the height at [aspectRatio]; windows already narrower than that (phones) are unchanged, and so
/// are the Android and iOS apps.
class PortraitFrame extends StatelessWidget {
  const PortraitFrame({super.key, required this.child, this.enabled = kIsWeb});

  final Widget child;
  final bool enabled;

  /// Width / height of the frame: a 9:16 phone screen.
  static const aspectRatio = 9 / 16;

  /// Shown at the sides of the frame.
  static const background = Color(0xFFE9EEF5);

  /// The frame for a window of [size]: full height, width from [aspectRatio], never wider than the window.
  static Size frameFor(Size size) {
    final width = size.height * aspectRatio;
    return width >= size.width ? size : Size(width, size.height);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final frame = frameFor(media.size);
    if (!enabled || frame == media.size) return child;

    return ColoredBox(
      color: background,
      child: Center(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 24)],
          ),
          child: SizedBox.fromSize(
            size: frame,
            // Screens inside see the frame as the whole screen (layouts, dialogs and TabletScale).
            child: MediaQuery(data: media.copyWith(size: frame), child: child),
          ),
        ),
      ),
    );
  }
}
