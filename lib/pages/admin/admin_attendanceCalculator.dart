import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

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
  String _selectedCategory = "All"; // 選擇的類別
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  // 從 Firebase 獲取課程數據
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

      // 取得全部類別的全體出席率
      await _calculateTotalAttendanceRate();
    } catch (e) {
      print("課程數據獲取失敗: $e");
    }
  }

  // 根據課程名稱和類別篩選課程
  void _filterCourses() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCourses = _courses.where((course) {
        bool matchesSearch =
            course['courseName']!.toLowerCase().contains(query);
        bool matchesCategory = _selectedCategory == "All" ||
            course['classType'] == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  // 計算 IT 和 GAME 的全體出席率
  Future<void> _calculateTotalAttendanceRate() async {
    try {
      for (var course in _courses) {
        String classID = course['classID']!;
        String classType = course['classType']!;

        print("正在處理授業: 類型: $classType, ID: $classID");

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
            print("找到 $totalStudents 名學生的數據");
          }

          if (data.containsKey('ATTENDANCE')) {
            Map<String, dynamic> attendanceData =
                data['ATTENDANCE'] as Map<String, dynamic>;

            List<String> activeDates = []; // 保存有效的上課日期

            int totalClasses = 0; // 課堂總數
            int totalAttendance = 0; // 總出席數

            for (var dateKey in attendanceData.keys) {
              if (attendanceData[dateKey]['STATUS'] == 'active') {
                totalClasses++;
                activeDates.add(dateKey); // 添加有效日期
                print("找到有效的課程日期: $dateKey");

                DatabaseReference attendanceRef = FirebaseDatabase.instance
                    .ref('ATTENDANCE/$classType/$classID/$dateKey');

                DataSnapshot attendanceSnapshot = await attendanceRef.get();

                if (attendanceSnapshot.exists) {
                  print("找到日期 $dateKey 的出席數據: ${attendanceSnapshot.value}");
                  Map<dynamic, dynamic> studentData =
                      attendanceSnapshot.value as Map<dynamic, dynamic>;

                  totalAttendance += studentData.length; // 簡單累加出席人數
                } else {
                  print("日期 $dateKey 沒有找到任何出席數據");
                }
              }
            }

            double attendanceRate = totalClasses > 0
                ? (totalAttendance / (totalStudents * totalClasses)) * 100
                : 0.0;

            print("授業 $classID 的出席率: $attendanceRate%");
            setState(() {
              _attendanceResults[classID] = {
                'attendanceRate': attendanceRate,
                'activeDates': activeDates, // 保存上課日期
              };
            });
          } else {
            print("授業 $classID 沒有出席數據");
          }
        } else {
          print("授業 $classID 不存在");
        }
      }
    } catch (e) {
      print("授業出席率計算失敗: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('管理者出席率統計'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 搜索欄位
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '授業検索',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => _filterCourses(),
            ),
            SizedBox(height: 16.0),

            // 下拉選單
            DropdownButton<String>(
              value: _selectedCategory,
              items: [
                DropdownMenuItem(value: "All", child: Text("全て")),
                DropdownMenuItem(value: "IT", child: Text("IT")),
                DropdownMenuItem(value: "GAME", child: Text("GAME")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                  _filterCourses();
                });
              },
              isExpanded: true,
            ),
            SizedBox(height: 16.0),

            Expanded(
              child: _filteredCourses.isEmpty
                  ? Center(
                      child: Text("関連する授業が見つかりませんでした"),
                    )
                  : ListView.builder(
                      itemCount: _filteredCourses.length,
                      itemBuilder: (context, index) {
                        final course = _filteredCourses[index];
                        final stats = _attendanceResults[course['classID']];

                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(course['courseName'] ?? "不明な授業"),
                            subtitle: Text(
                              '教室: ${course['classroom'] ?? "不明"}, 時間: ${course['day'] ?? "不明"} - ${course['time'] ?? "不明"}限',
                            ),
                            trailing: Text(
                              stats != null &&
                                      stats.containsKey('attendanceRate')
                                  ? '${stats['attendanceRate']?.toStringAsFixed(1)}%'
                                  : '授業データはありません。',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
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

class CourseDetailsPage extends StatelessWidget {
  final String courseName;
  final String classID;
  final String classType;
  final List<String> activeDates;

  CourseDetailsPage({
    required this.courseName,
    required this.classID,
    required this.classType,
    required this.activeDates, // 傳入上課日期
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(courseName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Course ID: $classID'),
            Text('Class Type: $classType'),
            SizedBox(height: 16),
            Text(
              '授業日：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // 顯示上課日期，並且為每個日期添加點擊事件
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: activeDates.map<Widget>((date) {
                return GestureDetector(
                  onTap: () {
                    // 點擊日期後跳轉到出席詳情頁面
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AttendanceDetailsPage(
                          courseName: courseName,
                          classID: classID,
                          classType: classType,
                          selectedDate: date,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    ' $date',
                    style: TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                );
              }).toList(),
            ),
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

  AttendanceDetailsPage({
    required this.courseName,
    required this.classID,
    required this.classType,
    required this.selectedDate,
  });

  Future<Map<String, String>> _fetchAttendanceDetails() async {
    try {
      // 根據選定的日期從 Firebase Realtime Database 獲取出席狀況
      DatabaseReference attendanceRef = FirebaseDatabase.instance
          .ref('ATTENDANCE/$classType/$classID/$selectedDate');
      DataSnapshot snapshot = await attendanceRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        Map<String, String> attendanceDetails = {};

        for (var entry in data.entries) {
          String studentID = entry.key.toString(); // 學生 ID
          Map<dynamic, dynamic>? studentData =
              entry.value as Map<dynamic, dynamic>?;

          if (studentData != null && studentData.containsKey("NAME")) {
            // 如果 "NAME" 欄位存在，直接使用
            attendanceDetails[studentID] = studentData["NAME"];
          } else {
            // 如果 "NAME" 不存在，從 Firestore 查找學生名字
            String studentName =
                await _fetchStudentNameFromFirestore(studentID);
            attendanceDetails[studentID] = studentName;
          }
        }
        return attendanceDetails;
      } else {
        return {}; // 如果沒有數據，返回空 Map
      }
    } catch (e) {
      print("出席數據獲取失敗: $e");
      return {}; // 如果發生錯誤，返回空 Map
    }
  }

  Future<String> _fetchStudentNameFromFirestore(String studentID) async {
    try {
      DocumentSnapshot? studentSnapshot;
      // 首先查詢 IT 學生
      studentSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc('Students')
          .collection('IT')
          .doc(studentID)
          .get();

      // 如果 IT 集合中找不到，再查詢 GAME 學生
      if (!studentSnapshot.exists) {
        studentSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc('Students')
            .collection('GAME')
            .doc(studentID)
            .get();
      }

      // 如果在 Firestore 中找到了學生資料
      if (studentSnapshot.exists) {
        final studentData = studentSnapshot.data() as Map<String, dynamic>;
        return studentData['NAME'] ?? "未知學生";
      } else {
        return "未知學生"; // 如果找不到資料，返回 "未知學生"
      }
    } catch (e) {
      print("學生名字獲取失敗: $e");
      return "未知學生"; // 如果發生錯誤，返回 "未知學生"
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('出席狀態 - $selectedDate'),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _fetchAttendanceDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 載入中顯示圈圈
          }

          if (snapshot.hasError) {
            return Center(child: Text("數據加載失敗: ${snapshot.error}"));
          }

          final attendanceData = snapshot.data!;
          if (attendanceData.isEmpty) {
            return Center(child: Text("沒有找到出席數據。"));
          }

          // 顯示出席情況
          return ListView.builder(
            itemCount: attendanceData.length,
            itemBuilder: (context, index) {
              final studentName = attendanceData.values.elementAt(index);

              return ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: Text('學生名: $studentName'),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(),
    );
  }
}
