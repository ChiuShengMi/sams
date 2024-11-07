import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/pages/mainPages/subjectlist/subjecttable.dart';
import 'package:sams/pages/mainPages/subjectlist/subjecttable_edit.dart';

import 'package:sams/widget/lessontable.dart';

class LessontableEdit extends StatelessWidget {
  final Map<String, dynamic> lessonData;

  LessontableEdit({required this.lessonData}); // Use 'lessonData' here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("授業名: ${lessonData['CLASS'] ?? 'N/A'}"),
            Text("教師: ${lessonData['TEACHER_ID'] ?? 'N/A'}"),
            Text("授業曜日: ${lessonData['DAY'] ?? 'N/A'}"),
            Text("時間割: ${lessonData['TIME'] ?? 'N/A'}"),
            Text("QRコード: ${lessonData['QR_CODE'] ?? 'N/A'}"),
            Text("教室: ${lessonData['CLASSROOM'] ?? 'N/A'}"),
            Text("号館: ${lessonData['PLACE'] ?? 'N/A'}"),
          ],
        ),
      ),
    );
  }
}
