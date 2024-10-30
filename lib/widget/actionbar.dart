// Actionbar.dart
import 'package:flutter/material.dart';

class Actionbar extends StatelessWidget {
  final List<Widget> children;

  Actionbar({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: EdgeInsets.all(30),
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 0.1),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children.map((child) {
          if (child is Flexible || child is Expanded) {
            return child;
          }
          return Flexible(child: child);
        }).toList(),
      ),
    );
  }
}
