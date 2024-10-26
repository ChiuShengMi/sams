import 'package:flutter/material.dart';
import 'button_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;

  CustomButton(
      {required this.text,
      required this.onPressed,
      this.width = 150.0,
      this.height = 50.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ButtonStyles.baseStyle,
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
