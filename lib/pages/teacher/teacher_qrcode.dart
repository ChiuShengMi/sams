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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "教員用授業QRコード",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              CustomButton(
                text: "戻る", // 戻るボタン
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePageTeacher()),
                  );
                },
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Divider(color: Colors.grey, thickness: 1.5, height: 15.0),
          SizedBox(
            height: 30,
          ),
          isTeacher
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: classList.isEmpty
                      ? Center(child: Text("関連する授業が見つかりませんでした"))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: TableCellHeader(text: "授業名")),
                              DataColumn(label: TableCellHeader(text: "授業ID")),
                              DataColumn(label: TableCellHeader(text: "曜日")),
                              DataColumn(label: TableCellHeader(text: "時間割")),
                              DataColumn(label: TableCellHeader(text: "QRコード")),
                            ],
                            rows: classList.map((classData) {
                              final className = classData["className"] ?? "未指定";
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

                              return DataRow(
                                color:
                                    MaterialStateProperty.resolveWith<Color?>(
                                        (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.hovered)) {
                                    return Colors.grey[
                                        200]; // Highlight color when hovered
                                  }
                                  return Colors.white; // Default row color
                                }),
                                cells: [
                                  DataCell(
                                      Text(classData["className"] ?? "未指定")),
                                  DataCell(Text(classData["classID"] ?? "不明")),
                                  DataCell(Text(classData["day"] ?? "不明")),
                                  DataCell(Text(classData["time"] ?? "不明")),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () async {
                                        DateTime now = DateTime.now();
                                        String todayDay =
                                            _getJapaneseWeekday(now.weekday);
                                        if (classData["day"] != todayDay) {
                                          bool? proceed =
                                              await _showWarningDialog(
                                            context,
                                            "授業の曜日ではありません。それでも生成しますか？",
                                          );
                                          if (proceed == null || !proceed)
                                            return;
                                        }

                                        String currentDate =
                                            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                                        await addAttendanceToSubject(
                                          classData["classType"],
                                          classData["classID"],
                                          currentDate,
                                        );

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
                          ),
                        ),
                )
              : Center(child: Text("教員ではないため、授業情報を表示できません")),
        ],
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
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "出席用QRコード生成",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                CustomButton(
                  text: "戻る", // 戻るボタン
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TeacherQrcode()),
                    );
                  },
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Divider(color: Colors.grey, thickness: 1.5, height: 15.0),
            SizedBox(
              height: 80,
            ),
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
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
