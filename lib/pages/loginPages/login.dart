import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sams/pages/loginPages/forget_password.dart';
import 'package:sams/pages/mainPages/homepage_admin.dart';
import 'package:sams/pages/mainPages/homepage_student.dart';
import 'package:sams/pages/mainPages/homepage_teacher.dart';
import 'package:sams/utils/firebase_auth.dart';
import 'package:sams/Animation/animation_Typing.dart';
import 'dart:math';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  final List<String> greetings = [
    'おはようございます!!',
    'ようこそ、ECCコンピュータ専門学校へ!',
    '今日も一日、よろしくお願いします！',
    'どうか、体お大事に!',
    '今日は何する予定でしょうか？',
    'こんにちは！',
    '無理したらあかんで!',
  ];

  late String currentGreeting;

  @override
  void initState() {
    super.initState();
    _setRandomGreeting(); // 페이지 로드 시 인사말 초기화
  }

  void _setRandomGreeting() {
    final random = Random();
    currentGreeting = greetings[random.nextInt(greetings.length)];
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FiresbaseAuth _firebaseAuthService = FiresbaseAuth();

  Future<void> signInWithEmailPassword() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String role = await _firebaseAuthService.getUserRole();
      print("取得した役割: $role");

      if (role == "管理者") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePageAdmin()),
        );
      } else if (role == "学生") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePageStudent()),
        );
      } else if (role == "教員") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePageTeacher()),
        );
      } else {
        Fluttertoast.showToast(msg: "役割が見つかりませんでした");

        Future.delayed(Duration(seconds: 5), () async {
          await FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        });
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? "ログインに失敗しました");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 94, 7, 131),
        toolbarHeight: 20,
      ),
      body: isMobile
          ? SingleChildScrollView(
              child: _buildMobileLayout(context),
            )
          : Row(
              children: [
                Expanded(
                  child: Container(
                    color: Color(0xFF7B1FA2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TypingTextAnimation(
                          text: 'Hello ECC !!',
                          textStyle: TextStyle(
                            fontSize: isMobile ? 70 : 100, // 모바일에서만 크기 증가
                            fontFamily: 'CarterOne',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        TypingTextAnimation(
                          text: currentGreeting,
                          textStyle: TextStyle(
                            fontSize: isMobile ? 15 : 30,
                            fontFamily: 'CarterOne',
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildLoginForm(context),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Color(0xFF7B1FA2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TypingTextAnimation(
              text: 'Hello ECC!!',
              textStyle: TextStyle(
                fontSize: 60, // 모바일에서 폰트 크기 조정
                fontFamily: 'CarterOne',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )),
          SizedBox(height: 20),
          TypingTextAnimation(
            text: currentGreeting,
            textStyle: TextStyle(
              fontSize: 20, // 모바일에서 작은 크기 조정
              fontFamily: 'FjallaOne',
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 40),
          _buildLoginForm(context),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return SingleChildScrollView(
      // 화면을 스크롤 가능하게 만들어줍니다.
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 이메일 입력란
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.check, color: Colors.grey),
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
              SizedBox(height: 20),

              // 비밀번호 입력란
              TextField(
                controller: passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    color: Colors.grey,
                    onPressed: () {
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
                      fontSize: isMobile ? 16 : 20,
                      color: Color(0xFF7B1FA2),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 80),

              // 비밀번호 찾기 링크
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ForgetPasswordPage()),
                  );
                },
                child: SizedBox(
                  height: 40, // 기존 텍스트가 있던 자리에 같은 크기의 빈 공간을 추가
                ),
              ),
              SizedBox(height: 25),

              // 로그인 버튼
              GestureDetector(
                onTap: signInWithEmailPassword,
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    bool isHovering = false;

                    return MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          isHovering = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          isHovering = false;
                        });
                      },
                      cursor: SystemMouseCursors.click, // 커서 변경
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: 55,
                        width: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: isHovering
                                ? [
                                    Color(0xFF9B59B6),
                                    Color(0xFF8E44AD)
                                  ] // 호버 시 색상
                                : [
                                    Color(0xFF7B1FA2),
                                    Color(0xFF8E44AD)
                                  ], // 기본 색상
                          ),
                          boxShadow: isHovering
                              ? [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  )
                                ]
                              : [],
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
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
