import 'package:flutter/material.dart';

class Actionbar extends StatelessWidget {
  Actionbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(30),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0.1),
            borderRadius: BorderRadius.circular(10)),
        height: 100,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, children: []));
  }
}
