import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttendanceDetailPage extends StatefulWidget {
  final String classID;
  final String classType;
  final String courseName;

  AttendanceDetailPage({
    required this.classID,
    required this.classType,
    required this.courseName,
  });

  @override
  _AttendanceDetailPageState createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
  List<Map<String, String>> _attendanceDetails = [];

  @override
  void initState() {
    super.initState();
    _fetchAttendanceDetails();
  }

  // 出席詳細データを取得する
  Future<void> _fetchAttendanceDetails() async {
    try {
      List<Map<String, String>> detailsList = [];
      DocumentReference classDoc = FirebaseFirestore.instance
          .collection('Class')
          .doc(widget.classType)
          .collection('Subjects')
          .doc(widget.classID);

      DocumentSnapshot classSnapshot = await classDoc.get();

      if (classSnapshot.exists) {
        Map<String, dynamic> data =
            classSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey('ATTENDANCE')) {
          Map<String, dynamic> attendanceData =
              data['ATTENDANCE'] as Map<String, dynamic>;

          for (var dateKey in attendanceData.keys) {
            Map<String, dynamic> dateData =
                attendanceData[dateKey] as Map<String, dynamic>;

            if (dateData['STATUS'] == 'active') {
              String attendancePath =
                  'ATTENDANCE/${widget.classType}/${widget.classID}/$dateKey';
              DatabaseReference attendanceRef =
                  FirebaseDatabase.instance.ref(attendancePath);
              DataSnapshot attendanceSnapshot = await attendanceRef.get();

              String status = "欠席　✖"; // デフォルト値は欠席
              if (attendanceSnapshot.exists) {
                Map<dynamic, dynamic> studentData =
                    attendanceSnapshot.value as Map<dynamic, dynamic>;
                if (studentData
                    .containsKey(FirebaseAuth.instance.currentUser?.uid)) {
                  Map<dynamic, dynamic> studentRecord =
                      studentData[FirebaseAuth.instance.currentUser?.uid]
                          as Map<dynamic, dynamic>;

                  String? updateTime = studentRecord['UPDATE_TIME'];
                  if (updateTime != null && updateTime.isNotEmpty) {
                    DateTime updateDateTime = DateTime.parse(updateTime);
                    DateTime classStartTime =
                        _getClassStartTime(dateData['TIME'] ?? '1');
                    status = updateDateTime.isAfter(classStartTime)
                        ? "遅刻　△"
                        : "出席　〇"; // 遅刻は△、出席は〇
                  }
                }
              }
              detailsList.add({'date': dateKey, 'status': status});
            }
          }
        }
      }

      setState(() {
        _attendanceDetails = detailsList;
      });
    } catch (e) {
      print("出席詳細データ取得中にエラーが発生しました: $e");
    }
  }

  // コース開始時間を取得する
  DateTime _getClassStartTime(String time) {
    DateTime now = DateTime.now();
    switch (time) {
      case '1':
        return DateTime(now.year, now.month, now.day, 9, 15);
      case '2':
        return DateTime(now.year, now.month, now.day, 11, 0);
      case '3':
        return DateTime(now.year, now.month, now.day, 13, 30);
      case '4':
        return DateTime(now.year, now.month, now.day, 15, 15);
      case '5':
        return DateTime(now.year, now.month, now.day, 17, 0);
      default:
        throw Exception("無効なコース時間: $time");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.courseName} 詳細状況'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _attendanceDetails.length,
          itemBuilder: (context, index) {
            final detail = _attendanceDetails[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text('日付: ${detail['date']}'),
                trailing: Text(
                  detail['status']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: detail['status'] == "出席　〇"
                        ? Colors.green
                        : detail['status'] == "遅刻　△"
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
