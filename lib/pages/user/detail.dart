import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sams/widget/actionbar.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/custom_input_container.dart';
import 'package:sams/pages/user/edit.dart';
import 'package:sams/pages/user/list.dart';
import 'package:sams/widget/modal/confirmation_modal.dart';
import 'package:sams/utils/log.dart'; // log.dart 참조

class UserDetail extends StatelessWidget {
  final String documentPath;

  UserDetail({required this.documentPath});

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

  Future<String?> _fetchCurrentUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('로그인된 사용자를 찾을 수 없습니다.');

      final uid = user.uid;

      DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc('Managers')
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
        throw Exception('관리자 정보를 찾을 수 없습니다.');
      }

      return adminSnapshot['NAME'];
    } catch (e) {
      print("Error fetching admin name: $e");
      return null;
    }
  }

  Future<void> _softDeleteUser(BuildContext context, String adminName,
      String userName, String userId, String userEmail) async {
    try {
      // Firestore에서 DELETE_FLG를 1로 업데이트
      await FirebaseFirestore.instance.doc(documentPath).update({
        'DELETE_FLG': 1,
      });

      print("Firestore: DELETE_FLG updated to 1 for $userEmail");

      // Firebase Authentication에서 사용자 무효화 처리
      User? user = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(userEmail)
          .then((methods) {
        if (methods.isNotEmpty) {
          return FirebaseAuth.instance.currentUser;
        }
        return null;
      });

      if (user != null) {
        await user.updatePassword(
            "DISABLED_${DateTime.now().millisecondsSinceEpoch}");
        print("Authentication: User disabled for $userEmail");
      }

      // 로그 메시지 추가
      await Utils.logMessage('$adminName が $userName-$userId を無効化しました。');

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User has been deactivated."),
        backgroundColor: Colors.green,
      ));

      // 페이지 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => UserList()),
        (route) => false,
      );
    } catch (e) {
      print("Error soft deleting user: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to deactivate user: $e"),
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
          String userEmail = userData['MAIL'] ?? 'N/A';

          return FutureBuilder<String?>(
            future: _fetchCurrentUserName(),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              String adminName = adminSnapshot.data ?? '관리자';

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
                                      loginEmail: userEmail,
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
                                      await _softDeleteUser(context, adminName,
                                          userName, userId, userEmail);
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
                          _buildDetailRow('Login E-mail', userEmail),
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
