import 'package:flutter/material.dart';
import './input_styles.dart';

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final double height;
  final double borderRadius;
  final Color fillColor;
  final Color borderColor;

  CustomInput(
      {required this.controller,
      required this.hintText,
      this.height = 50.0,
      this.borderRadius = 30.0,
      this.fillColor = Colors.white,
      this.borderColor = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        decoration: InputStyles.InputStyle.copyWith(
            hintText: hintText,
            fillColor: fillColor,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: borderColor, width: 1.5)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: borderColor, width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: Color(0xFF7B1FA2)))),
      ),
    );
  }
}

class SmallInput extends CustomInput {
  SmallInput(
      {required String hintText, required TextEditingController controller})
      : super(
            hintText: hintText,
            controller: controller,
            height: 40.0,
            borderRadius: 20.0);
}

class MediumInput extends CustomInput {
  MediumInput(
      {required String hintText, required TextEditingController controller})
      : super(
            hintText: hintText,
            controller: controller,
            height: 50.0,
            borderRadius: 25.0);
}

class LargeInput extends CustomInput {
  LargeInput(
      {required String hintText, required TextEditingController controller})
      : super(
            hintText: hintText,
            controller: controller,
            height: 60.0,
            borderRadius: 30.0);
}





//final TextEditingController InputController = TextEditingController();
// bulidの上にコントローラを宣言


// Actionbar(children: [
//                 Expanded(
//                     child: Row(
//                   children: [
//                     Flexible(     //Flexibleに囲んで使用。
//                         child: CustomInput(
//                             controller: InputController,
//                             hintText: ''))
//                   ],
//                 ))
//               ])