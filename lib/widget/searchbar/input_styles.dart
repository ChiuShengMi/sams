import 'package:flutter/material.dart';

class InputStyles {
  static final InputDecoration searchBarStyle = InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      filled: true,
      fillColor: Colors.white,
      hintText: 'Search',
      hintStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(color: Colors.grey, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
              color: Color(
                0xFF7B1FA2,
              ),
              width: 3.0)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.grey, width: 1.5)));
}
