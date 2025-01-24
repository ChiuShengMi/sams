import 'package:flutter/material.dart';
import 'button_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width; // ボタン幅をカスタマイズ
  final double? height; // ボタン高さをカスタマイズ
  final double? fontSize; // テキストサイズをカスタマイズ

  const CustomButton({
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 150, // デフォルト値を設定
      height: height ?? 50, // デフォルト値を設定
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize ?? 16, // デフォルトのフォントサイズ
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
