import 'package:flutter/material.dart';
import 'custom_button.dart';

class LargeButton extends CustomButton {
  LargeButton({required String text, required VoidCallback onPressed})
      : super(
          text: text,
          onPressed: onPressed,
          width: 250.0,
          height: 60,
        );
}
