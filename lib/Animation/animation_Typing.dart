import 'package:flutter/material.dart';

class TypingTextAnimation extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final Duration duration;

  TypingTextAnimation({
    required this.text,
    required this.textStyle,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  _TypingTextAnimationState createState() => _TypingTextAnimationState();
}

class _TypingTextAnimationState extends State<TypingTextAnimation>
    with SingleTickerProviderStateMixin {
  late String displayedText;
  int charIndex = 0;

  @override
  void initState() {
    super.initState();
    displayedText = '';
    _startTyping();
  }

  void _startTyping() {
    Future.doWhile(() async {
      await Future.delayed(widget.duration);
      if (charIndex < widget.text.length) {
        setState(() {
          displayedText += widget.text[charIndex];
          charIndex++;
        });
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      displayedText,
      style: widget.textStyle,
    );
  }
}
