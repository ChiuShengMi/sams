import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreをインポート
import 'package:sams/utils/firebase_auth.dart';
import 'package:sams/utils/firebase_realtime.dart'; // データベースサービスをインポート
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeScreen extends StatefulWidget {
  @override
  _QRCodeScreenState createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
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

  // ユーザーが教師かどうかを確認する
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

  // サービスの fetchClasses メソッドを呼び出して授業データを取得する
  Future<void> fetchClasses() async {
    // 授業データを取得
    List<Map<String, dynamic>> results =
        await _databaseService.fetchClasses(true, true); // 授業データを取得

    // 現在のUIDに基づいてTEACHER_IDをフィルタリング
    List<Map<String, dynamic>> filteredResults = results.where((classData) {
      final teacherIdMap =
          classData["TEACHER_ID"] as Map<dynamic, dynamic>?; // TEACHER_IDを取得
      return teacherIdMap != null &&
          teacherIdMap.containsKey(currentUID); // UIDが存在するか確認
    }).toList();

    // 授業データを更新する
    setState(() {
      classList = filteredResults;
    });
  }

  // FirestoreにATTENDANCEデータを追加する
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
            'GENERATEDAT': DateTime.now().toIso8601String(),
            'STATUS': 'active',
          },
        },
      }, SetOptions(merge: true)); // 既存データにマージ
      print("ATTENDANCEデータを追加しました");
    } catch (e) {
      print("Firestoreのエラー: $e");
    }
  }

  // 授業の曜日を確認するメソッド
  String _getJapaneseWeekday(int weekday) {
    const weekdays = ["月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日", "日曜日"];
    return weekdays[weekday - 1];
  }

  // 確認ダイアログを表示する
  Future<bool?> _showWarningDialog(BuildContext context, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("確認"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // キャンセル
            child: Text("いいえ"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // 続行
            child: Text("はい"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("教員用授業 QRコード")),
      body: Center(
        child: isTeacher
            ? classList.isEmpty
                ? Text("関連する授業が見つかりませんでした")
                : ListView.builder(
                    itemCount: classList.length,
                    itemBuilder: (context, index) {
                      final classData = classList[index];
                      return ListTile(
                        title: Text(
                          "${classData["className"] ?? "未指定の授業"}ー${classData["day"] ?? "曜日不明"}ー${classData["time"] ?? "時間不明"}限目",
                        ),
                        subtitle: Text("授業ID: ${classData["classID"]}"),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            DateTime now = DateTime.now();

                            // 曜日のチェック
                            String todayDay = _getJapaneseWeekday(now.weekday);
                            if (classData["day"] != todayDay) {
                              bool? proceed = await _showWarningDialog(
                                context,
                                "授業の曜日ではありません。それでも生成しますか？",
                              );
                              if (proceed == null || !proceed) return;
                            }

                            // FirestoreにATTENDANCEデータを追加
                            String currentDate =
                                "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                            await addAttendanceToSubject(
                              classData["classType"], // ITまたはGAME
                              classData["classID"], // 授業ID
                              currentDate, // 生成された日付
                            );

                            // QRコードデータを生成
                            final qrData = jsonEncode({
                              "classID": classData["classID"],
                              "className": classData["className"],
                              "day": classData["day"],
                              "time": classData["time"],
                              "classroom": classData["classroom"],
                              "place": classData["place"],
                              "create_at": DateTime.now().toString()
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    QrCodeDisplayScreen(data: qrData),
                              ),
                            );
                          },
                          child: Text("QRコードを表示"),
                        ),
                      );
                    },
                  )
            : Text("教員ではないため、授業情報を表示できません"),
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
      appBar: AppBar(title: Text("出席用QRコード生成")),
      body: Center(
        child: QrImageView(
          data: data, // QRコードの内容
          version: QrVersions.auto,
          size: 200.0, // QRコードのサイズ
        ),
      ),
    );
  }
}
