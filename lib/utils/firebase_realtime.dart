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

    // ーーーーーーー授業データを取得するメソッド（複数カテゴリ対応）ーーーーーーーーー
  // 使用方法:
  // `List<Map<String, dynamic>> classes = await fetchClasses(true, false);`
  // `isITSelected` と `isGameSelected` のフラグに応じて、ITまたはGAMEの授業データを取得します。
  Future<List<Map<String, dynamic>>> fetchClasses(bool isITSelected, bool isGameSelected) async {
    DatabaseReference dbRef = _realtimeDatabase.ref('CLASS');
    List<Map<String, dynamic>> results = []; // 授業データを格納するリスト

    // ITの授業データを取得
    if (isITSelected) {
      results.addAll(await _fetchClassData(dbRef.child('IT')));
    }

    // GAMEの授業データを取得
    if (isGameSelected) {
      results.addAll(await _fetchClassData(dbRef.child('GAME')));
    }

    // 両方未選択の場合、すべてのカテゴリを取得
    if (!isITSelected && !isGameSelected) {
      results.addAll(await _fetchClassData(dbRef.child('IT')));
      results.addAll(await _fetchClassData(dbRef.child('GAME')));
    }

    return results; // 授業データを返す
  }

  // 内部使用専用: 指定されたパスから授業データを取得するメソッド
  Future<List<Map<String, dynamic>>> _fetchClassData(DatabaseReference path) async {
    DataSnapshot snapshot = await path.get();
    List<Map<String, dynamic>> result = []; // 結果を格納するリスト

    if (snapshot.exists) {
      Map<dynamic, dynamic> classes = snapshot.value as Map<dynamic, dynamic>;
      classes.forEach((key, value) {
        result.add({
          'className': value['CLASS'] ?? 'Unknown',      // 授業名
          'day': value['DAY'] ?? 'Unknown',             // 授業日
          'time': value['TIME'] ?? 'Unknown',           // 授業時間
          'classroom': value['CLASSROOM'] ?? 'Unknown', // 教室
          'place': value['PLACE'] ?? 'Unknown',         // 場所
          'classID': key,                               // 授業ID
          'classType': path.key,                        // 授業タイプ（ITまたはGAME）
        });
      });
    }
    return result; // 授業データを返す
  }


  
}
