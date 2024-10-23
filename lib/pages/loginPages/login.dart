import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth パッケージ
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sams/pages/mainPages/homepage.dart'; // ここでパスが正しいことを確認

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false; // パスワード表示状態を管理するフラグ

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ログインメソッド
  Future<void> signInWithEmailPassword() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // ログイン成功後、ホームページに遷移
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage()), // HomePage のパスが正しいことを確認
      );
    } on FirebaseAuthException catch (e) {
      // ログインに失敗した場合、エラーメッセージを表示
      Fluttertoast.showToast(msg: e.message ?? "ログインに失敗しました");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // キーボード出現時に画面サイズを調整
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 94, 7, 131),
        toolbarHeight: 20, // AppBar の高さ
      ),
      body: SingleChildScrollView(
        // ページ全体をスクロール可能にする
        child: Container(
          height: MediaQuery.of(context).size.height, // デバイスの全高を使用
          decoration: BoxDecoration(
            color: Color(0xFF7B1FA2),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60.0, left: 22),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Hello ECC',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'CarterOne',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 80,
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 60),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: emailController, // メール入力コントローラにバインド
                          decoration: InputDecoration(
                            suffixIcon: Icon(Icons.check, color: Colors.grey),
                            label: Text(
                              'メール',
                              style: TextStyle(
                                fontFamily: 'FjallaOne',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7B1FA2),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: passwordController, // パスワード入力コントローラにバインド
                          obscureText: !_isPasswordVisible, // パスワードを表示するかどうか
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              color: Colors.grey,
                              onPressed: () {
                                // パスワードの表示/非表示を切り替える
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            label: Text(
                              'パスワード',
                              style: TextStyle(
                                fontFamily: 'FjallaOne',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7B1FA2),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 80),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'パスワードを忘れた方',
                            style: TextStyle(
                              fontFamily: 'FjallaOne',
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                        GestureDetector(
                          onTap:
                              signInWithEmailPassword, // ログインボタンをクリックした時にログインメソッドを呼び出す
                          child: Container(
                            height: 55,
                            width: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF7B1FA2),
                                  Color.fromARGB(255, 139, 7, 241),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'ログイン',
                                style: TextStyle(
                                  fontFamily: 'FjallaOne',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
