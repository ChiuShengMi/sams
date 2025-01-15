import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class teacherAttendanceManagementPage extends StatefulWidget {
  @override
  _teacherAttendanceManagementPageState createState() =>
      _teacherAttendanceManagementPageState();
}

class _teacherAttendanceManagementPageState
    extends State<teacherAttendanceManagementPage> {
  List<Map<String, String>> courses = [];

  @override
  void initState() {
    super.initState();
    fetchCourseByUID();
  }

  Future<void> fetchCourseByUID() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;

      DatabaseReference ref = FirebaseDatabase.instance.ref("CLASS");
      final itSnapshot = await ref.child("IT").get();
      final gameSnapshot = await ref.child("GAME").get();

      List<Map<String, String>> foundCourses = [];

      if (itSnapshot.exists) {
        itSnapshot.children.forEach((classSnapshot) {
          var teacherID = classSnapshot.child("TEACHER_ID").value as Map?;
          if (teacherID != null && teacherID.containsKey(uid)) {
            foundCourses.add({
              "courseID": classSnapshot.key!,
              "courseName": classSnapshot.child("CLASS").value as String,
              "courseRoom":
                  classSnapshot.child("CLASSROOM").value as String? ?? '無教室',
              "courseDay": classSnapshot.child("DAY").value as String? ?? '無日期',
              "coursePlace":
                  classSnapshot.child("PLACE").value as String? ?? '無地點',
              "courseTime":
                  classSnapshot.child("TIME").value as String? ?? '無時間',
            });
          }
        });
      }

      if (gameSnapshot.exists) {
        gameSnapshot.children.forEach((classSnapshot) {
          var teacherID = classSnapshot.child("TEACHER_ID").value as Map?;
          if (teacherID != null && teacherID.containsKey(uid)) {
            foundCourses.add({
              "courseID": classSnapshot.key!,
              "courseName": classSnapshot.child("CLASS").value as String,
              "courseRoom":
                  classSnapshot.child("CLASSROOM").value as String? ?? '無教室',
              "courseDay": classSnapshot.child("DAY").value as String? ?? '無日期',
              "coursePlace":
                  classSnapshot.child("PLACE").value as String? ?? '無地點',
              "courseTime":
                  classSnapshot.child("TIME").value as String? ?? '無時間',
            });
          }
        });
      }

      setState(() {
        courses = foundCourses;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('出席管理ページ'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '授業リスト',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                var course = courses[index];
                return ListTile(
                  title: Text(course['courseName'] ?? '無課程名稱'),
                  subtitle: Text(
                      '教室: ${course['coursePlace']}${course['courseRoom']}ー${course['courseDay']}ー${course['courseTime']}限目'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailsPage(
                          courseID: course['courseID']!,
                          courseName: course['courseName']!,
                          courseRoom: course['courseRoom']!,
                          courseDay: course['courseDay']!,
                          coursePlace: course['coursePlace']!,
                          courseTime: course['courseTime']!,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CourseDetailsPage extends StatefulWidget {
  final String courseID;
  final String courseName;
  final String courseRoom;
  final String courseDay;
  final String coursePlace;
  final String courseTime;

  CourseDetailsPage({
    required this.courseID,
    required this.courseName,
    required this.courseRoom,
    required this.courseDay,
    required this.coursePlace,
    required this.courseTime,
  });

  @override
  _CourseDetailsPageState createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  List<Map<String, String>> attendanceDates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAttendanceDates();
  }

  Future<void> fetchAttendanceDates() async {
    try {
      setState(() {
        isLoading = true;
      });

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      List<Map<String, String>> datesWithStatus = [];

      final itDoc = await firestore
          .collection("Class")
          .doc("IT")
          .collection("Subjects")
          .doc(widget.courseID)
          .get();

      final gameDoc = await firestore
          .collection("Class")
          .doc("GAME")
          .collection("Subjects")
          .doc(widget.courseID)
          .get();

      if (itDoc.exists) {
        Map<String, dynamic>? attendanceData =
            itDoc.data()?['ATTENDANCE'] as Map<String, dynamic>?;

        if (attendanceData != null) {
          attendanceData.forEach((date, value) {
            if (value is Map<String, dynamic>) {
              String status = value['STATUS'] ?? '未設定';
              datesWithStatus
                  .add({"date": date, "status": status, "department": "IT"});
            }
          });
        }
      }

      if (gameDoc.exists) {
        Map<String, dynamic>? attendanceData =
            gameDoc.data()?['ATTENDANCE'] as Map<String, dynamic>?;

        if (attendanceData != null) {
          attendanceData.forEach((date, value) {
            if (value is Map<String, dynamic>) {
              String status = value['STATUS'] ?? '未設定';
              datesWithStatus
                  .add({"date": date, "status": status, "department": "GAME"});
            }
          });
        }
      }

      if (datesWithStatus.isEmpty) {
      } else {}

      datesWithStatus.sort((a, b) => b["date"]!.compareTo(a["date"]!));

      setState(() {
        attendanceDates = datesWithStatus;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error fetching attendance dates: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('loading failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('授業詳細'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('課程ID: ${widget.courseID}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('課程名稱: ${widget.courseName}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('教室: ${widget.courseRoom}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('日期: ${widget.courseDay}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('地點: ${widget.coursePlace}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('時間: ${widget.courseTime}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('日付と状態`:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: attendanceDates.isNotEmpty
                        ? ListView.builder(
                            itemCount: attendanceDates.length,
                            itemBuilder: (context, index) {
                              var attendance = attendanceDates[index];
                              return Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                child: ListTile(
                                  leading: Icon(Icons.calendar_today),
                                  title: Text(
                                    attendance['date'] ?? '無日期',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    '状態: ${attendance['status'] ?? '未設定'}',
                                    style: TextStyle(
                                      color: attendance['status'] == 'active'
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                  onTap: () {
                                    // 點擊後導航到新的頁面，並傳遞日期、狀態和課程ID
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AttendanceDetailPage(
                                          date: attendance['date'] ?? '無日期',
                                          status: attendance['status'] ?? '未設定',
                                          courseID: widget.courseID,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          )
                        : Text('未找到上課日期'),
                  ),
          ],
        ),
      ),
    );
  }
}

class AttendanceDetailPage extends StatefulWidget {
  final String courseID;
  final String date;
  final String status;

  const AttendanceDetailPage({
    Key? key,
    required this.courseID,
    required this.date,
    required this.status,
  }) : super(key: key);

  @override
  _AttendanceDetailPageState createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
  bool isLoading = true;
  List<Map<String, String>> students = [];
  Set<String> presentUIDs = {}; // 出席的UID集合
  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    try {
      setState(() {
        isLoading = true;
      });

      //  Firebase Realtime Databaseから出席資料取り出す
      FirebaseDatabase database = FirebaseDatabase.instance;
      List<String> departments = ['IT', 'GAME'];

      for (var department in departments) {
        final attendanceRef = database
            .ref()
            .child('ATTENDANCE')
            .child(department)
            .child(widget.courseID)
            .child(widget.date);

        final attendanceSnapshot = await attendanceRef.get();
        if (attendanceSnapshot.exists) {
          final attendanceData =
              attendanceSnapshot.value as Map<dynamic, dynamic>;
          presentUIDs.addAll(attendanceData.keys.cast<String>());
        }
      }

      // Step 2: Firestoreから学生資料調べる
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      List<Map<String, String>> studentList = [];

      // IT
      final itDoc = await firestore
          .collection("Class")
          .doc("IT")
          .collection("Subjects")
          .doc(widget.courseID)
          .get();

      // GAME
      final gameDoc = await firestore
          .collection("Class")
          .doc("GAME")
          .collection("Subjects")
          .doc(widget.courseID)
          .get();

      if (itDoc.exists) {
        Map<String, dynamic>? attendanceData = itDoc.data();
        if (attendanceData != null) {
          Map<String, dynamic>? stdData = attendanceData['STD'];
          if (stdData != null) {
            stdData.forEach((key, student) {
              if (student is Map<String, dynamic>) {
                String name = student['NAME'] ?? '不明';
                String id = student['ID']?.toString() ?? 'ID不明';
                String uid = student['UID']?.toString() ?? 'UID不明';
                studentList.add({'name': name, 'id': id, 'uid': uid});
              }
            });
          }
        }
      }

      if (gameDoc.exists) {
        Map<String, dynamic>? attendanceData = gameDoc.data();
        if (attendanceData != null) {
          Map<String, dynamic>? stdData = attendanceData['STD'];
          if (stdData != null) {
            stdData.forEach((key, student) {
              if (student is Map<String, dynamic>) {
                String name = student['NAME'] ?? '不明';
                String id = student['ID']?.toString() ?? 'ID不明';
                String uid = student['UID']?.toString() ?? 'UID不明';
                studentList.add({'name': name, 'id': id, 'uid': uid});
              }
            });
          }
        }
      }

      setState(() {
        students = studentList;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error fetching data: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('資料加載失敗: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('出席記錄詳細'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('課程ID: ${widget.courseID}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('日期: ${widget.date}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('狀態: ${widget.status}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('學生列表: ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        var student = students[index];
                        final isPresent = presentUIDs.contains(student['uid']);
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(student['name'] ?? '不明'),
                            subtitle: Text(
                              '学籍番号: ${student['id'] ?? '学籍番号不明'} - UID: ${student['uid'] ?? 'UID不明'}',
                              style: TextStyle(fontSize: 16),
                            ),
                            trailing: Text(
                              isPresent ? '出席' : '欠席',
                              style: TextStyle(
                                color: isPresent ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
