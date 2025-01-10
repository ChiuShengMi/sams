import 'package:flutter/material.dart';
import 'package:sams/pages/admin/admin_attendanceCalculator.dart';
import 'package:sams/pages/admin/admin_leavesManagement.dart';
import 'package:sams/pages/admin/admin_link.dart';
import 'package:sams/pages/admin/log/log.dart';
import 'package:sams/pages/admin/subjectlist/subjecttable.dart';
// import 'package:sams/pages/user/add.dart';
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
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF7B1FA2), // 버튼 배경색
          foregroundColor: Colors.white, // 텍스트 색상
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // 모서리 둥글기
          ),
          elevation: 5, // 그림자 효과
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
