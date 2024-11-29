import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sams/pages/loginPages/login.dart';
import 'package:sams/pages/testPages/testPages_leaves.dart';
import 'package:sams/widget/appbarlogout_mobile.dart';
import 'package:sams/pages/student/student_leaves.dart';

class HomePageStudent extends StatefulWidget {
  @override
  _HomePageStudentState createState() => _HomePageStudentState();
}

class _HomePageStudentState extends State<HomePageStudent> {
  final String currentUID = FirebaseAuth.instance.currentUser!.uid; // 現在のユーザーID
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestoreのインスタンス
  final FirebaseDatabase _realtimeDatabase =
      FirebaseDatabase.instance; // Realtime Databaseのインスタンス

  // ログアウト処理
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      // エラーが発生した場合、ログアウトできません
    }
  }

  // QRコードスキャンページへの遷移
  void _navigateToQRScanner(BuildContext parentContext) async {
    final result = await Navigator.push(
      parentContext,
      MaterialPageRoute(
        builder: (context) => QRScannerPage(),
      ),
    );

    if (result != null) {
      try {
        final decodedData = json.decode(result);
        _showAttendanceDialog(parentContext, decodedData); // 出席確認ダイアログを表示
      } catch (e) {
        // QRコードデータ解析エラー
      }
    }
  }

  // 出席確認ダイアログを表示
  Future<void> _showAttendanceDialog(
      BuildContext context, Map<String, dynamic> data) {
    final String classID = data["classID"]?.toString() ?? "";
    String classType = classID.contains("IT")
        ? "IT"
        : classID.contains("GAME")
            ? "GAME"
            : "未指定";

    final String className = data["className"]?.toString() ?? "授業名不明";
    final String day = data["day"]?.toString() ?? "曜日不明";
    final String time = data["time"]?.toString() ?? "時間不明";
    final String place = data["place"]?.toString() ?? "場所不明";
    final String classroom = data["classroom"]?.toString() ?? "教室不明";
    final String formattedDate =
        (data['create_at']?.substring(0, 10)) ?? '日付不明';

    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("出席確認"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('授業: $className ー $day - $time 限目'),
            Text('場所: $place'),
            Text('教室: $classroom'),
            Text('出席日: $formattedDate'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // ダイアログを閉じる
            child: Text("いいえ"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // ダイアログを閉じる
              await _checkAttendance(
                  context, classID, classType, currentUID); // 出席確認処理
            },
            child: Text("はい"),
          ),
        ],
      ),
    );
  }

  // 出席確認処理
  Future<void> _checkAttendance(BuildContext context, String classID,
      String classType, String uid) async {
    _showLoadingDialog(context); // 読み込み中ダイアログを表示
    bool isLoadingDialogOpen = true; // 読み込み中ダイアログが開いているかを記録
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('Class')
          .doc(classType)
          .collection('Subjects')
          .doc(classID)
          .get();

      if (!snapshot.exists) {
        throw Exception("授業データが見つかりません");
      }

      var stdMap = snapshot['STD'];
      if (stdMap is! Map<String, dynamic>) {
        throw Exception("STDデータの形式が正しくありません");
      }

      // 学生が出席対象に含まれるかを確認
      bool isPresent = stdMap.values.any((value) => value['UID'] == uid);
      if (isPresent) {
        await _recordAttendance(classID, classType, uid); // 出席記録処理
        if (isLoadingDialogOpen && Navigator.canPop(context)) {
          Navigator.pop(context); // 読み込み中ダイアログを閉じる
          isLoadingDialogOpen = false;
        }
        _showResultDialog(context, "出席成功", "あなたはこの授業に出席しました！");
      } else {
        if (isLoadingDialogOpen && Navigator.canPop(context)) {
          Navigator.pop(context);
          isLoadingDialogOpen = false;
        }
        _showResultDialog(context, "出席失敗", "この授業が無いため、出席出来ません。");
      }
    } catch (e) {
      if (isLoadingDialogOpen && Navigator.canPop(context)) {
        Navigator.pop(context); // 読み込み中ダイアログを閉じる
        isLoadingDialogOpen = false;
      }
      _showResultDialog(context, "エラー", "出席確認中にエラーが発生しました");
    } finally {
      if (isLoadingDialogOpen && Navigator.canPop(context)) {
        Navigator.pop(context); // 必ず読み込み中ダイアログを閉じる
      }
    }
  }

  // 出席記録処理
  Future<void> _recordAttendance(
      String classID, String classType, String uid) async {
    try {
      String date = DateTime.now().toIso8601String().split('T')[0];
      String? course;

      // IT と GAME を検索して UID に対応する COURSE を取得
      for (var courseType in ['IT', 'GAME']) {
        DocumentSnapshot userSnapshot = await _firestore
            .collection('Users/Students/$courseType')
            .doc(uid)
            .get();

        if (userSnapshot.exists) {
          course = courseType;
          break;
        }
      }

      if (course == null) {
        throw Exception("UID に対応する COURSE が見つかりません");
      }

      DocumentSnapshot userSnapshot =
          await _firestore.collection('Users/Students/$course').doc(uid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        // Realtime Database に出席データを追加
        DatabaseReference attendanceRef =
            _realtimeDatabase.ref('ATTENDANCE/$classType/$classID/$date/$uid');

        await attendanceRef.set({
          'UPDATE_TIME': DateTime.now().toIso8601String(),
          'METHOD': 'QRCODE',
          'NAME': userData['NAME'] ?? 'Unknown',
          'CLASS': userData['CLASS'] ?? 'Unknown',
          'ID': userData['ID'] ?? 'Unknown',
        });
      } else {
        throw Exception("学生データが見つかりません");
      }
    } catch (e) {
      // 出席記録エラーが発生した場合
    }
  }

  // 読み込み中ダイアログを表示
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  // 出席結果ダイアログを表示
  Future<void> _showResultDialog(
      BuildContext context, String title, String message) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("閉じる"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '学生出席ページへようこそ！',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B1FA2),
                      ),
                    ),
                    SizedBox(height: 100),

                    // 出席するボタン
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF7B1FA2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () => _navigateToQRScanner(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          foregroundColor: Colors.white, // Text color
                        ),
                        child: Text(
                          '出席する',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // 休暇届ボタン
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF7B1FA2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StudentLeaves()),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          foregroundColor: Colors.white, // Text color
                        ),
                        child: Text(
                          '休暇届',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('戻る'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        controller.stopCamera();
        Navigator.pop(context, scanData.code);
      }
    });
  }
}
