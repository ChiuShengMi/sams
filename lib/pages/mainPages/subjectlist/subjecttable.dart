import 'package:flutter/foundation.dart';
import 'package:sams/pages/mainPages/homepage_admin.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/lessontable.dart';
import 'package:flutter/material.dart';
import 'package:sams/pages/mainPages/subjectlist/subjecttable_new.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SubjectTable extends StatefulWidget {
  @override
  _SubjectTableState createState() => _SubjectTableState();
}

class _SubjectTableState extends State<SubjectTable> {
  TextEditingController searchController =
      TextEditingController(); // 検索バーのコントローラー
  List<Map<String, dynamic>> lessonList = []; // 全授業データ
  List<Map<String, dynamic>> filteredLessonList = []; // フィルタリングされた授業データ
  List<bool> isSelected = [true, true]; // トグルボタンの選択状態（IT, GAME）
  bool isLoading = true; // データ読み込み中フラグ

  @override
  void initState() {
    super.initState();
    _fetchInitialData(); // 初期データを取得
  }

  // 初期データを取得するメソッド
  Future<void> _fetchInitialData() async {
    setState(() {
      isLoading = true; // ローディングを開始
    });

    // ITとGAMEの授業データを取得
    lessonList = await fetchClasses(true, true);
    filterLessonList(); // デフォルトフィルタリング実行

    setState(() {
      isLoading = false; // ローディングを終了
    });
  }

  // 授業データを取得するメソッド
  Future<List<Map<String, dynamic>>> fetchClasses(
      bool isITSelected, bool isGameSelected) async {
    final FirebaseDatabase _realtimeDatabase =
        FirebaseDatabase.instance; // Realtime Databaseのインスタンス
    DatabaseReference dbRef = _realtimeDatabase.ref('CLASS'); // 授業データへの参照
    List<Map<String, dynamic>> results = []; // 結果リスト

    if (isITSelected) {
      results.addAll(await _fetchClassData(dbRef.child('IT')));
    }

    if (isGameSelected) {
      results.addAll(await _fetchClassData(dbRef.child('GAME')));
    }

    return results; // 取得結果を返す
  }

  Future<List<Map<String, dynamic>>> _fetchClassData(
      DatabaseReference path) async {
    DataSnapshot snapshot = await path.get();
    List<Map<String, dynamic>> result = [];

    if (snapshot.exists) {
      Map<dynamic, dynamic> classes = snapshot.value as Map<dynamic, dynamic>;
      classes.forEach((key, value) {
        result.add({
          'CLASS': value['CLASS'] ?? 'N/A', // 授業名
          'CLASSROOM': value['CLASSROOM'] ?? 'N/A', // 教室
          'COURSE': value['COURSE'] ?? 'N/A', // コース
          'DAY': value['DAY'] ?? 'N/A', // 授業曜日
          'PLACE': value['PLACE'] ?? 'N/A', // 号館
          'QR_CODE': value['QR_CODE'] ?? 'N/A', // QRコード
          'TEACHER_ID': value['TEACHER_ID'] ?? {}, // 教師ID
          'TIME': value['TIME'] ?? 'N/A', // 時間
          'classID': key, // 授業ID
          'classType': path.key, // 授業タイプ (IT または GAME)
        });
      });
    }
    return result;
  }

  void filterLessonList() {
    setState(() {
      List<String> selectedCategories = [];
      if (isSelected[0]) selectedCategories.add('IT');
      if (isSelected[1]) selectedCategories.add('GAME');

      String searchText = searchController.text.toLowerCase();

      filteredLessonList = lessonList
          .where((lesson) =>
              selectedCategories.contains(lesson['classType']) &&
              (lesson['CLASS'].toString().toLowerCase().contains(searchText)))
          .toList();

      print("Filtered Lesson List: ${filteredLessonList.length} items");
      filteredLessonList.forEach((lesson) => print(lesson));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(), // カスタムアプリバー
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // ローディング表示
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // タイトル行
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "授業リスト",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20), // 余白
                Divider(
                  color: Colors.grey, // ディバイダーの色
                  thickness: 1.5,
                  height: 15.0,
                ),
                SizedBox(height: 20),
                // フィルタリングと検索バー
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      text: "戻る", // 戻るボタン
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePageAdmin()),
                        );
                      },
                    ),
                    SizedBox(width: 10),
                    // 検索バー
                    Container(
                      width: 500,
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          filterLessonList(); // 檢索條件改變時重新篩選
                        },
                        decoration: InputDecoration(
                          hintText: '検索する内容を入力',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    // ITとGAMEを切り替えるトグルボタン（複数選択可能）
                    ToggleButtons(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('IT'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('GAME'),
                        ),
                      ],
                      isSelected: isSelected, // 現在の選択状態
                      onPressed: (index) {
                        setState(() {
                          isSelected[index] = !isSelected[index]; // 選択状態をトグル
                          filterLessonList(); // フィルタリングを実行
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    // 新しい授業作成ボタン
                    CustomButton(
                      text: "新しい授業作成",
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SubjecttableNew()),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // 授業リスト表示部分
                Expanded(
                  child: filteredLessonList.isEmpty
                      ? Center(child: Text('データが見つかりませんでした。'))
                      : Lessontable(
                          lessonData: filteredLessonList, // 傳遞過濾後的資料
                          course: isSelected[0] && isSelected[1]
                              ? 'All'
                              : isSelected[0]
                                  ? 'IT'
                                  : 'GAME',
                        ),
                ),
              ],
            ),
      bottomNavigationBar: BottomBar(), // カスタムボトムバー
    );
  }
}
