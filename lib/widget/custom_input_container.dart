import 'package:flutter/material.dart';

class CustomInputContainer extends StatelessWidget {
  final String? title;
  final List<Widget> inputWidgets;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;

  CustomInputContainer({
    Key? key,
    this.title,
    required this.inputWidgets,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(16.0),
    this.borderRadius = 15.0,
    this.borderColor = Colors.black,
    this.borderWidth = 0.1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(borderRadius)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ...inputWidgets,
        ],
      ),
    );
  }
}
