import 'package:flutter/material.dart';

/// Official artwork (generated from the Sangha's logo; masters in `branding/`).
abstract final class BrandAssets {
  /// Emblem only (no text) - small marks such as app bars.
  static const emblem = 'assets/images/pvs_emblem.jpg';

  /// Full logo: emblem, "Padmashali Vidya Sethu" and "Education | Support | Databank".
  static const logo = 'assets/images/pvs_logo.jpg';

  /// Full-screen splash artwork (portrait).
  static const splash = 'assets/images/splash.jpg';
}

/// The emblem without text, square.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72});
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: _WhiteTile(
      radius: size * 0.22,
      child: Image.asset(BrandAssets.emblem, width: size, height: size, fit: BoxFit.contain),
    ),
  );
}

/// The full logo including the name and tagline, on a rounded white tile. [semanticLabel] is read by screen readers.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, required this.semanticLabel, this.height = 160});
  final String semanticLabel;
  final double height;

  @override
  Widget build(BuildContext context) => _WhiteTile(
    radius: height * 0.1,
    child: Padding(
      padding: EdgeInsets.all(height * 0.03),
      child: Image.asset(BrandAssets.logo, height: height, fit: BoxFit.contain, semanticLabel: semanticLabel),
    ),
  );
}

/// The artwork has a white background: show it on a rounded white tile so it looks intentional in dark mode
/// (and blends into the page in light mode).
class _WhiteTile extends StatelessWidget {
  const _WhiteTile({required this.child, required this.radius});
  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: ColoredBox(color: Colors.white, child: child),
  );
}
