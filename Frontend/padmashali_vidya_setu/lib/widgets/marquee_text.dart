import 'package:flutter/material.dart';

/// One line of text that scrolls sideways, in a loop, when it is wider than the space it has; otherwise it stands
/// still. Stays still too when the device asks for reduced motion (the text is then shortened with "...").
class MarqueeText extends StatefulWidget {
  const MarqueeText(this.text, {super.key, this.style, this.speed = 30, this.gap = 48});

  final String text;
  final TextStyle? style;

  /// Logical pixels per second.
  final double speed;

  /// Space between the end of the text and its next repetition.
  final double gap;

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double? _distance;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Starts (or stops) the loop for [distance] = text width + gap, or null when the text fits.
  void _run(double? distance) {
    if (distance == _distance) return;
    _distance = distance;
    if (distance == null) {
      _controller.stop();
      _controller.value = 0;
      return;
    }
    _controller
      ..duration = Duration(milliseconds: (distance / widget.speed * 1000).round())
      ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.merge(widget.style);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: 1,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        final textWidth = painter.width;
        final height = painter.height;
        painter.dispose();

        final scrolls = !reduceMotion && textWidth > constraints.maxWidth;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _run(scrolls ? textWidth + widget.gap : null);
        });

        if (!scrolls) {
          return Text(widget.text, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
        }
        return SizedBox(
          height: height,
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) =>
                  Transform.translate(offset: Offset(-_controller.value * (textWidth + widget.gap), 0), child: child),
              // Two copies, so the start comes in from the right as the end leaves on the left.
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                maxWidth: double.infinity,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.text, style: style, maxLines: 1, softWrap: false),
                    SizedBox(width: widget.gap),
                    Text(widget.text, style: style, maxLines: 1, softWrap: false),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
