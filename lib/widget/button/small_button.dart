import 'package:flutter/material.dart';
import 'custom_button.dart';

class SmallButton extends CustomButton {
  SmallButton({required String text, required VoidCallback onPressed})
      : super(text: text, onPressed: onPressed, width: 120.0, height: 40.0);
}
