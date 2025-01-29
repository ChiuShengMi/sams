import 'package:flutter/material.dart';
import 'button_styles.dart';
import 'custom_buttonMob.dart';

enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonSize size;

  CustomButton(
      {required this.text,
      required this.onPressed,
      this.size = ButtonSize.medium});

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    double fontSize;

    switch (size) {
      case ButtonSize.small:
        width = 90.0;
        height = 40.0;
        fontSize = 12.0;
        break;
      case ButtonSize.large:
        width = 250.0;
        height = 60.0;
        fontSize = 25.0;
        break;
      case ButtonSize.medium:
      default:
        width = 150.0;
        height = 50.0;
        fontSize = 18.0;
        break;
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ButtonStyles.baseStyle.copyWith(
          textStyle: MaterialStateProperty.all(TextStyle(fontSize: fontSize)),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}

class SmallButton extends CustomButton {
  SmallButton({required String text, required VoidCallback onPressed})
      : super(text: text, onPressed: onPressed, size: ButtonSize.small);
}

class MediumButton extends CustomButton {
  MediumButton({required String text, required VoidCallback onPressed})
      : super(text: text, onPressed: onPressed, size: ButtonSize.medium);
}

class LargeButton extends CustomButton {
  LargeButton({required String text, required VoidCallback onPressed})
      : super(text: text, onPressed: onPressed, size: ButtonSize.large);
}
