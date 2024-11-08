import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/pages/user/add.dart';
import 'package:sams/widget/actionbar.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/custom_input_container.dart';
import 'package:sams/widget/dropbox/custom_dropdown.dart';
import 'package:sams/widget/searchbar/custom_input.dart';
import 'package:sams/widget/table/custom_table.dart';

class UserList extends StatelessWidget {
  final TextEditingController searchInputController = TextEditingController();
  final firestore = FirebaseFirestore.instance;

  Future<List<List<String>>> _fetchStudents() async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('Users')
          .doc('Students')
          .collection('IT')
          .get();

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
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
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
                        hintText: 'Select Option',
                        items: [],
                        onChanged: (value) {},
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
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ]),
              CustomInputContainer(
                title: 'User List',
                inputWidgets: [
                  FutureBuilder<List<List<String>>>(
                    future: _fetchStudents(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final data = snapshot.data ?? [];
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
                      }),
                  SizedBox(width: 16),
                  MediumButton(
                      text: '追加',
                      onPressed: () {
                        {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserAdd()),
                          );
                        }
                      }),
                  SizedBox(width: 16)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
