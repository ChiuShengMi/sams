import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sams/pages/loginPages/login.dart';
import 'package:sams/pages/mainPages/subjectlist/subjecttable.dart';
import 'package:sams/pages/user/add.dart';
import 'package:sams/pages/user/list.dart';
import 'package:sams/widget/appbarlogout.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/pages/testPages/testPages.dart';
import 'package:sams/widget/custom_input_container.dart';

class HomePageAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(), // Custom AppBar 적용
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      "管理者トップ画面",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Divider(color: Colors.grey, thickness: 1.5, height: 15.0),
                    SizedBox(height: 100),
                    CustomInputContainer(
                      inputWidgets: [
                        SizedBox(height: 20),

                        // 첫 번째 줄 버튼
                        Row(
                          children: [
                            Expanded(
                              child: _buildBoxedButton(
                                context: context,
                                label: '出席総計管理',
                                onPressed: () {
                                  // 첫 번째 버튼 동작
                                },
                              ),
                            ),
                            SizedBox(width: 20), // 버튼 사이 간격
                            Expanded(
                              child: _buildBoxedButton(
                                context: context,
                                label: '全体出席データ管理',
                                onPressed: () {
                                  // 두 번째 버튼 동작
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // 두 번째 줄 버튼
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
                            SizedBox(width: 20), // 버튼 사이 간격
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
                              _buildBoxedButton(
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
                            ])
                        // Test Page 버튼
                      ],
                    ),
                  ])),
        ),
      ),
      bottomNavigationBar: BottomBar(), // Custom BottomBar 적용
    );
  }

  // 버튼 스타일을 위한 헬퍼 메서드
  Widget _buildBoxedButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Color(0xFF7B1FA2), // 버튼 색상
        borderRadius: BorderRadius.circular(10),
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class SubjecttableNew extends StatefulWidget {
  @override
  _SubjecttableNewState createState() => _SubjecttableNewState();
}

class _SubjecttableNewState extends State<SubjecttableNew> {
  // Define necessary controllers for input fields (e.g., for the new lesson form)
  late TextEditingController _classController;
  late TextEditingController _teacherController;
  late TextEditingController _dayController;
  late TextEditingController _timeController;
  late TextEditingController _classroomController;
  late TextEditingController _placeController;
  late TextEditingController _qrCodeController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _classController = TextEditingController();
    _teacherController = TextEditingController();
    _dayController = TextEditingController();
    _timeController = TextEditingController();
    _classroomController = TextEditingController();
    _placeController = TextEditingController();
    _qrCodeController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose controllers when done
    _classController.dispose();
    _teacherController.dispose();
    _dayController.dispose();
    _timeController.dispose();
    _classroomController.dispose();
    _placeController.dispose();
    _qrCodeController.dispose();
    super.dispose();
  }

  // Method to handle saving the new lesson data
  void _saveNewLesson() {
    // Your save logic goes here (e.g., saving to Firebase)
    print("New lesson saved: ${_classController.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("新しい授業作成"), // Title of the page
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _classController,
              decoration: InputDecoration(labelText: "授業名"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _teacherController,
              decoration: InputDecoration(labelText: "教師名"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _dayController,
              decoration: InputDecoration(labelText: "授業曜日"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(labelText: "時間割"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _classroomController,
              decoration: InputDecoration(labelText: "教室"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _placeController,
              decoration: InputDecoration(labelText: "号館"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _qrCodeController,
              decoration: InputDecoration(labelText: "QRコード"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveNewLesson, // Call the save method when pressed
              child: Text("保存"),
            ),
          ],
        ),
      ),
    );
  }
}
