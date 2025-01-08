import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/pages/admin/admin_link.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/pages/mainPages/homepage_admin.dart';
import 'package:sams/pages/admin/admin_link.dart';

import 'package:sams/utils/log.dart';

// 学生検索のpage
class AdminLink2 extends StatefulWidget {
  final String selectedClass;
  final String classType;
  final String classID;

  AdminLink2({
    required this.selectedClass,
    required this.classType,
    required this.classID,
  });

  @override
  _adminLink2State createState() => _adminLink2State();
}

class _adminLink2State extends State<AdminLink2> {
  TextEditingController studentSearchController = TextEditingController();
  bool isITSelected = false;
  bool isGameSelected = false;
  List<Map<String, dynamic>> studentList = [];
  List<Map<String, dynamic>> filteredStudentList = [];
  Set<String> selectedStudentIds = {};

  @override
  void initState() {
    super.initState();
    fetchStudents();
    studentSearchController.addListener(() => filterStudentList());
  }

  Future<void> fetchStudents() async {
    List<Map<String, dynamic>> results = [];

    CollectionReference studentsITRef =
        FirebaseFirestore.instance.collection('Users/Students/IT');
    CollectionReference studentsGameRef =
        FirebaseFirestore.instance.collection('Users/Students/GAME');

    if (isITSelected || isGameSelected) {
      if (isITSelected) results.addAll(await _fetchStudentData(studentsITRef));
      if (isGameSelected)
        results.addAll(await _fetchStudentData(studentsGameRef));
    } else {
      results.addAll(await _fetchStudentData(studentsITRef));
      results.addAll(await _fetchStudentData(studentsGameRef));
    }

    setState(() {
      studentList = results;
      filterStudentList();
    });
    // ログメッセージを追加
    await Utils.logMessage('学生データを取得しました: ${results.length}件');
  }

  Future<List<Map<String, dynamic>>> _fetchStudentData(
      CollectionReference path) async {
    QuerySnapshot snapshot = await path.get();
    List<Map<String, dynamic>> result = [];

    if (snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        result.add({
          'id': data['ID'],
          'name': data['NAME'],
          'class': data['CLASS'],
          'uid': doc.id,
        });
      }
    }

    return result;
  }

  void filterStudentList() {
    String searchText = studentSearchController.text.toLowerCase();
    setState(() {
      filteredStudentList = studentList.where((studentData) {
        final studentName =
            (studentData['name'] ?? '').toString().toLowerCase();
        final studentClass =
            (studentData['class'] ?? '').toString().toLowerCase();
        final studentID = (studentData['id'] ?? '').toString();
        return selectedStudentIds.contains(studentData['uid']) ||
            studentName.contains(searchText) ||
            studentClass.contains(searchText) ||
            studentID.contains(searchText);
      }).toList();

      for (var student in studentList) {
        if (selectedStudentIds.contains(student['uid']) &&
            !filteredStudentList.contains(student)) {
          filteredStudentList.add(student);
        }
      }
    });
  }

  Future<void> saveSelectedStudents() async {
    String classType = widget.classType;
    String classID = widget.classID;

    Map<String, dynamic> studentData = {
      for (var i = 0; i < filteredStudentList.length; i++)
        if (selectedStudentIds.contains(filteredStudentList[i]['uid']))
          i.toString(): {
            'UID': filteredStudentList[i]['uid'],
            'NAME': filteredStudentList[i]['name'],
            //'ID': filteredStudentList[i]['id'],
            'ID': filteredStudentList[i]['id'].toString(), // 保存時にもStringに変換

            'CLASS': filteredStudentList[i]['class'],
          },
    };

    Map<String, dynamic> data = {
      'CLASS': widget.selectedClass,
      'STD': studentData,
    };

    await FirebaseFirestore.instance
        .collection('Class')
        .doc(classType)
        .collection('Subjects')
        .doc(classID)
        .set(data, SetOptions(merge: true));
    // ログメッセージを追加
    await Utils.logMessage(
        ' クラス=${widget.selectedClass}, 学生数=${studentData.length}');

// Update the state to refresh the UI
    setState(() {
      filteredStudentList.clear(); //
    });

    // Show success message after saving
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('学生が正常に保存されました。')),
    );

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    studentSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '選択中の授業: ${widget.selectedClass}',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 500,
                        child: TextField(
                          controller: studentSearchController,
                          decoration: InputDecoration(
                            hintText: '学生検索する',
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      ToggleButtons(
                        isSelected: [isITSelected, isGameSelected],
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('IT'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('GAME'),
                          ),
                        ],
                        onPressed: (int index) {
                          setState(() {
                            if (index == 0) {
                              isITSelected = !isITSelected;
                            } else if (index == 1) {
                              isGameSelected = !isGameSelected;
                            }
                            fetchStudents();
                          });
                        },
                      ),
                      SizedBox(width: 40),
                      CustomButton(
                        text: '全体取消',
                        onPressed: () {
                          setState(() {
                            selectedStudentIds.clear();
                          });
                        },
                      ),
                      SizedBox(width: 20),
                      CustomButton(
                        text: '全体追加',
                        onPressed: () {
                          setState(() {
                            for (var student in filteredStudentList) {
                              selectedStudentIds.add(student['uid'].toString());
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Use a ListView for displaying students
            Expanded(
              child: Column(
                children: [
                  // Header Container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                    ),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1),
                      },
                      children: [
                        // Header Row
                        TableRow(
                          children: [
                            TableCellHeader(text: '学籍番号'), // 学籍番号
                            TableCellHeader(text: '学生名'), // 学生名
                            TableCellHeader(text: 'クラス'), // クラス
                            TableCellHeader(text: 'チェック'), // チェック
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Table Container
                  Expanded(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width, // 最小幅
                        ),
                        child: SingleChildScrollView(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0),
                              ),
                            ),
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(1),
                                2: FlexColumnWidth(1),
                                3: FlexColumnWidth(1),
                              },
                              children: [
                                // Dynamic Rows with alternating colors
                                ...filteredStudentList
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final studentData = entry.value;
                                  final isEvenRow = index % 2 == 0;

                                  return TableRow(
                                    decoration: BoxDecoration(
                                      color: isEvenRow
                                          ? Colors.grey[200]
                                          : Colors.grey[100],
                                    ),
                                    children: [
                                      buildTableCell(
                                        studentData['id']?.toString() ?? '',
                                      ),
                                      buildTableCell(
                                        studentData['name'] ?? '',
                                      ),
                                      buildTableCell(
                                        studentData['class'] ?? '',
                                      ),
                                      TableCell(
                                        child: Checkbox(
                                          value: selectedStudentIds
                                              .contains(studentData['uid']),
                                          onChanged: (bool? value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedStudentIds
                                                    .add(studentData['uid']);
                                              } else {
                                                selectedStudentIds
                                                    .remove(studentData['uid']);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  text: '戻る',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(
                  width: 30,
                ),
                CustomButton(
                    onPressed: saveSelectedStudents, // 保存ロジック
                    text: '確定'), // ボタンのテキスト
              ],
            ),
          ),
          BottomBar(),
        ],
      ),
      //bottomNavigationBar: BottomBar(),
    );
  }
}

// テーブルのセルを構築するメソッド
Widget buildTableCell(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}

// テーブルヘッダーのセルウィジェット
class TableCellHeader extends StatelessWidget {
  final String text;

  const TableCellHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
