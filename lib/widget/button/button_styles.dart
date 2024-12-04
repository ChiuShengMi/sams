import 'package:flutter/material.dart';

class ButtonStyles {
  static final ButtonStyle baseStyle = ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF7B1FA2),
      foregroundColor: Colors.white,
      textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)));
}
