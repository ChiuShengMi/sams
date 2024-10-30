import 'package:flutter/material.dart';

class DropboxStyles {
  static final InputDecoration dropdownDecoration = InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Color(0xFFB1FA2), width: 3.0)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.grey, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.red, width: 1.5)));

  static final TextStyle dropdownItemStyle =
      TextStyle(color: Colors.black, fontSize: 16.0);

  static final BoxDecoration dropdownBoxDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30.0),
      border: Border.all(color: Colors.grey, width: 1.5));
}
