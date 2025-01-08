import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Utils {
  /// Firestore にログを保存する共通関数
  static Future<void> logMessage(String msg) async {
    DateTime now = DateTime.now();
    String datePath =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    String time =
        '${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';

    // ユニークなドキュメント名
    String documentName = datePath + "-" + time;

    try {
      // Firestore にログを保存
      await FirebaseFirestore.instance
          .collection("Log") // 主集合
          .doc(documentName) // ユニークなドキュメント名
          .set({
        'MSG': msg,
      });
    } catch (e) {
      // エラーハンドリング（必要に応じてログ出力などを追加）
      print("Error saving log: $e");
    }
  }

  static Future<Map<String, String>> getUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('ユーザーがログインしていません');
    final uid = user.uid;

    DocumentSnapshot? managerSnapshot;
    managerSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc('Managers')
        .collection('IT')
        .doc(uid)
        .get();

    if (!managerSnapshot.exists) {
      managerSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc('Managers')
          .collection('GAME')
          .doc(uid)
          .get();
    }

    if (!managerSnapshot.exists) {
      throw Exception('ユーザー情報が見つかりません');
    }

    final managerData = managerSnapshot.data() as Map<String, dynamic>;
    final userId = managerData['ID'];
    final userName = managerData['NAME'];

    return {
      'userId': userId,
      'userName': userName,
    };
  }
}




/////////////使用方法///////////
// import 'package:sams/utils/log.dart'; 　　　// utils.dart ファイルをインポート

// await Utils.logMessage(
//         'ここにLOGメッセージを入れる',
//       );
