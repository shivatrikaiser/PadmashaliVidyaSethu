import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Entry for the 4-digit Phone Number Verification Code: four boxes backed by one text field,
/// so typing, deleting, pasting and SMS autofill all behave naturally.
class CodeInput extends StatefulWidget {
  const CodeInput({
    super.key,
    required this.controller,
    required this.semanticLabel,
    this.length = 4,
    this.onCompleted,
    this.hasError = false,
  });

  final TextEditingController controller;
  final String semanticLabel;
  final int length;
  final ValueChanged<String>? onCompleted;
  final bool hasError;

  @override
  State<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  final _focus = FocusNode();
  String _lastCompleted = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_textChanged);
    _focus.addListener(_focusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_textChanged);
    _focus.dispose();
    super.dispose();
  }

  void _focusChanged() => setState(() {});

  void _textChanged() {
    setState(() {});
    final text = widget.controller.text;
    // Fire once per complete entry, not on every selection/focus change.
    if (text.length == widget.length && text != _lastCompleted) {
      _lastCompleted = text;
      widget.onCompleted?.call(text);
    } else if (text.length < widget.length) {
      _lastCompleted = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = widget.controller.text;

    return Semantics(
      label: widget.semanticLabel,
      textField: true,
      child: GestureDetector(
        onTap: _focus.requestFocus,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.length; i++)
                  Container(
                    width: 56,
                    height: 64,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        width: 2,
                        color: widget.hasError
                            ? scheme.error
                            : (_focus.hasFocus && i == text.length.clamp(0, widget.length - 1))
                            ? scheme.primary
                            : scheme.outlineVariant,
                      ),
                    ),
                    child: Text(
                      i < text.length ? text[i] : '',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            // The real input: invisible, but focusable and accessible.
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  key: const Key('codeInputField'),
                  controller: widget.controller,
                  focusNode: _focus,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                  showCursor: false,
                  enableInteractiveSelection: false,
                  decoration: const InputDecoration(border: InputBorder.none, filled: false, counterText: ''),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
