import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  // FirebaseAuth パッケージをインポート
import 'package:sams/pages/loginPages/login.dart';  

class HomePage extends StatelessWidget {
  // ログアウトメソッド
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();  // FirebaseAuth の signOut メソッドを使ってログアウト
      // ログアウト後、ログインページに戻る
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('ログアウトエラー: $e');  // エラーハンドリング
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          // ログアウトボタン
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(context),  // ログアウトメソッドを呼び出す
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome to Home Page!'),
      ),
    );
  }
}
