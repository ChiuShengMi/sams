import 'package:flutter/material.dart';

class ModalStyles {
  static final TextStyle modalTitleStyle = TextStyle(
      fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF7B1FA2));

  static final TextStyle modalContentStyle = TextStyle(
      fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xFF7B1FA2));

  static final ButtonStyle modalButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF7B1FA2),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12));
}
