import 'package:flutter/material.dart';

class ButtonStyles {
  static final ButtonStyle baseStyle = ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF7B1FA2),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    elevation: 2.0,
    textStyle: TextStyle(
      fontSize: 15.0,
      fontWeight: FontWeight.bold,
    ),
  );
}
