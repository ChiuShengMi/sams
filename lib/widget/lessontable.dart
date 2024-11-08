import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/pages/mainPages/subjectlist/subjecttable.dart';
import 'package:sams/pages/mainPages/subjectlist/subjecttable_edit.dart';
import 'package:sams/widget/lessontable_edit.dart';

class Lessontable extends StatefulWidget {
  @override
  _LessonTableScreenState createState() => _LessonTableScreenState();
}

class _LessonTableScreenState extends State<Lessontable> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _cachedData; // キャッシュされたデータ
  bool _isLoading = true; // データ読み込み中かどうかのフラグ

  @override
  void initState() {
    super.initState();
    _loadData(); // データを読み込む
  }

  // Firebase Realtime Database からデータを取得するメソッド
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true; // ローディング状態を設定
    });

    try {
      final DatabaseEvent event = await _database.child('CLASS').once();
      if (event.snapshot.value != null) {
        setState(() {
          _cachedData = Map<String, dynamic>.from(
              event.snapshot.value as Map); // キャッシュデータを設定
          _isLoading = false; // ローディング終了
        });
      } else {
        setState(() {
          _cachedData = null; // データが空の場合
          _isLoading = false; // ローディング終了
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // ローディング終了
      });
      print('データ読み込みエラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // キャッシュをクリアしてホーム画面に戻る
        setState(() {
          _cachedData = null;
        });
        return true;
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                border: Border.all(color: Colors.black, width: 0.1),
              ),
              child: SingleChildScrollView(
                child: _buildTableContent(), // テーブルコンテンツを構築する
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _loadData, // 更新ボタン
          child: Icon(Icons.refresh),
          tooltip: 'データを更新',
        ),
      ),
    );
  }

  // テーブルのコンテンツを構築するメソッド
  Widget _buildTableContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator()); // ローディングスピナーを表示
    }

    if (_cachedData == null) {
      return Center(child: Text('データがありません')); // データがない場合のメッセージ
    }
    List<TableRow> tableRows = [
      TableRow(
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        children: const [
          TableCellHeader(text: '授業名'),
          TableCellHeader(text: "コース"),
          TableCellHeader(text: '教師'),
          TableCellHeader(text: '授業曜日'),
          TableCellHeader(text: '時間割'),
          TableCellHeader(text: 'QRコード'),
          TableCellHeader(text: '教室'),
          TableCellHeader(text: '号館'),
          TableCellHeader(text: '編集'),
        ],
      ),
    ];

    _cachedData!.forEach((categoryKey, subjects) {
      Map<String, dynamic> subjectMap = Map<String, dynamic>.from(subjects);
      subjectMap.forEach((subjectKey, subjectData) {
        final data = Map<String, dynamic>.from(subjectData);

        tableRows.add(
          TableRow(
            children: [
              buildTableCell(data['CLASS'] ?? 'N/A'),
              buildTableCell(categoryKey), // コース名を表示
              TableCell(
                child: FutureBuilder<DocumentSnapshot>(
                  future: _firestore
                      .collection('Class')
                      .doc(categoryKey)
                      .collection('Subjects')
                      .doc(subjectKey)
                      .get(),
                  builder: (context, firestoreSnapshot) {
                    if (firestoreSnapshot.hasError) {
                      return buildTableCell('エラー');
                    }
                    if (firestoreSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var firestoreData = firestoreSnapshot.data!.data()
                            as Map<String, dynamic>? ??
                        {};

                    String teacherDisplay = 'N/A';

                    if (data['TEACHER_ID'] is Map) {
                      Map<dynamic, dynamic> teacherMap =
                          data['TEACHER_ID'] as Map<dynamic, dynamic>;

                      teacherDisplay = teacherMap.values
                          .map((teacher) => teacher['NAME'].toString())
                          .join('\n'); // 用逗号分隔名字
                    }

                    return buildTableCell(teacherDisplay);
                  },
                ),
              ),
              buildTableCell(data['DAY'] ?? 'N/A'),
              buildTableCell(data['TIME'] ?? 'N/A'),
              buildTableCell(data['QR_CODE'] ?? 'N/A'),
              buildTableCell(data['CLASSROOM'] ?? 'N/A'),
              buildTableCell(data['PLACE'] ?? 'N/A'),
              buildEditCell(context, '編集', data, subjectKey, categoryKey),
            ],
          ),
        );
      });
    });

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(2),
        4: FlexColumnWidth(1),
        5: FlexColumnWidth(1),
        6: FlexColumnWidth(1),
        7: FlexColumnWidth(1),
      },
      children: tableRows,
    );
  }

  // テーブルのセルを構築するメソッド
  Widget buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // 編集セルを構築するメソッド
  Widget buildEditCell(BuildContext context, String text,
      Map<String, dynamic> lessonData, String id, String course) {
    return InkWell(
      onTap: () async {
        // 編集画面へ遷移し、戻り値で更新状態を取得
        bool? result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjecttableEdit(
              lessonData: lessonData,
              id: id,
              course: course,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}

class TableCellHeader extends StatelessWidget {
  final String text;

  const TableCellHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
