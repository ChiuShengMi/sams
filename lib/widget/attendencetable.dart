import 'package:flutter/material.dart';

class AttendanceTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            border: Border.all(color: Colors.black, width: 0.1),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(2),
                    4: FlexColumnWidth(1),
                    5: FlexColumnWidth(1),
                    6: FlexColumnWidth(1),
                    7: FlexColumnWidth(1),
                    8: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: Text('学籍番号',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: Text('学生名',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: Text('クラス',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: Text('授業名',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: Text('出席状態',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: Text('日付',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: Text('限目',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: Text('教員名',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: Text('登録方法',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...List.generate(10, (index) {
                      return buildRow(
                        '2223028${index}',
                        'クォン ドンヒョク',
                        'SE2A',
                        'データベース演習',
                        '出席',
                        '2024-05-15',
                        '3',
                        '細井 和馬',
                        'QRコートスキャン',
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TableRow buildRow(
    String studentId,
    String studentName,
    String classGroup,
    String subjectName,
    String attendanceStatus,
    String date,
    String classPeriod,
    String teacherName,
    String attendanceMethod,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(studentId,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(studentName,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(classGroup,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(subjectName,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(attendanceStatus,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(date,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(classPeriod,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(teacherName,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(attendanceMethod,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
