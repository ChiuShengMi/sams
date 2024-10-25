import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth パッケージをインポート
import 'package:sams/pages/loginPages/login.dart';
import 'package:sams/pages/mainPages/subjectlist/subjecttable.dart';
import 'package:sams/widget/appbarlogout.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/pages/testPages/testPages.dart';
import 'package:sams/pages/mainPages/subjectlist/subjecttable.dart';
import 'package:sams/main.dart';

class HomePageAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(), // カスタムAppBarを適用
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 中央揃え
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.all(150.0), // Padding around the content
                child: Container(
                  padding: const EdgeInsets.all(50.0), // 内側に余白を追加
                  decoration: BoxDecoration(
                    color: Colors.white, // 背景色
                    borderRadius: BorderRadius.circular(10), // 角を丸くする
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // シャドウの色
                        spreadRadius: 5, // シャドウの広がり
                        blurRadius: 7, // シャドウのぼかし
                        offset: Offset(0, 3), // シャドウの位置
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // 中央揃え vertically
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // 中央揃え horizontally
                      children: [
                        SizedBox(height: 20),

                        // First Row with Equal-Sized Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // First Button
                            Expanded(
                              child: _buildBoxedButton(
                                context: context,
                                label: '出席総計管理',
                                onPressed: () {
                                  //押されたとき処理
                                },
                              ),
                            ),

                            SizedBox(width: 20), // Space between buttons

                            // Second Button
                            Expanded(
                              child: _buildBoxedButton(
                                context: context,
                                label: '全体出席データ管理',
                                onPressed: () {
                                  //押されたとき処理
                                },
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Second Row with Equal-Sized Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Third Button
                            Expanded(
                              child: _buildBoxedButton(
                                context: context,
                                label: '授業リスト',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Subjecttable()),
                                  );
                                },
                              ),
                            ),

                            SizedBox(width: 20), // Space between buttons

                            // Fourth Button
                            Expanded(
                              child: _buildBoxedButton(
                                context: context,
                                label: 'ユーザ管理',
                                onPressed: () {
                                  //押されたとき処理
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Place the Test Page button at the bottom
          Padding(
            padding: const EdgeInsets.all(5.0), // Padding around the button
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
        ],
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
}
