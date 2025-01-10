import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth 임포트
import 'package:sams/widget/actionbar.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/custom_input_container.dart';
import 'package:sams/pages/user/edit.dart';
import 'package:sams/pages/user/list.dart';
import 'package:sams/widget/modal/confirmation_modal.dart';
import 'package:sams/utils/log.dart'; // log.dart 임포트

class UserDetail extends StatelessWidget {
  final String documentPath;

  UserDetail({required this.documentPath});

  // 현재 로그인된 관리자의 이름을 가져오는 함수
  Future<String?> _fetchCurrentAdminName() async {
    try {
      // Firebase Authentication에서 현재 로그인된 유저 UID를 가져옴
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('ログインユーザーが見つかりません');

      final uid = user.uid;

      // Firestore에서 관리자의 이름을 UID로 검색
      DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('Users') // 'Users' 컬렉션에서
          .doc('Managers') // 'Managers' 하위 컬렉션에서
          .collection('IT')
          .doc(uid)
          .get();

      if (!adminSnapshot.exists) {
        adminSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc('Managers')
            .collection('GAME')
            .doc(uid)
            .get();
      }

      if (!adminSnapshot.exists) {
        throw Exception('管理者情報が見つかりません');
      }

      return adminSnapshot['NAME']; // 관리자의 이름 반환
    } catch (e) {
      print("Error fetching admin name: $e");
      return null;
    }
  }

  // 유저 삭제 함수
  Future<void> _deleteUser(BuildContext context, String adminName,
      String userName, String userId) async {
    try {
      await FirebaseFirestore.instance.doc(documentPath).delete();

      // 로그 메시지 추가
      await Utils.logMessage('$adminName が $userName-$userId を削除しました。');

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User deleted successfully!"),
        backgroundColor: Colors.green,
      ));

      // 페이지 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => UserList()),
        (route) => false,
      );
    } catch (e) {
      print("Error deleting user: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to delete user: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data found'));
          }

          var userData = snapshot.data!;
          String userName = userData['NAME'] ?? 'N/A';
          String userId = userData['ID']?.toString() ?? 'N/A';

          return FutureBuilder<String?>(
            future: _fetchCurrentAdminName(),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              String adminName = adminSnapshot.data ?? '管理者';

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Actionbar(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomButton(
                              text: '修正',
                              onPressed: () async {
                                bool? result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserEdit(
                                      documentPath: documentPath,
                                      loginEmail: userData['MAIL'] ?? 'N/A',
                                      dataId: userId,
                                      userName: userName,
                                      phoneNumber: userData['TEL'] ?? 'N/A',
                                      className: userData['CLASS'] ?? 'N/A',
                                      role: userData['JOB'] ?? 'N/A',
                                      course: userData['COURSE'] ?? 'N/A',
                                    ),
                                  ),
                                );

                                if (result == true) {
                                  await Utils.logMessage(
                                      '$adminName が $userName-$userId を修正しました。');
                                }
                              },
                            ),
                            SizedBox(width: 30),
                            CustomButton(
                              text: '削除',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => DeleteModalSubEdit(
                                    onConfirmDelete: () async {
                                      Navigator.of(context).pop();
                                      await _deleteUser(
                                          context, adminName, userName, userId);
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ]),
                      CustomInputContainer(
                        title: 'User Detail',
                        inputWidgets: [
                          _buildDetailRow(
                              'Login E-mail', userData['MAIL'] ?? 'N/A'),
                          _buildDetailRow('Data ID', userId),
                          _buildDetailRow('User Name', userName),
                          _buildDetailRow(
                              'Phone Number', userData['TEL'] ?? 'N/A'),
                          _buildDetailRow(
                              'Course', userData['COURSE'] ?? 'N/A'),
                          _buildDetailRow('Class', userData['CLASS'] ?? 'N/A'),
                          _buildDetailRow('Role', userData['JOB'] ?? 'N/A'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomButton(
                            text: '戻る',
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchUserData() async {
    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.doc(documentPath).get();
      return snapshot.data() as Map<String, dynamic>?;
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
