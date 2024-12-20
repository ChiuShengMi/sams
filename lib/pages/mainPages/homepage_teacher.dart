import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth パッケージをインポート
import 'package:sams/pages/admin/log/log.dart';
import 'package:sams/pages/loginPages/login.dart';
import 'package:sams/pages/testPages/testPages.dart';
import 'package:sams/widget/appbarlogout.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/pages/teacher/teacher_qrcode.dart';
import 'package:sams/widget/custom_input_container.dart';

class HomePageTeacher extends StatelessWidget {
  @override
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
              Text(
                "教員トップ画面",
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
                          label: '',
                          onPressed: () {},
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
