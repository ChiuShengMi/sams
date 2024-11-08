import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FiresbaseAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 現在ログインしているユーザーの役割を取得するメソッド
  Future<String> getUserRole() async {
    try {
      // 現在ログインしているユーザーのUIDを取得
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print("未ログイン");
        return "未ログイン";
      }
      String uid = currentUser.uid;
      print("UID: $uid");

      // カテゴリ (IT, GAME) を定義
      List<String> categories = ['IT', 'GAME'];

      // 1. MANAGERS コレクションで検索
      for (String category in categories) {
        DocumentSnapshot managerDoc = await _db
            .collection('Users')
            .doc('Managers')
            .collection(category)
            .doc(uid)
            .get();
        if (managerDoc.exists) {
          print("役割: 管理者 ($category)");
          return "管理者";
        }
      }

      // 2. STUDENTS コレクションで検索
      for (String category in categories) {
        DocumentSnapshot studentDoc = await _db
            .collection('Users')
            .doc('Students')
            .collection(category)
            .doc(uid)
            .get();
        if (studentDoc.exists) {
          print("役割: 学生 ($category)");
          return "学生";
        }
      }

      // 3. TEACHERS コレクションで検索
      for (String category in categories) {
        DocumentSnapshot teacherDoc = await _db
            .collection('Users')
            .doc('Teachers')
            .collection(category)
            .doc(uid)
            .get();
        if (teacherDoc.exists) {
          print("役割: 教員 ($category)");
          return "教員";
        }
      }

      // 何も見つからなかった場合
      print("役割: 役割なし");
      return "役割なし";
    } catch (e) {
      print("エラー: $e");
      return "エラー";
    }
  }
}
