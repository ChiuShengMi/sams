import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1, // 画面の10%
      color: Color(0xFF7B1FA2),
      alignment: Alignment.center,
      child: Text(
        'Copyright © Yamaguchi Gakuen. All Rights Reserved.',
        style: TextStyle(
          fontSize: 14, //
          color: Colors.white, // テキスト色
        ),
      ),
    );
  }
}
