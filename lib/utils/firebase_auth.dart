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

      // 1. MANAGERS コレクションで検索
      DocumentSnapshot managerDoc =
          await _db.collection('Users').doc('Managers').collection('IT').doc(uid).get();
      if (managerDoc.exists) {
        print("役割: 管理者");
        return "管理者";
      }

      // 2. STUDENTS コレクションで検索
      DocumentSnapshot studentDoc =
          await _db.collection('Users').doc('Students').collection('IT').doc(uid).get();
      if (studentDoc.exists) {
        print("役割: 学生");
        return "学生";
      }

      // 3. TEACHERS コレクションで検索
      DocumentSnapshot teacherDoc =
          await _db.collection('Users').doc('Teachers').collection('IT').doc(uid).get();
      if (teacherDoc.exists) {
        print("役割: 教師");
        return "教師";
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
