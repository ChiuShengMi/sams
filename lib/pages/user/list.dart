import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/widget/actionbar.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/custom_input_container.dart';
import 'package:sams/widget/dropbox/custom_dropdown.dart';
import 'package:sams/widget/searchbar/custom_input.dart';
import 'package:sams/widget/table/custom_table.dart';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final TextEditingController searchInputController = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  String selectedUserType = 'Students'; // Default user type

  List<List<String>> _mapSnapshotToData(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return [
        data['ID']?.toString() ?? 'N/A',
        data['COURSE']?.toString() ?? 'N/A',
        data['CLASS']?.toString() ?? 'N/A',
        data['JOB']?.toString() ?? 'N/A',
        data['MAIL']?.toString() ?? 'N/A',
        data['NAME']?.toString() ?? 'N/A',
        data['TEL']?.toString() ?? 'N/A',
        'Edit'
      ];
    }).toList();
  }

  Stream<QuerySnapshot> _getUserStream() {
    // Update Firestore query based on selected user type
    return firestore
        .collection('Users')
        .doc(selectedUserType)
        .collection(
            'IT') // Modify if needed based on user type and specific course
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Actionbar(children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Customdropdown(
                        hintText: 'Select User Type',
                        items: [
                          DropdownMenuItem(
                              child: Text('学生'), value: 'Students'),
                          DropdownMenuItem(
                              child: Text('教員'), value: 'Teachers'),
                          DropdownMenuItem(
                              child: Text('管理者'), value: 'Managers'),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedUserType = value!;
                          });
                        },
                        size: DropboxSize.medium,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 4,
                      child: CustomInput(
                        controller: searchInputController,
                        hintText: 'Search',
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: MediumButton(
                        text: '検索',
                        onPressed: () {
                          // Add search functionality if needed
                        },
                      ),
                    ),
                  ],
                ),
              ]),
              CustomInputContainer(
                title: 'User List',
                inputWidgets: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _getUserStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final List<List<String>> data = snapshot.hasData
                          ? _mapSnapshotToData(snapshot.data!)
                          : [];

                      return CustomTable(
                        headers: [
                          '学籍番号',
                          'コース',
                          'クラス名',
                          '属性',
                          'E-Mail',
                          '名前',
                          '電話番号',
                          '修正',
                        ],
                        data: data,
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MediumButton(
                    text: '戻る',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 16),
                  MediumButton(
                    text: '追加',
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => UserAdd()),
                      // );
                    },
                  ),
                  SizedBox(width: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
