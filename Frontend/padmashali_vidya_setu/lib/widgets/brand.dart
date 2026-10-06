import 'package:flutter/material.dart';

/// Simple text-free brand mark (a bridge arc over a book) until an official logo is supplied.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72});
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [scheme.primary, scheme.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(Icons.auto_stories_rounded, color: scheme.onPrimary, size: size * 0.5),
      ),
    );
  }
}
