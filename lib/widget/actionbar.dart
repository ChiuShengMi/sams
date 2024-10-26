import 'package:flutter/material.dart';
import 'button/button_styles.dart';
import 'button/custom_button.dart';
import 'button/large_button.dart';
import 'button/small_button.dart';

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
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
              child: LargeButton(text: 'Large Button', onPressed: () {})),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: CustomButton(text: 'Custom Button', onPressed: () {}),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
            child: SmallButton(text: 'Small Button', onPressed: () {}),
          ),
        ]));
  }
}
