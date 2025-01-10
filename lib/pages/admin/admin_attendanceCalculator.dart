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
  String _selectedCategory = "All"; // 選択されたカテゴリー
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
        bool matchesCategory = _selectedCategory == "All" ||
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
      appBar: AppBar(
        title: Text('管理者出席率統計'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 検索フィールド
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

            // ドロップダウンメニュー
            DropdownButton<String>(
              value: _selectedCategory,
              items: [
                DropdownMenuItem(value: "All", child: Text("すべて")),
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
                                  : '授業データがありません',
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
    required this.activeDates, // 授業日を渡す
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
            // 授業日を表示し、各日付にクリックイベントを追加
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: activeDates.map<Widget>((date) {
                return GestureDetector(
                  onTap: () {
                    // 日付をクリックすると出席詳細ページに遷移
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
      appBar: AppBar(
        title: Text('出席状態 - $selectedDate'),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _fetchAttendanceDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator()); // ローディング中はサークルを表示
          }

          if (snapshot.hasError) {
            return Center(child: Text("データの読み込みに失敗しました: ${snapshot.error}"));
          }

          final attendanceData = snapshot.data!;
          if (attendanceData.isEmpty) {
            return Center(child: Text("出席データがなかった"));
          }

          // 出席情況
          return ListView.builder(
            itemCount: attendanceData.length,
            itemBuilder: (context, index) {
              final studentName = attendanceData.values.elementAt(index);

              return ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: Text('学生名: $studentName'),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(),
    );
  }
}
