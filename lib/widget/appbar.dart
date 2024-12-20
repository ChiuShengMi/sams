import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(''),
      backgroundColor: Color(0xFF7B1FA2), // AppBarの背景色
      elevation: MediaQuery.of(context).size.height * 0.2, // 画面の20%
      leading: IconButton(
        icon: Image.asset(
          'assets/icon/HelloECC_icon_big.png', // assetのアイコンを表示
          width: 80, // アイコンの幅（調整したサイズ）
          height: 80, // アイコンの高さ（調整したサイズ）
          fit: BoxFit.cover, // 画像をカバーするように描画
        ),
        onPressed: () {
          // アイコンが押されたときの処理あるなら
        },
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
