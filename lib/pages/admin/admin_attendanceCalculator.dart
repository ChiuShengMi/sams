import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sams/pages/mainPages/homepage_admin.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/bottombar.dart';

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

  Future<Map<String, String>> _fetchAttendanceDetails() async {
    try {
      // 選択された日付のFirebase Realtime Databaseから出席状況を取得
      DatabaseReference attendanceRef = FirebaseDatabase.instance
          .ref('ATTENDANCE/$classType/$classID/$selectedDate');
      DataSnapshot snapshot = await attendanceRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        Map<String, String> attendanceDetails = {};

        for (var entry in data.entries) {
          String studentID = entry.key.toString(); // 学生ID
          Map<dynamic, dynamic>? studentData =
              entry.value as Map<dynamic, dynamic>?;

          if (studentData != null && studentData.containsKey("NAME")) {
            // NAMEフィールドが存在する場合は直接使用
            attendanceDetails[studentID] = studentData["NAME"];
          } else {
            // NAMEが存在しない場合、Firestoreから学生名を検索
            String studentName =
                await _fetchStudentNameFromFirestore(studentID);
            attendanceDetails[studentID] = studentName;
          }
        }
        return attendanceDetails;
      } else {
        return {}; // データがない場合は空のMapを返す
      }
    } catch (e) {
      print("出席データの取得に失敗しました: $e");
      return {}; // エラーが発生した場合は空のMapを返す
    }
  }

  Future<String> _fetchStudentNameFromFirestore(String studentID) async {
    try {
      DocumentSnapshot? studentSnapshot;
      // まずはIT学生を検索
      studentSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc('Students')
          .collection('IT')
          .doc(studentID)
          .get();

      // IT集合で見つからない場合、GAME学生を検索
      if (!studentSnapshot.exists) {
        studentSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc('Students')
            .collection('GAME')
            .doc(studentID)
            .get();
      }

      // Firestoreで学生データが見つかった場合
      if (studentSnapshot.exists) {
        final studentData = studentSnapshot.data() as Map<String, dynamic>;
        return studentData['NAME'] ?? "不明な学生";
      } else {
        return "不明な学生"; // データが見つからない場合は "不明な学生" を返す
      }
    } catch (e) {
      print("学生名の取得に失敗しました: $e");
      return "不明な学生"; // エラーが発生した場合は "不明な学生" を返す
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
                    offset: Offset(0, 3), // Shadow position
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
              child: FutureBuilder<Map<String, String>>(
                future: _fetchAttendanceDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    ); // Show a loading spinner
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "データの読み込みに失敗しました: ${snapshot.error}",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    );
                  }

                  final attendanceData = snapshot.data!;
                  if (attendanceData.isEmpty) {
                    return Center(
                      child: Text(
                        "出席データがありません",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  // Display Attendance List
                  return ListView.builder(
                    itemCount: attendanceData.length,
                    itemBuilder: (context, index) {
                      final studentName =
                          attendanceData.values.elementAt(index);

                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 4.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            studentName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "出席済み",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 18,
                          ),
                          onTap: () {
                            // Add action for tapping a student
                            print("Tapped on $studentName");
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
