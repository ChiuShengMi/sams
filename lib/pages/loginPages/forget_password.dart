import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgetPasswordPage extends StatefulWidget {
  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      Fluttertoast.showToast(msg: "パスワードリセットのメールを送信しました");
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? "リセットに失敗しました");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Color(0xFF7B1FA2),
        title: Text(
          'パスワードリセット',
          style: TextStyle(fontFamily: 'FjallaOne'),
        ),
      ),
      body: Container(
        color: Color(0xFF7B1FA2),
        child: Center(
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
                  Text(
                    'メールアドレスを入力してください',
                    style: TextStyle(
                      fontFamily: 'FjallaOne',
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 16 : 20,
                      color: Color(0xFF7B1FA2),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.email, color: Colors.grey),
                      label: Text(
                        'メール',
                        style: TextStyle(
                          fontFamily: 'FjallaOne',
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 16 : 20,
                          color: Color(0xFF7B1FA2),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  GestureDetector(
                    onTap: resetPassword,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: 55,
                      width: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [Color(0xFF7B1FA2), Color(0xFF8E44AD)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'リセットメールを送信',
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
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      '戻る',
                      style: TextStyle(
                        fontFamily: 'FjallaOne',
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 16 : 18,
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
