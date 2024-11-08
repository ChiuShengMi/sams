import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    List<Map<String, dynamic>> results =
        await _databaseService.fetchClasses(true, true); // 2つのパラメータを渡す
    setState(() {
      classList = results; // 授業データを更新する
    });
  }

  // 授業の曜日を確認するメソッド
  String _getJapaneseWeekday(int weekday) {
    const weekdays = ["月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日", "日曜日"];
    return weekdays[weekday - 1];
  }

  // 授業の時間範囲を確認するメソッド
  bool _isWithinClassTime(DateTime now, int classTime) {
    final schedule = {
      1: {"start": "09:00", "end": "10:45"},
      2: {"start": "11:00", "end": "12:30"},
      3: {"start": "13:30", "end": "15:00"},
      4: {"start": "15:15", "end": "16:45"},
      5: {"start": "17:00", "end": "18:30"},
    };

    if (!schedule.containsKey(classTime)) return false;

    // 授業の開始時間と終了時間をパースする
    final startTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(schedule[classTime]!["start"]!.split(":")[0]),
      int.parse(schedule[classTime]!["start"]!.split(":")[1]),
    );
    final endTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(schedule[classTime]!["end"]!.split(":")[0]),
      int.parse(schedule[classTime]!["end"]!.split(":")[1]),
    );

    // 授業開始の15分前に対応
    final allowedTime = startTime.subtract(Duration(minutes: 15));

    return now.isAfter(allowedTime) && now.isBefore(endTime);
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

                            // 時間のチェック
                            int classTime =
                                int.tryParse(classData["time"]) ?? 0;
                            if (!_isWithinClassTime(now, classTime)) {
                              bool? proceed = await _showWarningDialog(
                                context,
                                "授業の時間ではありません。それでも生成しますか？",
                              );
                              if (proceed == null || !proceed) return;
                            }

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
