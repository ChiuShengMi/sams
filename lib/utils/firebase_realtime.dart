import 'package:firebase_database/firebase_database.dart';

class RealtimeDatabaseService {
  final FirebaseDatabase _realtimeDatabase = FirebaseDatabase.instance;

  // ーーーーーーー授業IDを自動生成するメソッドーーーーーーーーー
  // 使用方法:
  // `String classId = await generateClassId("IT");`
  // `classId` は自動生成された授業IDが返されます (例: "IT_subject_001")
  Future<String> generateClassId(String course) async {
    DatabaseReference dbRef = _realtimeDatabase.ref();
    DatabaseEvent event = await dbRef.child('CLASS/$course').once();
    DataSnapshot snapshot = event.snapshot;
    int nextId = 1;

    if (snapshot.value != null) {
      Map<dynamic, dynamic> classes = snapshot.value as Map<dynamic, dynamic>;
      List<String> ids = classes.keys.map((key) => key.toString()).toList();
      ids.sort();
      String lastId = ids.last;
      nextId = int.parse(lastId.split('_').last) + 1;
    }

    return '${course.toUpperCase()}_subject_${nextId.toString().padLeft(3, '0')}';
  }

  // ーーーーーーー授業データを保存するメソッドーーーーーーーーー
  // 使用方法:
  // `await saveClassData("IT", "IT_subject_001", classData);`
  // 授業データが指定した場所に保存されます
  Future<void> saveClassData(String course, String classId, Map<String, dynamic> classData) async {
    try {
      DatabaseReference dbRef = _realtimeDatabase.ref();
      await dbRef.child('CLASS/$course/$classId').set(classData);
      print('データが保存されました');
    } catch (e) {
      print('エラーが発生しました: $e');
    }
  }

  // ーーーーーーー授業データを取得するメソッドーーーーーーーーー
  // 使用方法:
  // `List<Map<String, dynamic>> classes = await fetchClasses(true, false);`
  // `classes` は取得した授業データのリストが返されます
  Future<List<Map<String, dynamic>>> fetchClasses(bool isITSelected, bool isGameSelected) async {
    DatabaseReference dbRef = _realtimeDatabase.ref('CLASS');
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

    return results;
  }

  // 内部使用専用: 指定されたパスから授業データを取得するメソッド
  Future<List<Map<String, dynamic>>> _fetchClassData(DatabaseReference path) async {
    DataSnapshot snapshot = await path.get();
    List<Map<String, dynamic>> result = [];

    if (snapshot.exists) {
      Map<dynamic, dynamic> classes = snapshot.value as Map<dynamic, dynamic>;
      classes.forEach((key, value) {
        result.add({
          'className': value['CLASS'] ?? 'Unknown',
          'day': value['DAY'] ?? 'Unknown',
          'time': value['TIME'] ?? 'Unknown',
          'classID': key,
          'classType': path.key,
        });
      });
    }
    return result;
  }
}
