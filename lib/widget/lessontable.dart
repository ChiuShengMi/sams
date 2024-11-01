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
  Map<String, dynamic>? _cachedData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final DatabaseEvent event = await _database.child('CLASS').once();
      if (event.snapshot.value != null) {
        setState(() {
          _cachedData = Map<String, dynamic>.from(event.snapshot.value as Map);
          _isLoading = false;
        });
      } else {
        setState(() {
          _cachedData = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // キャッシュをクリアしてからホーム画面に戻る
        setState(() {
          _cachedData = null;
        });
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('授業リスト'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // キャッシュをクリアしてからホーム画面に戻る
              setState(() {
                _cachedData = null;
              });
              Navigator.of(context).pop();
            },
          ),
        ),
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
                child: _buildTableContent(),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _loadData,
          child: Icon(Icons.refresh),
          tooltip: 'データを更新',
        ),
      ),
    );
  }

  Widget _buildTableContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_cachedData == null) {
      return Center(child: Text('データがありません'));
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
              buildTableCell(categoryKey), // Display course name
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
                      return buildTableCell('Error');
                    }
                    if (firestoreSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var firestoreData = firestoreSnapshot.data!.data()
                            as Map<String, dynamic>? ??
                        {};

                    String teacherDisplay =
                        (firestoreData['TEACHER_ID'] is List)
                            ? (firestoreData['TEACHER_ID'] as List).join(', ')
                            : firestoreData['TEACHER_ID']?.toString() ??
                                data['TEACHER_ID']?.toString() ??
                                'N/A';

                    return buildTableCell(teacherDisplay);
                  },
                ),
              ),
              buildTableCell(data['DAY'] ?? 'N/A'),
              buildTableCell(data['TIME'] ?? 'N/A'),
              buildTableCell(data['QR_CODE'] ?? 'N/A'),
              buildTableCell(data['CLASSROOM'] ?? 'N/A'),
              buildTableCell(data['PLACE'] ?? 'N/A'),
              buildEditCell(context, '編集', data),
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

  Widget buildEditCell(
      BuildContext context, String text, Map<String, dynamic> lessonData) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjecttableEdit(
                lessonData: lessonData), // Use 'lessonData' here
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
