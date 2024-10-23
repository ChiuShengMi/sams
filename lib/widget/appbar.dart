import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Custom App Bar'),
      backgroundColor: Color(0xFF7B1FA2), // AppBarの背景色
      elevation: MediaQuery.of(context).size.height * 0.2, // 画面の20%
      leading: IconButton(
        icon: Image.asset(
          'assets/icon/HelloECC_icon.png', // assetのアイコンを表示
          width: 24, // アイコンの幅
          height: 24, // アイコンの高さ
        ),
        onPressed: () {
          // アイコンが押されたときの処理あるならr
        },
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
