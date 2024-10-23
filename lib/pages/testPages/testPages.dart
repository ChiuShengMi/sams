import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  // FirebaseAuth パッケージをインポート
import 'package:sams/pages/loginPages/login.dart';

class TestPage extends StatelessWidget {

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // ユーザ追加機能の処理を書く
                print("ユーザ追加ボタンが押されました");
              },
              child: Text('ユーザ追加'),
            ),
            SizedBox(height: 20),  // ボタン間のスペース
            ElevatedButton(
              onPressed: () {
                // 権限管理機能の処理を書く
                print("権限管理ボタンが押されました");
              },
              child: Text('権限管理'),
            ),
            SizedBox(height: 20),  // ボタン間のスペース
            ElevatedButton(
              onPressed: () {
                // DATABASE構築機能の処理を書く
                print("DATABASE構築ボタンが押されました");
              },
              child: Text('DATABASE構築'),
            ),
          ],
        ),
      ),
    );
  }
}
