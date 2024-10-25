import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    final double appBarHeight = 130.0;

    return AppBar(
      title: Text(''),
      backgroundColor: Color(0xFF7B1FA2),
      elevation: MediaQuery.of(context).size.height * 0.2,
      toolbarHeight: appBarHeight,
      leadingWidth: appBarHeight,

      // アプリアイコン（左側）
      leading: Center(
        child: Container(
          height: appBarHeight * 0.9,
          width: appBarHeight * 0.9,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(appBarHeight * 0.25),
              onTap: () {
                // アイコンが押されたときの処理
              },
              child: Padding(
                padding: EdgeInsets.all(appBarHeight * 0.1),
                child: Image.asset(
                  'assets/icon/HelloECC_icon_big.png',
                  height: 150,
                  width: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),

      // ログアウトアイコン（右側）
      actions: [
        Container(
          height: appBarHeight,
          width: appBarHeight * 0.8,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(appBarHeight * 0.25),
              onTap: () => _signOut(context),
              child: Tooltip(
                message: 'Logout',
                child: Icon(
                  Icons.logout,
                  size: appBarHeight * 0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  void _signOut(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Logged out!'),
    ));
  }
}
