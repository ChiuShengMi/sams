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
                                for (var i = 0;
                                    i < filteredClassList.length;
                                    i++)
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: i % 2 == 0
                                          ? Colors.grey[200] // 偶数行: グレー
                                          : Colors.grey[100], // 奇数行: 薄いグレー
                                    ),
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          widget.onClassSelected(
                                            filteredClassList[i]['className'] ??
                                                '',
                                            filteredClassList[i]['classType'] ??
                                                '',
                                            filteredClassList[i]['classID'] ??
                                                '',
                                          );
                                        },
                                        child: buildTableCell(
                                            filteredClassList[i]['className'] ??
                                                ''),
                                      ),
                                      buildTableCell(
                                          filteredClassList[i]['day'] ?? ''),
                                      buildTableCell(
                                          filteredClassList[i]['time'] ?? ''),
                                      buildEditCell(
                                        context,
                                        '学生追加',
                                        filteredClassList[i],
                                        filteredClassList[i]['classType'] ?? '',
                                        filteredClassList[i]['classID'] ?? '',
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
        setState(() {});
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
