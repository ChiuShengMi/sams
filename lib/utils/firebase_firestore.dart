import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ーーーーーーー全てのユーザを取得 (コース別で)ーーーーーーーーー
  // 使用方法:
  // FirestoreService firestoreService = FirestoreService();
  // List<Map<String, dynamic>> users = await firestoreService.getAllUsers("IT");  //GAMEに変えてもよい
  // `users` には IT コースの学生情報が返されます
  Future<List<Map<String, dynamic>>> getAllUsers(String course) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("Users")
          .doc("Students")
          .collection(course)
          .get();

      List<Map<String, dynamic>> users = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>; 
        return {
          "uid": doc.id, // ユーザのID
          "name": data["NAME"] ?? "Unknown",
          "class": data["CLASS"] ?? "Unknown", 
        };
      }).toList();


      return users;
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }

  // ーーーーーーー学籍番号／社員番号／管理者番号でユーザ情報を取得するメソッドーーーーーーーーー
  // 使用方法:
  // Map<String, dynamic>? user = await getUserByID("IT", "12345");
  // `user` に該当するユーザ情報が返されます。該当しない場合は null が返されます
  Future<Map<String, dynamic>?> getUserByID(String course, String id) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("Users")
          .doc("Students")
          .collection(course)
          .where("ID", isEqualTo: id)
          .get();

      if (snapshot.docs.isEmpty) {
        snapshot = await _db
            .collection("Users")
            .doc("Teachers")
            .collection(course)
            .where("ID", isEqualTo: id)
            .get();
      }

      if (snapshot.docs.isEmpty) {
        snapshot = await _db
            .collection("Users")
            .doc("Managers")
            .collection(course)
            .where("ID", isEqualTo: id)
            .get();
      }

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>?;
        return {
          "uid": doc.id,
          "name": data?["NAME"] ?? "Unknown",
          "class": data?["CLASS"] ?? "Unknown",
          "job": data?["JOB"] ?? "Unknown",
          "mail": data?["MAIL"] ?? "Unknown",
          "tel": data?["TEL"] ?? "Unknown",
        };
      } else {
        print("この番号がなかった: $id");
        return null;
      }
    } catch (e) {
      print("エラーが発生しました: $e");
      return null;
    }
  }

  // ーーーーーーー教師データを取得するメソッドーーーーーーーーー
  // 使用方法:
  // List<String> teachers = await fetchTeachers(teacherMap);
  // `teachers` には教師名のリストが返されます
  Future<List<String>> fetchTeachers(Map<String, String> teacherMap) async {
    List<String> teacherNames = [];

    QuerySnapshot itTeachers = await _db
        .collection('Users')
        .doc('Teachers')
        .collection('IT')
        .get();

    for (var doc in itTeachers.docs) {
      teacherMap[doc['NAME']] = doc.id;
      teacherNames.add('IT - ${doc['NAME']}');
    }

    QuerySnapshot gameTeachers = await _db
        .collection('Users')
        .doc('Teachers')
        .collection('GAME')
        .get();

    for (var doc in gameTeachers.docs) {
      teacherMap[doc['NAME']] = doc.id;
      teacherNames.add('GAME - ${doc['NAME']}');
    }

    return teacherNames;
  }

  // ーーーーーーーユーザデータを追加するメソッドーーーーーーーーー
  // 使用方法:
  // await addUser("学生", "IT", uid, userData);
  // ユーザデータが指定した場所に保存されます
  Future<void> addUser(
      String job, String course, String uid, Map<String, dynamic> userData) async {
    try {
      await _db
          .collection('Users')
          .doc(job == '教師' ? 'Teachers' : job == '学生' ? 'Students' : 'Managers')
          .collection(course == 'IT' ? 'IT' : 'GAME')
          .doc(uid)
          .set(userData);

      print('ユーザが作成されました');
    } catch (e) {
      print('エラーが発生しました: $e');
    }
  }

  // ーーーーーーー学生データを取得するメソッドーーーーーーーーー
  // 使用方法:
  // List<Map<String, dynamic>> students = await fetchStudents(true, false);
  // `students` には指定したコースの学生データが返されます
  Future<List<Map<String, dynamic>>> fetchStudents(bool isITSelected, bool isGameSelected) async {
    List<Map<String, dynamic>> results = [];

    CollectionReference studentsITRef = _db.collection('Users/Students/IT');
    CollectionReference studentsGameRef = _db.collection('Users/Students/GAME');

    if (isITSelected) results.addAll(await _fetchStudentData(studentsITRef));
    if (isGameSelected) results.addAll(await _fetchStudentData(studentsGameRef));

    if (!isITSelected && !isGameSelected) {
      results.addAll(await _fetchStudentData(studentsITRef));
      results.addAll(await _fetchStudentData(studentsGameRef));
    }

    return results;
  }

  // 内部メソッド: 指定されたコレクションから学生データを取得する
  Future<List<Map<String, dynamic>>> _fetchStudentData(CollectionReference path) async {
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

  // ーーーーーーー選択された学生データをFirestoreに保存するメソッドーーーーーーーーー
  // 使用方法:
  // await saveSelectedStudents("IT", "classID123", "Math Class", studentData);
  // 学生データが授業情報に保存されます
  Future<void> saveSelectedStudents(String classType, String classID, String selectedClass,
      Map<String, dynamic> studentData) async {
    Map<String, dynamic> data = {
      'CLASS': selectedClass,
      'STD': studentData,
    };

    await _db
        .collection('Class')
        .doc(classType)
        .collection('Subjects')
        .doc(classID)
        .set(data, SetOptions(merge: true));
  }



    // 休暇申請のデータをFirestoreに保存するメソッド
  // 使用方法:
  // await firestoreService.saveLeaveRequest(course, userId, leaveId, leaveData);
  Future<void> saveLeaveRequest(
      String course, String userId, String leaveId, Map<String, dynamic> leaveData) async {
    try {
      await _db
          .collection('Leaves')
          .doc(course)
          .collection(userId)
          .doc(leaveId)
          .set(leaveData, SetOptions(merge: true));

      print('休暇申請が保存されました');
    } catch (e) {
      print('休暇申請の保存中にエラーが発生しました: $e');
    }
  }

  // 授業名を取得するメソッド
  // 使用方法:
  // String className = await firestoreService.getClassName(course, classId);
  Future<String?> getClassName(String course, String classId) async {
    try {
      DocumentSnapshot doc = await _db
          .collection('Class')
          .doc(course)
          .collection('Subjects')
          .doc(classId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>; 
        return data['CLASS'] as String?;
      } else {
        print('クラスIDが見つかりませんでした: $classId');
        return null;
      }
    } catch (e) {
      print('クラス名を取得中にエラーが発生しました: $e');
      return null;
    }
  }
}
