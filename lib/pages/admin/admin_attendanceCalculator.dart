import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sams/pages/mainPages/homepage_admin.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/utils/log.dart';

class AdminAttendanceCalculator extends StatefulWidget {
  @override
  _AdminAttendanceCalculatorState createState() =>
      _AdminAttendanceCalculatorState();
}

class _AdminAttendanceCalculatorState extends State<AdminAttendanceCalculator> {
  List<Map<String, String>> _courses = [];
  List<Map<String, String>> _filteredCourses = [];
  Map<String, Map<String, dynamic>> _attendanceResults = {};
  Map<String, double> _totalAttendanceRates = {
    'IT': 0.0,
    'GAME': 0.0,
  };
  List<bool> isSelected = [true, false, false]; // Default selection: all
  String _selectedCategory = "すべて"; // 選択されたカテゴリー
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  // Firebaseからコースデータを取得
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
            var time = courseInfo['TIME'];

            coursesList.add({
              'courseName': className,
              'classID': classID,
              'classType': classType,
              'classroom': classroom,
              'day': day,
              'time': time,
            });
          }
        }
      }

      setState(() {
        _courses = coursesList;
        _filteredCourses = _courses;
      });

      // 全カテゴリーの全体出席率を取得
      await _calculateTotalAttendanceRate();
    } catch (e) {
      print("コースデータの取得に失敗しました: $e");
    }
  }

  // コース名とカテゴリーでコースをフィルタリング
  void _filterCourses() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCourses = _courses.where((course) {
        bool matchesSearch =
            course['courseName']!.toLowerCase().contains(query);
        bool matchesCategory = _selectedCategory == "すべて" ||
            course['classType'] == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  // ITとGAMEの全体出席率を計算
  Future<void> _calculateTotalAttendanceRate() async {
    try {
      for (var course in _courses) {
        String classID = course['classID']!;
        String classType = course['classType']!;

        print("処理中の授業: タイプ: $classType, ID: $classID");

        DocumentReference classDoc = FirebaseFirestore.instance
            .collection('Class')
            .doc(classType)
            .collection('Subjects')
            .doc(classID);

        DocumentSnapshot classSnapshot = await classDoc.get();
        if (classSnapshot.exists) {
          Map<String, dynamic> data =
              classSnapshot.data() as Map<String, dynamic>;

          int totalStudents = 0;
          if (data.containsKey('STD')) {
            Map<String, dynamic> stdData = data['STD'] as Map<String, dynamic>;
            totalStudents = stdData.length;
            print("$totalStudents 名の学生データを見つけました");
          }

          if (data.containsKey('ATTENDANCE')) {
            Map<String, dynamic> attendanceData =
                data['ATTENDANCE'] as Map<String, dynamic>;

            List<String> activeDates = []; // 有効な授業日を保存

            int totalClasses = 0; // 総授業数
            int totalAttendance = 0; // 総出席数

            for (var dateKey in attendanceData.keys) {
              if (attendanceData[dateKey]['STATUS'] == 'active') {
                totalClasses++;
                activeDates.add(dateKey); // 有効な日付を追加
                print("有効な授業日を見つけました: $dateKey");

                DatabaseReference attendanceRef = FirebaseDatabase.instance
                    .ref('ATTENDANCE/$classType/$classID/$dateKey');

                DataSnapshot attendanceSnapshot = await attendanceRef.get();

                if (attendanceSnapshot.exists) {
                  print(
                      "日付 $dateKey の出席データを見つけました: ${attendanceSnapshot.value}");
                  Map<dynamic, dynamic> studentData =
                      attendanceSnapshot.value as Map<dynamic, dynamic>;

                  totalAttendance += studentData.length; // 出席人数を単純に加算
                } else {
                  print("日付 $dateKey の出席データが見つかりません");
                }
              }
            }

            double attendanceRate = totalClasses > 0
                ? (totalAttendance / (totalStudents * totalClasses)) * 100
                : 0.0;

            print("授業 $classID の出席率: $attendanceRate%");
            setState(() {
              _attendanceResults[classID] = {
                'attendanceRate': attendanceRate,
                'activeDates': activeDates, // 授業日を保存
              };
            });
          } else {
            print("授業 $classID の出席データがありません");
          }
        } else {
          print("授業 $classID が存在しません");
        }
      }
    } catch (e) {
      print("授業出席率の計算に失敗しました: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                  // タイトル行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "管理者出席率統計",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  // フィルタリングと検索バー
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 検索バー
                      Container(
                        width: 500,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            _filterCourses(); // 檢索條件改變時重新篩選
                          },
                          decoration: InputDecoration(
                            hintText: '検索する内容を入力',
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                      SizedBox(width: 30),
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
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('すべて'),
                          ),
                        ],
                        isSelected: isSelected, // Current selection state
                        onPressed: (int index) {
                          setState(() {
                            // Update selection state
                            for (int i = 0; i < isSelected.length; i++) {
                              isSelected[i] = i == index;
                            }

                            // Update selected category based on index
                            if (index == 0) _selectedCategory = "IT";
                            if (index == 1) _selectedCategory = "GAME";
                            if (index == 2) _selectedCategory = "すべて";

                            // Call your filter method
                            _filterCourses();
                          });
                        },
                      ),

                      SizedBox(
                        width: 90,
                      ),

                      CustomButton(
                        text: "戻る",
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePageAdmin()),
                          );
                        },
                      ),
                      SizedBox(width: 20),
                    ],
                  ),
                ],
              ),
            ),
            // 検索フィールド

            SizedBox(height: 16.0),

            Expanded(
              child: _filteredCourses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "関連する授業が見つかりませんでした",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _filteredCourses.length,
                      itemBuilder: (context, index) {
                        final course = _filteredCourses[index];
                        final stats = _attendanceResults[course['classID']];
                        final attendanceRate = stats?['attendanceRate'];

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CourseDetailsPage(
                                      courseName: course['courseName'] ?? "",
                                      classID: course['classID'] ?? "",
                                      classType: course['classType'] ?? "",
                                      activeDates:
                                          _attendanceResults[course['classID']]
                                                  ?['activeDates'] ??
                                              [],
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              course['courseName'] ?? "不明な授業",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          attendanceRate != null
                                              ? Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getAttendanceColor(
                                                        attendanceRate),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Text(
                                                    '${attendanceRate.toStringAsFixed(1)}%',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                )
                                              : Text(
                                                  '授業データがありません',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            size: 16,
                                            color: Colors.purple.shade600,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            course['classroom'] ?? "不明",
                                            style: TextStyle(
                                              color: Colors.purple.shade700,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Colors.purple.shade600,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '${course['day'] ?? "不明"} - ${course['time'] ?? "不明"}限',
                                            style: TextStyle(
                                              color: Colors.purple.shade700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}

Color _getAttendanceColor(double rate) {
  if (rate >= 90) {
    return Colors.green.shade500;
  } else if (rate >= 80) {
    return Colors.blue.shade500;
  } else if (rate >= 70) {
    return Colors.orange.shade500;
  } else {
    return Colors.red.shade500;
  }
}

class CourseDetailsPage extends StatelessWidget {
  final String courseName;
  final String classID;
  final String classType;
  final List<String> activeDates;

  CourseDetailsPage({
    required this.courseName,
    required this.classID,
    required this.classType,
    required this.activeDates, // 授業日を渡す
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        courseName,
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
                              builder: (context) => AdminAttendanceCalculator(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Information Card
                  Card(
                    elevation: 2,
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
                                      'Course ID: $classID',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Class Type: $classType',
                                      style: TextStyle(
                                        fontSize: 20,
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

                  // Class Dates Section
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

                  // Dates List
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: activeDates.length,
                      itemBuilder: (context, index) {
                        final date = activeDates[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AttendanceDetailsPage(
                                      courseName: courseName,
                                      classID: classID,
                                      classType: classType,
                                      selectedDate: date,
                                      activeDates: activeDates,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.purple.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.calendar_today,
                                          color: Colors.purple.shade700,
                                          size: 24,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          date,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18,
                                        color: Colors.purple.shade300,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AttendanceDetailsPage extends StatelessWidget {
  final String courseName;
  final String classID;
  final String classType;
  final String selectedDate;
  final List<String> activeDates;

  AttendanceDetailsPage({
    required this.courseName,
    required this.classID,
    required this.classType,
    required this.selectedDate,
    required this.activeDates,
  });

  Future<List<Map<String, String>>> _fetchAttendanceData() async {
    try {
      List<String> presentUIDs = [];
      FirebaseDatabase database = FirebaseDatabase.instance;

      List<String> departments = ['IT', 'GAME'];
      for (var department in departments) {
        final attendanceRef = database
            .ref()
            .child('ATTENDANCE')
            .child(department)
            .child(classID)
            .child(selectedDate);
        final attendanceSnapshot = await attendanceRef.get();

        if (attendanceSnapshot.exists) {
          final attendanceData =
              attendanceSnapshot.value as Map<dynamic, dynamic>;
          presentUIDs.addAll(attendanceData.keys.cast<String>());
        }
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      List<Map<String, String>> studentList = [];

      final itDoc = await firestore
          .collection("Class")
          .doc("IT")
          .collection("Subjects")
          .doc(classID)
          .get();

      if (itDoc.exists) {
        Map<String, dynamic>? data = itDoc.data();
        _addStudentsFromData(data, studentList, presentUIDs);
      }

      final gameDoc = await firestore
          .collection("Class")
          .doc("GAME")
          .collection("Subjects")
          .doc(classID)
          .get();

      if (gameDoc.exists) {
        Map<String, dynamic>? data = gameDoc.data();
        _addStudentsFromData(data, studentList, presentUIDs);
      }

      return studentList;
    } catch (e) {
      print('出席データの取得に失敗しました: $e');
      return [];
    }
  }

  void _addStudentsFromData(
    Map<String, dynamic>? data,
    List<Map<String, String>> studentList,
    List<String> presentUIDs,
  ) {
    if (data != null && data.containsKey('STD')) {
      Map<String, dynamic>? stdData = data['STD'];
      if (stdData != null) {
        stdData.forEach((key, student) {
          if (student is Map<String, dynamic>) {
            String uid = student['UID']?.toString() ?? 'UID不明';
            bool isPresent = presentUIDs.contains(uid);
            studentList.add({
              'name': student['NAME'] ?? '不明',
              'id': student['ID']?.toString() ?? 'ID不明',
              'uid': uid,
              'status': isPresent ? '出席' : '未出席',
            });
          }
        });
      }
    }
  }

  Future<void> _updateAttendance(
      String uid, String status, String studentID, String studentName) async {
    FirebaseDatabase database = FirebaseDatabase.instance;

    List<String> departments = ['IT', 'GAME'];

    String updateTime = DateTime.now().toIso8601String();

    try {
      for (String department in departments) {
        final attendanceRef = database
            .ref()
            .child('ATTENDANCE')
            .child(department)
            .child(classID)
            .child(selectedDate);

        if (status == '出席') {
          final studentData = {
            'ID': studentID,
            'NAME': studentName,
            'METHOD': 'ADMINISTRATION',
            'UPDATE_TIME': updateTime,
            'APPROVE': 4,
          };
          await attendanceRef.update({uid: studentData});
        } else if (status == '欠席') {
          await attendanceRef.child(uid).remove();
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('ユーザーがログインしていません');
        final managerUid = user.uid;

        DocumentSnapshot? managerSnapshot;
        managerSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc('Managers')
            .collection('IT')
            .doc(managerUid)
            .get();

        if (!managerSnapshot.exists) {
          managerSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc('Managers')
              .collection('GAME')
              .doc(managerUid)
              .get();
        }

        if (!managerSnapshot.exists) {
          throw Exception('管理者情報が見つかりません');
        }

        final managerData = managerSnapshot.data() as Map<String, dynamic>;
        final approver = {
          'UID': managerUid,
          'ID': managerData['ID'].toString(),
          'NAME': managerData['NAME'],
        };

        await Utils.logMessage(
          '${managerData['NAME']}-${managerData['ID']}が ${studentName}-${selectedDate} の出席状態を変動しました。',
        );
      }
    } catch (e) {
      print('出席データの更新に失敗しました: $e');
    }
  }

  void _showAttendanceDialog(
      BuildContext context, Map<String, String> student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('出席状態を変わりますか'),
          content: Text('学生: ${student['name']}\nID: ${student['id']}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 取消
              },
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                await _updateAttendance(
                  student['uid']!,
                  '出席',
                  student['id']!,
                  student['name']!,
                );
                Navigator.of(context).pop();
              },
              child: Text('出席'),
            ),
            TextButton(
              onPressed: () async {
                await _updateAttendance(
                  student['uid']!,
                  '欠席',
                  student['id']!,
                  student['name']!,
                );
                Navigator.of(context).pop(); // 欠席
              },
              child: Text('欠席'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Title Section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '出席状態 - $selectedDate',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
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
                              builder: (context) => CourseDetailsPage(
                                courseName: courseName,
                                classID: classID,
                                classType: classType,
                                activeDates: activeDates,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            // Attendance List Section
            Expanded(
              child: FutureBuilder<List<Map<String, String>>>(
                future: _fetchAttendanceData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "データの読み込みに失敗しました: ${snapshot.error}",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    );
                  }

                  final students = snapshot.data ?? [];
                  if (students.isEmpty) {
                    return Center(
                      child: Text(
                        "出席データがありません",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final isPresent = student['status'] == '出席';

                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 4.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isPresent
                                ? Colors.green
                                : Colors.red, // 綠色表示出席，紅色表示未出席
                            child: Icon(
                              isPresent ? Icons.check : Icons.close,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            student['name'] ?? '不明',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "ID: ${student['id']}, UID: ${student['uid']}",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          onTap: () {
                            _showAttendanceDialog(context, student); // 顯示對話框
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
