import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../utils/l10n.dart';

/// Colours taken from the splash artwork and logo.
abstract final class SplashColors {
  static const cream = Color(0xFFF6EDE2);
  static const navy = Color(0xFF0B2D6B);
  static const blue = Color(0xFF1C4F9C);
  static const gold = Color(0xFFD49A2E);
  static const goldLight = Color(0xFFF3CF7E);
  static const cardTop = Color(0xFFFFFAEF);
  static const cardBottom = Color(0xFFFBEED2);
}

/// The artwork ends inside the students' scene: this fades its bottom edge into [SplashColors.cream].
class SplashArtworkFade extends StatelessWidget {
  const SplashArtworkFade({super.key});

  @override
  Widget build(BuildContext context) => const Align(
    alignment: Alignment.bottomCenter,
    child: SizedBox(
      height: 56,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00F6EDE2), SplashColors.cream],
          ),
        ),
      ),
    ),
  );
}

/// Sponsor card + "Powered by" over the blue and gold waves of the artwork. Both come from the admin portal
/// ([appBrandingProvider]) and appear once loaded; nothing waits for them.
class SplashFooter extends ConsumerWidget {
  const SplashFooter({super.key, this.respectBottomInset = true});

  /// Keep clear of the system navigation bar (true when the footer is at the bottom of the screen).
  final bool respectBottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final b = ref.watch(appBrandingProvider).valueOrNull;
    final logoUrl = b == null ? null : sponsorLogoUrl(ref.watch(appConfigProvider), b);
    final poweredBy = b?.poweredBy;
    final band = _WavesPainter.bandHeight(MediaQuery.sizeOf(context).width);

    return CustomPaint(
      painter: const _WavesPainter(),
      child: SafeArea(
        top: false,
        bottom: respectBottomInset,
        child: Padding(
          padding: EdgeInsets.fromLTRB(28, 4, 28, band + 6),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (b != null && b.hasSponsor)
                  _SponsorCard(name: b.sponsorName, logoUrl: logoUrl, label: l10n.sponsoredBy),
                if (poweredBy != null) ...[
                  const SizedBox(height: 14),
                  Text.rich(
                    TextSpan(
                      text: '${l10n.poweredBy} : ',
                      children: [
                        TextSpan(
                          text: poweredBy,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: SplashColors.navy, fontSize: 15),
                  ),
                ],
                if (b == null) const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SponsorCard extends StatelessWidget {
  const _SponsorCard({required this.name, required this.logoUrl, required this.label});
  final String? name;
  final String? logoUrl;
  final String label;

  @override
  Widget build(BuildContext context) {
    final sponsor = name;
    final logo = logoUrl;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: SplashColors.goldLight, width: 1.5),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [SplashColors.cardTop, SplashColors.cardBottom],
          ),
          boxShadow: const [BoxShadow(color: Color(0x22B07A1A), blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium, color: SplashColors.gold, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: SplashColors.navy, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  if (logo != null) ...[
                    const SizedBox(height: 6),
                    Image.network(
                      logo,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ],
                  if (sponsor != null && sponsor.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      sponsor,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: SplashColors.navy, fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.workspace_premium, color: SplashColors.gold, size: 28),
          ],
        ),
      ),
    );
  }
}

/// The artwork's bottom decoration: navy waves from both corners with gold ribbons, under the footer text.
class _WavesPainter extends CustomPainter {
  const _WavesPainter();

  /// Height of the wave band at the bottom; footer text is laid out above it.
  static double bandHeight(double width) => (width * 0.15).clamp(48.0, 90.0);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final band = bandHeight(w);
    final top = h - band;

    // Left: gold ribbon, then navy wave, rising from the bottom centre to the left edge.
    canvas.drawPath(
      Path()
        ..moveTo(0, top - band * 0.45)
        ..cubicTo(w * 0.18, top - band * 0.1, w * 0.32, h - band * 0.25, w * 0.52, h)
        ..lineTo(0, h)
        ..close(),
      Paint()
        ..shader = const LinearGradient(
          colors: [SplashColors.gold, SplashColors.goldLight],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, top - band * 0.15)
        ..cubicTo(w * 0.16, top + band * 0.15, w * 0.28, h - band * 0.12, w * 0.46, h)
        ..lineTo(0, h)
        ..close(),
      Paint()
        ..shader = const LinearGradient(
          colors: [SplashColors.navy, SplashColors.blue],
        ).createShader(Offset.zero & size),
    );

    // Right: gold ribbon, then navy wave, rising from the bottom centre to the right edge.
    canvas.drawPath(
      Path()
        ..moveTo(w, top - band * 0.3)
        ..cubicTo(w * 0.84, top + band * 0.05, w * 0.7, h - band * 0.3, w * 0.48, h)
        ..lineTo(w, h)
        ..close(),
      Paint()
        ..shader = const LinearGradient(
          colors: [SplashColors.goldLight, SplashColors.gold],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      Path()
        ..moveTo(w, top + band * 0.05)
        ..cubicTo(w * 0.86, top + band * 0.3, w * 0.74, h - band * 0.15, w * 0.55, h)
        ..lineTo(w, h)
        ..close(),
      Paint()
        ..shader = const LinearGradient(
          colors: [SplashColors.blue, SplashColors.navy],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
