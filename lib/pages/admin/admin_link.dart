import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/pages/mainPages/homepage_admin.dart';
import 'package:sams/pages/admin/admin_link2.dart';

import 'package:sams/utils/log.dart';

class adminPageLink extends StatefulWidget {
  final Function(String selectedClass, String classType, String classID)
      onClassSelected;
  adminPageLink({required this.onClassSelected});
  @override
  _adminPageLinkState createState() => _adminPageLinkState();
}

class _adminPageLinkState extends State<adminPageLink> {
  TextEditingController classSearchController = TextEditingController();
  bool isITSelected = false;
  bool isGameSelected = false;
  List<Map<String, dynamic>> classList = [];
  List<Map<String, dynamic>> filteredClassList = [];

  @override
  void initState() {
    super.initState();
    fetchClasses();
    classSearchController.addListener(filterClassList);
  }

  void refresh() {
    setState(() {
      // Refresh logic here
    });
  }

  Future<void> fetchClasses() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('CLASS');
    List<Map<String, dynamic>> results = [];

    if (isITSelected) {
      results.addAll(await _fetchClassData(dbRef.child('IT')));
    }
    if (isGameSelected) {
      results.addAll(await _fetchClassData(dbRef.child('GAME')));
    }
    if (!isITSelected && !isGameSelected) {
      results.addAll(await _fetchClassData(dbRef.child('IT')));
      results.addAll(await _fetchClassData(dbRef.child('GAME')));
    }

    setState(() {
      classList = results;
      filterClassList();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchClassData(
      DatabaseReference path) async {
    DataSnapshot snapshot = await path.get();
    List<Map<String, dynamic>> result = [];

    if (snapshot.exists) {
      Map<dynamic, dynamic> classes = snapshot.value as Map<dynamic, dynamic>;
      classes.forEach((key, value) {
        result.add({
          'className': value['CLASS'] ?? 'Unknown Class',
          'day': value['DAY'] ?? 'Unknown Day',
          'time': value['TIME'] ?? 'Unknown Time',
          'classID': key,
          'classType': path.key ?? 'Unknown Type',
        });
      });
    }
    return result;
  }

  void filterClassList() {
    String searchText = classSearchController.text.toLowerCase();
    setState(() {
      filteredClassList = classList.where((classData) {
        final className = classData['className'].toLowerCase();
        final day = classData['day'].toLowerCase();
        return className.contains(searchText) || day.contains(searchText);
      }).toList();
    });
  }

  @override
  void dispose() {
    classSearchController.dispose();
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
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Text(
                      "授業に学生を追加",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )
                  ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 500,
                        child: TextField(
                          controller: classSearchController,
                          decoration: InputDecoration(
                            hintText: '検索する内容を入力',
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      ToggleButtons(
                        isSelected: [isITSelected, isGameSelected],
                        children: [Text('IT'), Text('GAME')],
                        onPressed: (int index) {
                          setState(() {
                            if (index == 0) isITSelected = !isITSelected;
                            if (index == 1) isGameSelected = !isGameSelected;
                            fetchClasses();
                          });
                        },
                      ),
                      SizedBox(
                        width: 90,
                      ),
                      CustomButton(
                        text: "戻る",
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePageAdmin()),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  // ヘッダー部分 (固定)
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
                        TableRow(
                          children: [
                            TableCellHeader(text: 'クラス'),
                            TableCellHeader(text: '曜日'),
                            TableCellHeader(text: '時間割'),
                            TableCellHeader(text: '編集'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // データ部分 (スクロール可能)
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // 横スクロール
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth:
                              MediaQuery.of(context).size.width, // 最小幅を画面幅に設定
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical, // 縦スクロール
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0),
                              ),
                              border:
                                  Border.all(color: Colors.black, width: 0.1),
                            ),
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(1),
                                2: FlexColumnWidth(1),
                                3: FlexColumnWidth(1),
                              },
                              children: [
                                for (var classData in filteredClassList)
                                  TableRow(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          widget.onClassSelected(
                                            classData['className'] ?? '',
                                            classData['classType'] ?? '',
                                            classData['classID'] ?? '',
                                          );
                                        },
                                        child: buildTableCell(
                                            classData['className'] ?? ''),
                                      ),
                                      buildTableCell(classData['day'] ?? ''),
                                      buildTableCell(classData['time'] ?? ''),
                                      buildEditCell(
                                          context,
                                          '学生追加',
                                          classData,
                                          classData['classType'] ?? '',
                                          classData['classID'] ?? '')
                                    ],
                                  ),
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
      bottomNavigationBar: BottomBar(),
    );
  }
}

//編集セルを構築するメソッド
Widget buildEditCell(BuildContext context, String text,
    Map<String, dynamic> selectedClass, String classType, String classId) {
  return InkWell(
    onTap: () async {
      // Navigate to AdminLink2 with the selected class data
      bool? result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminLink2(
            selectedClass: selectedClass['className'] ?? '',
            classType: classType,
            classID: classId,
          ),
        ),
      );
      if (result == true) {
        // setState(() {});
      }
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    ),
  );
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


// 学生検索のダイアログ
class StudentSelectionDialog extends StatefulWidget {
  final String selectedClass;
  final String classType;
  final String classID;

  StudentSelectionDialog({
    required this.selectedClass,
    required this.classType,
    required this.classID,
  });

  @override
  _StudentSelectionDialogState createState() => _StudentSelectionDialogState();
}

class _StudentSelectionDialogState extends State<StudentSelectionDialog> {
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
            'ID': filteredStudentList[i]['id'],
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



log のメッセージ
await Utils.logMessage(
        'ここにLOGメッセージを入れる',
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
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ClassSelectionDialog(
                          onClassSelected: (selectedClass, classType, classID) {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return StudentSelectionDialog(
                                  selectedClass: selectedClass,
                                  classType: classType,
                                  classID: classID,
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                Text(
                  '選択中の授業: ${widget.selectedClass}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedStudentIds.clear();
                        });
                      },
                      child: Text('全体取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          for (var student in filteredStudentList) {
                            selectedStudentIds.add(student['uid'].toString());
                          }
                        });
                      },
                      child: Text('全体追加'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: studentSearchController,
              decoration: InputDecoration(
                labelText: '学生検索',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ToggleButtons(
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
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredStudentList.length,
              itemBuilder: (context, index) {
                final studentData = filteredStudentList[index];
                final studentUID = studentData['uid'].toString();
                return ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${studentData['id']} - ${studentData['name']} - ${studentData['class']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Checkbox(
                        value: selectedStudentIds.contains(studentUID),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedStudentIds.add(studentUID);
                            } else {
                              selectedStudentIds.remove(studentUID);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: saveSelectedStudents,
              child: Text('確定'),
            ),
          ),
        ],
      ),
    );
  }
}
