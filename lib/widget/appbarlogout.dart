import 'package:flutter/material.dart';
import 'package:sams/pages/loginPages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      leading: Center(
        child: Container(
          height: appBarHeight * 0.9,
          width: appBarHeight * 0.9,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(appBarHeight * 0.25),
              onTap: () {},
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
      actions: [
        IconButton(
          icon: Icon(Icons.logout, size: appBarHeight * 0.5),
          tooltip: 'Logout',
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => LoginPage()),
            // );
            try {
              // FirebaseAuth の signOut メソッドを使ってログアウト
              // ログアウト後、ログインページに戻る
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            } catch (e) {
              print('ログアウトエラー: $e'); // エラーハンドリング
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
