import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  // FirebaseAuth パッケージをインポート
import 'package:sams/pages/loginPages/login.dart';  
import 'package:sams/pages/testPages/testPages.dart';
class HomePageTeacher extends StatelessWidget {

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
        child: _buildBoxedButton(
          context: context,
          label: 'Test Page',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TestPage()),
            );
          },
        ),
      ),
    );
  }
}



  Widget _buildBoxedButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 60, // Fixed height for consistent button size
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