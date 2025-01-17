import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/pages/mainPages/homepage_teacher.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/appbar.dart';

class teacherAttendanceManagementPage extends StatefulWidget {
  @override
  _teacherAttendanceManagementPageState createState() =>
      _teacherAttendanceManagementPageState();
}

//↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ここは出席管理メイン画面↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
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
                  classSnapshot.child("CLASSROOM").value as String? ?? '不明',
              "courseDay": classSnapshot.child("DAY").value as String? ?? '不明',
              "coursePlace":
                  classSnapshot.child("PLACE").value as String? ?? '不明',
              "courseTime":
                  classSnapshot.child("TIME").value as String? ?? '不明',
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
                  classSnapshot.child("CLASSROOM").value as String? ?? '不明',
              "courseDay": classSnapshot.child("DAY").value as String? ?? '不明',
              "coursePlace":
                  classSnapshot.child("PLACE").value as String? ?? '不明',
              "courseTime":
                  classSnapshot.child("TIME").value as String? ?? '不明',
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
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "出席管理ページ\n授業リスト",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(width: 90),
                    CustomButton(
                      text: "戻る",
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePageTeacher(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: SingleChildScrollView(
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1),
                  },
                  children: [
                    // Header Row
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                      ),
                      children: [
                        TableCellHeader(text: "授業名"),
                        TableCellHeader(text: "教室"),
                        TableCellHeader(text: "曜日"),
                        TableCellHeader(text: "時間割"),
                        TableCellHeader(text: "授業詳細"),
                      ],
                    ),
                    // Dynamic Rows for Courses
                    if (courses != null && courses.isNotEmpty)
                      ...courses.map((course) {
                        return TableRow(
                          decoration: BoxDecoration(
                            color: courses.indexOf(course) % 2 == 0
                                ? Colors.grey[200]
                                : Colors.grey[100],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(course['courseName'] ?? '不明'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(course['courseRoom'] ?? '不明'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(course['courseDay'] ?? '不明'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text('${course['courseTime']}限目'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CourseDetailsPage(
                                        courseID: course['courseID'] ?? '',
                                        courseName: course['courseName'] ?? '',
                                        courseRoom: course['courseRoom'] ?? '',
                                        courseDay: course['courseDay'] ?? '',
                                        coursePlace:
                                            course['coursePlace'] ?? '',
                                        courseTime: course['courseTime'] ?? '',
                                      ),
                                    ),
                                  );
                                },
                                child: Text("詳細"),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomBar(),
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
        textAlign: TextAlign.start,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

//↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ここは出席管理メイン画面↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

//↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓授業リストが押されたらここにくる↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
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
              String status = value['STATUS'] ?? '不明';
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
              String status = value['STATUS'] ?? '不明';
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
      appBar: CustomAppBar(),
      body: Column(
        children: [
          // Header Container
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "授業詳細",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(width: 90),
                    CustomButton(
                      text: "戻る",
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                teacherAttendanceManagementPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Details Card
                  Card(
                    elevation: 7,
                    margin: EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade50, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.school,
                                  color: Colors.purple.shade700, size: 28),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '授業ID: ${widget.courseID}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '授業名: ${widget.courseName}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '教室: ${widget.courseRoom}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '曜日: ${widget.courseDay}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '場所: ${widget.coursePlace}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '時間: ${widget.courseTime}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
//'日付と状態`:
                  // Attendance Dates Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.event_note,
                            color: Colors.purple.shade700, size: 28),
                        SizedBox(width: 12),
                        Text(
                          '授業日',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Attendance List
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : attendanceDates.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: attendanceDates.length,
                              itemBuilder: (context, index) {
                                var attendance = attendanceDates[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  child: ListTile(
                                    title: Text(
                                      attendance['date'] ?? '不明',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AttendanceDetailPage(
                                            date: attendance['date'] ?? '不明',
                                            status:
                                                attendance['status'] ?? '不明',
                                            courseID: widget.courseID,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            )
                          : Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('授業がなかった'),
                            ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}

//↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑授業リストが押されたらここにくる↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

//↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓日付が押されたらここにくる↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
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
  Set<String> presentUIDs = {}; // 出席UID
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
        SnackBar(content: Text('FAILED: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          // Header section
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "出席記録詳細",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(width: 90),
                    CustomButton(
                      text: "戻る",
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Details and Attendance section
          Expanded(
            child: Column(
              children: [
                // Course Details Card
                Card(
                  elevation: 7,
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade50, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.school,
                                color: Colors.purple.shade700, size: 28),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '授業ID: ${widget.courseID}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '日付: ${widget.date}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '狀態: ${widget.status}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),

                // Attendance List Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(Icons.person_2,
                                color: Colors.purple.shade700, size: 28),
                            SizedBox(width: 12),
                            Text(
                              '学生リスト',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: isLoading
                            ? Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                itemCount: students.length,
                                itemBuilder: (context, index) {
                                  var student = students[index];
                                  final isPresent =
                                      presentUIDs.contains(student['uid']);
                                  return Card(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isPresent
                                            ? Colors.green.shade50
                                            : Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: isPresent
                                                ? Colors.green
                                                : Colors.red,
                                            child: Icon(
                                              isPresent
                                                  ? Icons.check
                                                  : Icons.close,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  student['name'] ?? '不明',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  '学籍番号: ${student['id'] ?? '学籍番号不明'}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            isPresent ? '出席' : '欠席',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isPresent
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
//↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑日付が押されたらここにくる↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
