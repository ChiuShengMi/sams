import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth パッケージをインポート
import 'package:sams/pages/loginPages/login.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/bottombar.dart';

class HomePage extends StatelessWidget {
  // ログアウトメソッド
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .signOut(); // FirebaseAuth の signOut メソッドを使ってログアウト
      // ログアウト後、ログインページに戻る
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('ログアウトエラー: $e'); // エラーハンドリング
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(), // カスタムAppBarを適用
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 中央揃え
          children: [
            Text('Welcome to Home Page!'),
            SizedBox(height: 20), // テキストとボタンの間にスペースを追加
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => _signOut(context), // ログアウトメソッドを呼び出す
              tooltip: 'Logout', // ツールチップを追加
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(), // カスタムBottomBarを適用
    );
  }
}
