import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sams/pages/student/attendance_std_detail.dart';

class AttendanceRatePage extends StatefulWidget {
  @override
  _AttendanceRatePageState createState() => _AttendanceRatePageState();
}

class _AttendanceRatePageState extends State<AttendanceRatePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _courses = [];
  List<Map<String, String>> _filteredCourses = [];
  Map<String, Map<String, dynamic>> _attendanceResults = {};
  String? _currentUID;

  @override
  void initState() {
    super.initState();
    _getCurrentUserUID();
  }

  // 現在ログイン中のユーザーのUIDを取得する
  Future<void> _getCurrentUserUID() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUID = user.uid;
      });
      await _fetchCourses(); // コースデータを取得
      await _calculateAttendanceRate(); // 出席率を計算
    }
  }

  // Firebase Realtime Databaseからコースデータを取得
  Future<void> _fetchCourses() async {
    List<Map<String, String>> coursesList = [];
    try {
      DatabaseReference reference = FirebaseDatabase.instance.ref('CLASS');
      DataSnapshot snapshot = await reference.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> coursesData =
            snapshot.value as Map<dynamic, dynamic>;

        for (var classType in coursesData.keys) {
          var classData = coursesData[classType];

          for (var classID in classData.keys) {
            var courseInfo = classData[classID];
            var className = courseInfo['CLASS'];
            var classroom = courseInfo['CLASSROOM'];
            var day = courseInfo['DAY'];
            var place = courseInfo['PLACE'];
            var time = courseInfo['TIME'];

            // 学生がこのコースに登録されているかどうかを確認
            bool isStudentAttended =
                await _checkStudentAttendance(classID, classType);

            // 学生が登録されていればコースを追加
            if (isStudentAttended) {
              coursesList.add({
                'courseName': className,
                'classID': classID,
                'classType': classType,
                'status': '出席',
                'classroom': classroom,
                'day': day,
                'place': place,
                'time': time,
              });
            }
          }
        }
      }

      setState(() {
        _courses = coursesList; // コースデータを更新
        _filteredCourses = _courses; // フィルタされたコースも更新
      });
    } catch (e) {
      print("コースデータ取得中にエラーが発生しました: $e");
    }
  }

  // 学生が特定のコースに登録されているか確認する
  Future<bool> _checkStudentAttendance(String classID, String classType) async {
    try {
      DocumentReference classDoc = FirebaseFirestore.instance
          .collection('Class')
          .doc(classType)
          .collection('Subjects')
          .doc(classID);

      DocumentSnapshot snapshot = await classDoc.get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('STD')) {
          Map<String, dynamic> stdData = data['STD'] as Map<String, dynamic>;

          for (var key in stdData.keys) {
            var studentData = stdData[key] as Map<String, dynamic>;
            var studentUID = studentData['UID'];

            if (studentUID == _currentUID) {
              return true; // 登録されている
            }
          }
        }
      }
      return false; // 登録されていない
    } catch (e) {
      print("出席確認中にエラーが発生しました: $e");
      return false;
    }
  }

// 出席率を計算
  Future<void> _calculateAttendanceRate() async {
    try {
      for (var course in _courses) {
        String classType = course['classType']!;
        String classID = course['classID']!;
        String classTime = course['time']!;

        DocumentReference classDoc = FirebaseFirestore.instance
            .collection('Class')
            .doc(classType)
            .collection('Subjects')
            .doc(classID);

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
                    'ATTENDANCE/$classType/$classID/$dateKey';
                DatabaseReference attendanceRef =
                    FirebaseDatabase.instance.ref(attendancePath);
                DataSnapshot attendanceSnapshot = await attendanceRef.get();

                bool isAbsent = true;
                bool isLate = false;
                bool isPresent = false;

                if (attendanceSnapshot.exists) {
                  Map<dynamic, dynamic> studentData =
                      attendanceSnapshot.value as Map<dynamic, dynamic>;

                  if (studentData.containsKey(_currentUID)) {
                    Map<dynamic, dynamic> studentRecord =
                        studentData[_currentUID] as Map<dynamic, dynamic>;

                    if (studentRecord.containsKey('APPROVE') &&
                        (studentRecord['APPROVE'] == 1 ||
                            studentRecord['APPROVE'] == '1')) {
                      isPresent = true;
                      isAbsent = false;
                    }

                    if (!isPresent &&
                        studentRecord.containsKey('UPDATE_TIME')) {
                      String updateTime = studentRecord['UPDATE_TIME'];
                      DateTime updateDateTime = DateTime.parse(updateTime);
                      DateTime classStartTime = _getClassStartTime(classTime);

                      print(
                          'UPDATE_TIME: $updateTime (classID: $classID, dateKey: $dateKey, UID: $_currentUID)');

                      isLate = updateDateTime.isAfter(classStartTime);
                      isAbsent = false;
                    }
                  }
                }

                if (!_attendanceResults.containsKey(classID)) {
                  _attendanceResults[classID] = {
                    'total': 0,
                    'absent': 0,
                    'late': 0,
                  };
                }
                _attendanceResults[classID]!['total'] += 1;
                if (isAbsent) {
                  _attendanceResults[classID]!['absent'] += 1;
                } else if (isLate) {
                  _attendanceResults[classID]!['late'] += 1;
                }
              }
            }
          } else {
            _attendanceResults[classID] = {
              'status': '授業データありません',
            };
          }
        } else {
          _attendanceResults[classID] = {
            'status': '授業データありません',
          };
        }
      }

      // 出席率を計算
      _attendanceResults.forEach((classID, stats) {
        if (stats.containsKey('total')) {
          int lateCount = stats['late'];
          int lateToAbsent = lateCount ~/ 3;
          stats['absent'] += lateToAbsent;
          stats['attendanceRate'] =
              ((stats['total'] - stats['absent']) / stats['total']) * 100;
        }
      });

      setState(() {}); // UIを更新
    } catch (e) {
      print("出席率計算中にエラーが発生しました: $e");
    }
  }

  // コースの開始時間を取得
  DateTime _getClassStartTime(String classTime) {
    DateTime now = DateTime.now();
    switch (classTime) {
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
        throw Exception("無効なコース時間: $classTime");
    }
  }

  // 検索されたコースをフィルタリング
  void _filterCourses(String query) {
    setState(() {
      _filteredCourses = _courses
          .where((course) =>
              course['courseName']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('出席率'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _filterCourses,
              decoration: InputDecoration(
                labelText: '検索コース',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: _currentUID == null
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _filteredCourses.length,
                      itemBuilder: (context, index) {
                        final course = _filteredCourses[index];
                        final stats = _attendanceResults[course['classID']];
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(course['courseName']!),
                            subtitle: Text(
                                '教室: ${course['classroom']}, 時間: ${course['day']} - ${course['time']}限目'),
                            trailing: Text(
                              stats != null
                                  ? stats['status'] == '授業データありません'
                                      ? '授業データありません'
                                      : '${stats['attendanceRate']?.toStringAsFixed(1)}%'
                                  : '計算中...',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: stats != null &&
                                        stats['status'] == '授業データありません'
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                            ),
                            onTap:
                                stats != null && stats['status'] != '授業データありません'
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AttendanceDetailPage(
                                              classID: course['classID']!,
                                              classType: course['classType']!,
                                              courseName: course['courseName']!,
                                            ),
                                          ),
                                        );
                                      }
                                    : null, // 状態が"授業データありません"の場合、何もしない
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
