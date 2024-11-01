import 'package:flutter/material.dart';

class TableStyles {
  static const TextStyle headerTextStyle =
      TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16);

  static const TextStyle cellTextStyle =
      TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14);

  static const Color headerBackgroundColor = Color(0xFF7B1FA2);
  static const Color cellBackgroundColor = Colors.white;

  static BoxDecoration headerDecoration = BoxDecoration(
    color: headerBackgroundColor,
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
  );

  static BoxDecoration cellDecoration = BoxDecoration(
      color: cellBackgroundColor,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      border: Border.all(color: Colors.black, width: 0.1));
}
