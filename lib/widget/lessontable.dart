import 'package:flutter/material.dart';
import 'package:sams/pages/admin/subjectlist/subjecttable_edit.dart';

class Lessontable extends StatefulWidget {
  final String course; // コース (IT, GAME, All)
  final List<Map<String, dynamic>> lessonData; // 授業データ

  const Lessontable({
    Key? key,
    required this.course,
    required this.lessonData,
  }) : super(key: key);

  @override
  _LessonTableScreenState createState() => _LessonTableScreenState();
}

class _LessonTableScreenState extends State<Lessontable> {
  @override
  void initState() {
    super.initState();
    print("Received lessonData: ${widget.lessonData}");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
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
              child: Column(
                children: [
                  // Fixed Header
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                    ),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(2),
                        3: FlexColumnWidth(1),
                        4: FlexColumnWidth(1),
                        5: FlexColumnWidth(2),
                        6: FlexColumnWidth(1),
                        7: FlexColumnWidth(1),
                      },
                      children: const [
                        TableRow(
                          children: [
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
                      ],
                    ),
                  ),
                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildTableContent(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // テーブルの内容を生成するメソッド
  Widget _buildTableContent() {
    if (widget.lessonData.isEmpty) {
      return Center(child: Text('データが見つかりませんでした。'));
    }

    List<TableRow> tableRows = [];

    // 基於 widget.lessonData 生成資料行
    for (final data in widget.lessonData) {
      tableRows.add(
        TableRow(
          children: [
            buildTableCell(data['CLASS'] ?? 'N/A'),
            buildTableCell(data['classType'] ?? 'N/A'), // 現在のコース (ITまたはGAME)
            buildTableCell(
              (data['TEACHER_ID'] as Map<dynamic, dynamic>?)
                      ?.values
                      .map((teacher) => teacher['NAME'] ?? 'N/A')
                      .join('\n') ??
                  'N/A', // 教師情報
            ),
            buildTableCell(data['DAY'] ?? 'N/A'), // 授業曜日
            buildTableCell(data['TIME'] ?? 'N/A'), // 時間割
            buildTableCell(data['QR_CODE'] ?? 'N/A'), // QRコード
            buildTableCell(data['CLASSROOM'] ?? 'N/A'), // 教室
            buildTableCell(data['PLACE'] ?? 'N/A'), // 号館
            buildEditCell(
                context, '編集', data, data['classID'], data['classType']),
          ],
        ),
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
        5: FlexColumnWidth(2),
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
        // 編集画面へ遷移
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
        if (result == true) {
          // 必要に応じてデータを更新
          setState(() {});
        }
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

// テーブルヘッダーのセルウィジェット
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
