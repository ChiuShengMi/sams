import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth パッケージをインポート
import 'package:sams/pages/loginPages/login.dart';
import 'package:sams/widget/appbarlogout.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/pages/testPages/testPages.dart';

class HomePageAdmin extends StatelessWidget {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the content
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 中央揃え
          children: [
            SizedBox(height: 20),

            // First Row:
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // Evenly space the buttons
              children: [
                // First Button
                _buildBoxedButton(
                  context: context,
                  label: '出席総計管理',
                  onPressed: () {
                    //押されたとき処理
                  },
                ),

                // Second Button
                _buildBoxedButton(
                  context: context,
                  label: '全体出席データ管理',
                  onPressed: () {
                    //押されたとき処理
                  },
                ),
              ],
            ),

            SizedBox(height: 20),

            // Second Row: Third and Fourth Buttons
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // Evenly space the buttons
              children: [
                // Third Button
                _buildBoxedButton(
                  context: context,
                  label: '授業リスト',
                  onPressed: () {
                    //押されたとき処理
                  },
                ),

                // Fourth Button
                _buildBoxedButton(
                  context: context,
                  label: 'ユーザ管理',
                  onPressed: () {
                    //押されたとき処理
                  },
                ),
              ],
            ),

            SizedBox(height: 20),

            // Third Row: Test button
            _buildBoxedButton(
              context: context,
              label: 'Test Page',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TestPage()),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(), // カスタムBottomBarを適用
    );
  }

  // Helper method to create boxed buttons without icons
  Widget _buildBoxedButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: EdgeInsets.all(90), // Padding inside the box
      decoration: BoxDecoration(
        color: Color(0xFF7B1FA2), // Box color
        borderRadius: BorderRadius.circular(10), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow effect
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3), // Shadow position
          ),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white, // Text color
            fontSize: 16, // Text size
            fontWeight: FontWeight.bold, // Bold text
          ),
        ),
      ),
    );
  }
}
