import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth パッケージをインポート
import 'package:sams/Animation/animation_Welcome.dart';
import 'package:sams/pages/admin/log/log.dart';
import 'package:sams/pages/loginPages/login.dart';
import 'package:sams/pages/teacher/teacher_attendance_management.dart';
import 'package:sams/pages/testPages/testPages.dart';
import 'package:sams/widget/appbarlogout.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/pages/teacher/teacher_qrcode.dart';
import 'package:sams/widget/custom_input_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePageTeacher extends StatefulWidget {
  @override
  _HomePageTeacherState createState() => _HomePageTeacherState();
}

class _HomePageTeacherState extends State<HomePageTeacher>
    with TickerProviderStateMixin {
  String userName = '';
  final String currentUID = FirebaseAuth.instance.currentUser!.uid; // 現在のユーザーID
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestoreのインスタンス
  final FirebaseDatabase _realtimeDatabase =
      FirebaseDatabase.instance; // Realtime Databaseのインスタンス

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  //loginしているユーザー名表示
  @override
  void initState() {
    super.initState();
    _initializePage(); // 初期化処理を呼び出す
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  Future<void> _initializePage() async {
    await _loadUserInfo(); // Ensure user info is loaded
    //await fetchStudents(); // Then fetch students
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('ユーザーがログインしていません');
      final uid = user.uid;

      DocumentSnapshot? teacherSnapshot;

      // ITコレクションの検索
      teacherSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc('Teachers')
          .collection('IT')
          .doc(uid)
          .get();

      // ITに存在しない場合、GAMEコレクションの検索
      if (!teacherSnapshot.exists) {
        teacherSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc('Teachers')
            .collection('GAME')
            .doc(uid)
            .get();
      }

      // 学生情報が見つからない場合
      if (!teacherSnapshot.exists) {
        throw Exception('学生情報が見つかりません');
      }

      // データの取得と型の確認
      final studentData = teacherSnapshot.data();
      if (studentData == null || !(studentData is Map<String, dynamic>)) {
        throw Exception('データ形式が無効です');
      }

      final fetchedUserId = studentData['ID'];
      final fetchedUserName = studentData['NAME'];

      setState(() {
        // userId = fetchedUserId?.toString() ?? 'Unknown';
        userName = fetchedUserName?.toString() ?? 'Unknown';
      });
    } catch (e) {
      print('エラーが発生しました: $e');
      setState(() {
        userName = 'エラー: ユーザー情報の取得に失敗しました';
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SizedBox(height: 20),
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: AnimatedWelcomeMessage(
                    username: userName.isNotEmpty ? userName : 'Loading...',
                  ),
                ),
              ),

              SizedBox(height: 100),
              CustomInputContainer(
                inputWidgets: [
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBoxedButton(
                          context: context,
                          label: 'ＱＲコード作成',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TeacherQrcode(),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildBoxedButton(
                          context: context,
                          label: 'TestPage',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TestPage()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBoxedButton(
                          context: context,
                          label: '出席管理',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      teacherAttendanceManagementPage()),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildBoxedButton(
                          context: context,
                          label: '4',
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }

  Widget _buildBoxedButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 60, //
      decoration: BoxDecoration(
        color: Color(0xFF7B1FA2),
        borderRadius: BorderRadius.circular(10), //
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16, // Text size
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
