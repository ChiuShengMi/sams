import 'package:flutter/material.dart';
import 'package:sams/pages/admin/admin_attendanceCalculator.dart';
import 'package:sams/pages/admin/admin_leavesManagement.dart';
import 'package:sams/pages/admin/admin_link.dart';
import 'package:sams/pages/admin/log/log.dart';
import 'package:sams/pages/admin/subjectlist/subjecttable.dart';
import 'package:sams/pages/loginPages/login.dart';
// import 'package:sams/pages/user/add.dart';
import 'package:sams/pages/user/list.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/pages/testPages/testPages.dart';
import 'package:sams/widget/custom_input_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/Animation/animation_Welcome.dart';
import 'package:sams/pages/admin/admin_announce.dart';

class HomePageAdmin extends StatefulWidget {
  @override
  _HomePageAdminState createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin>
    with SingleTickerProviderStateMixin {
  String userName = 'Loading...';
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializePage();

    // 애니메이션 초기화
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializePage() async {
    await _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('ユーザーがログインしていません');
      final uid = user.uid;

      DocumentSnapshot? managerSnapshot;

      managerSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc('Managers')
          .collection('IT')
          .doc(uid)
          .get();

      if (!managerSnapshot.exists) {
        managerSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc('Managers')
            .collection('GAME')
            .doc(uid)
            .get();
      }

      if (!managerSnapshot.exists) {
        throw Exception('学生情報が見つかりません');
      }

      final managerData = managerSnapshot.data() as Map<String, dynamic>;
      final fetchedUserName = managerData['NAME'];

      setState(() {
        userName = fetchedUserName ?? 'Unknown';
      });
    } catch (e) {
      print('エラーが発生しました: $e');
      setState(() {
        userName = 'エラー: ユーザー情報の取得に失敗しました';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('管理者トップ画面'),
        backgroundColor: Color(0xFF7B1FA2),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            tooltip: 'ログアウト',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: AnimatedWelcomeMessage(
                          username:
                              userName.isNotEmpty ? userName : 'Loading...',
                        ),
                      ),
                    ),
                    SizedBox(height: 80),
                    CustomInputContainer(
                      inputWidgets: [
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildBoxedButton(
                                context: context,
                                label: 'アナウンス設定',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AdminAnnouncePage()),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: _buildBoxedButton(
                                context: context,
                                label: '全体出席データ管理',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AdminAttendanceCalculator()),
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
                                label: '授業リスト',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SubjectTable()),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: _buildBoxedButton(
                                context: context,
                                label: 'ユーザ管理',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UserList()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _buildBoxedButton(
                                  context: context,
                                  label: 'Test Page',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TestPage()),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: _buildBoxedButton(
                                  context: context,
                                  label: 'ログ',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => logPage()),
                                    );
                                  },
                                ),
                              ),
                            ]),
                        SizedBox(height: 20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _buildBoxedButton(
                                  context: context,
                                  label: '休暇管理',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              adminLeaveManagement()),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: _buildBoxedButton(
                                  context: context,
                                  label: '授業と学生紐付け',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => adminPageLink(
                                          onClassSelected:
                                              (String selectedClass,
                                                  String classType,
                                                  String classID) {
                                            print(
                                                'Selected Class: $selectedClass, Type: $classType, ID: $classID');

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Class Selected: $selectedClass')),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ]),
                      ],
                    ),
                  ])),
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
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF7B1FA2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
