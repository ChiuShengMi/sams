import 'package:flutter/material.dart';
import 'package:sams/pages/mainPages/homepage_teacher.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/bottombar.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreをインポート
import 'package:sams/utils/firebase_auth.dart';
import 'package:sams/utils/firebase_realtime.dart'; // データベースサービスをインポート
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/utils/log.dart';

class TeacherQrcode extends StatefulWidget {
  @override
  _TeacherQrcodeState createState() => _TeacherQrcodeState();
}

class _TeacherQrcodeState extends State<TeacherQrcode> {
  final String currentUID = FirebaseAuth.instance.currentUser!.uid; // 現在のユーザーID
  final RealtimeDatabaseService _databaseService =
      RealtimeDatabaseService(); // データベースサービス
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore
  bool isTeacher = false; // 教師であるかどうかのフラグ
  List<Map<String, dynamic>> classList = []; // 授業データを格納するリスト

  @override
  void initState() {
    super.initState();
    checkUserRole(); // ユーザーの役割を確認する
  }

  Future<void> checkUserRole() async {
    FiresbaseAuth firesbaseAuth = FiresbaseAuth();
    String role = await firesbaseAuth.getUserRole();
    if (role == "教員") {
      setState(() {
        isTeacher = true;
      });
      fetchClasses(); // 授業データを取得する
    } else {
      setState(() {
        isTeacher = false;
      });
    }
  }

  void _showMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("エラー"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> fetchClasses() async {
    List<Map<String, dynamic>> results =
        await _databaseService.fetchClasses(true, true); // 授業データを取得

    List<Map<String, dynamic>> filteredResults = results.where((classData) {
      final teacherIdMap =
          classData["TEACHER_ID"] as Map<dynamic, dynamic>?; // TEACHER_IDを取得
      return teacherIdMap != null &&
          teacherIdMap.containsKey(currentUID); // UIDが存在するか確認
    }).toList();

    setState(() {
      classList = filteredResults;
    });
  }

  Future<void> addAttendanceToSubject(
      String classType, String classID, String currentDate) async {
    try {
      DocumentReference subjectDoc = _firestore
          .collection('Class')
          .doc(classType)
          .collection('Subjects')
          .doc(classID);

      await subjectDoc.set({
        'ATTENDANCE': {
          currentDate: {
            'GENERATEDAE': DateTime.now().toIso8601String(),
            'STATUS': 'active',
          },
        },
      }, SetOptions(merge: true)); // 既存データにマージ
      print("ATTENDANCEデータを追加しました");
    } catch (e) {
      print("Firestoreのエラー: $e");
    }
  }

  String _getJapaneseWeekday(int weekday) {
    const weekdays = ["月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日", "日曜日"];
    return weekdays[weekday - 1];
  }

  DateTime _getClassStartTime(String time) {
    DateTime now = DateTime.now();
    switch (time) {
      case '1':
        return DateTime(now.year, now.month, now.day, 9, 15);
      case '2':
        return DateTime(now.year, now.month, now.day, 11, 0);
      case '3':
        return DateTime(now.year, now.month, now.day, 13, 30);
      case '4':
        return DateTime(now.year, now.month, now.day, 15, 15);
      case '5':
        return DateTime(now.year, now.month, now.day, 17, 0);
      default:
        throw Exception("無効なコース時間: $time");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // タイトルと戻るボタン
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                        "教員用授業QRコード",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(width: 90),
                      CustomButton(
                        text: "戻る",
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePageTeacher(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // 授業データ表示部分
            isTeacher
                ? classList.isEmpty
                    ? Center(
                        child: Text("関連する授業が見つかりませんでした"),
                      )
                    : Expanded(
                        child: SingleChildScrollView(
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
                            },
                            children: [
                              // ヘッダー行
                              TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0),
                                  ),
                                ),
                                children: [
                                  TableCellHeader(text: "授業名"),
                                  TableCellHeader(text: "授業ID"),
                                  TableCellHeader(text: "曜日"),
                                  TableCellHeader(text: "時間割"),
                                  TableCellHeader(text: "QRコード"),
                                ],
                              ),
                              // データ行
                              ...classList.asMap().entries.map((entry) {
                                int index = entry.key;
                                var classData = entry.value;
                                final className =
                                    classData["className"] ?? "未指定";
                                final classID = classData["classID"] ?? "不明";
                                final day = classData["day"] ?? "不明";
                                final time = classData["time"] ?? "不明";
                                final qrData = jsonEncode({
                                  "classID": classID,
                                  "className": className,
                                  "day": day,
                                  "time": time,
                                  "classroom": classData["classroom"],
                                  "place": classData["place"],
                                  "create_at": DateTime.now().toString()
                                });

                                // Alternate row colors
                                bool isEvenRow = index % 2 == 0;

                                return TableRow(
                                  decoration: BoxDecoration(
                                    color: isEvenRow
                                        ? Colors.grey[200]
                                        : Colors.grey[100],
                                  ),
                                  children: [
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Text(className),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Text(classID),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Text(day),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Text(time),
                                      ),
                                    ),
                                    TableCell(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  QrCodeDisplayScreen(
                                                      data: qrData),
                                            ),
                                          );
                                        },
                                        child: Text("QRコード表示"),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      )
                : Center(
                    child: Text("教員ではないため、授業情報を表示できません"),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }

  Future<bool?> _showWarningDialog(BuildContext context, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("確認"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("いいえ"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("はい"),
          ),
        ],
      ),
    );
  }
}

// QRコード表示画面
class QrCodeDisplayScreen extends StatelessWidget {
  final String data;

  QrCodeDisplayScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Title and Return Button
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                        "出席用QRコード生成",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(width: 90),
                      CustomButton(
                        text: "戻る", // 戻るボタン
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TeacherQrcode()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            SizedBox(height: 80), // Empty space for layout
            QrImageView(
              data: data,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
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
        textAlign: TextAlign.start,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
