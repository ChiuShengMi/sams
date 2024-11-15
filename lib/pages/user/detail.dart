import 'package:flutter/material.dart';
import 'package:sams/widget/actionbar.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/custom_input_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/pages/user/edit.dart';
import 'package:sams/pages/user/list.dart';
import 'package:sams/widget/modal/delete_modal.dart'; // DeleteModal import

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

  Future<void> _deleteUser(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.doc(documentPath).delete();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User deleted successfully!"),
        backgroundColor: Colors.green,
      ));

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => UserList()),
        (route) => false,
      );
    } catch (e) {
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserEdit(
                                  documentPath: documentPath,
                                  loginEmail: userData['MAIL'] ?? 'N/A',
                                  dataId: userData['ID']?.toString() ?? 'N/A',
                                  userName: userData['NAME'] ?? 'N/A',
                                  phoneNumber: userData['TEL'] ?? 'N/A',
                                  className: userData['CLASS'] ?? 'N/A',
                                  role: userData['JOB'] ?? 'N/A',
                                  course: userData['COURSE'] ?? 'N/A',
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 30),
                        CustomButton(
                          text: '削除',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => DeleteModal(
                                onConfirm: () async {
                                  Navigator.of(context).pop(); // 모달 닫기
                                  await _deleteUser(context);
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
                      _buildDetailRow(
                          'Data ID', userData['ID']?.toString() ?? 'N/A'),
                      _buildDetailRow('User Name', userData['NAME'] ?? 'N/A'),
                      _buildDetailRow('Phone Number', userData['TEL'] ?? 'N/A'),
                      _buildDetailRow('Course', userData['COURSE'] ?? 'N/A'),
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
