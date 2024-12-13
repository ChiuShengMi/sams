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
      Map<String, int> totalClasses = {
        'IT': 0,
        'GAME': 0,
      };
      Map<String, int> totalAttendance = {
        'IT': 0,
        'GAME': 0,
      };

      for (var course in _courses) {
        String classType = course['classType']!;
        String classID = course['classID']!;

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

            int totalClasses = 0;
            int totalAttendance = 0;

            for (var dateKey in attendanceData.keys) {
              Map<String, dynamic> dateData =
                  attendanceData[dateKey] as Map<String, dynamic>;

              if (dateData['STATUS'] == 'active') {
                totalClasses++;

                DatabaseReference attendanceRef = FirebaseDatabase.instance
                    .ref('ATTENDANCE/$classType/$classID/$dateKey');
                DataSnapshot attendanceSnapshot = await attendanceRef.get();

                if (attendanceSnapshot.exists) {
                  Map<dynamic, dynamic> studentData =
                      attendanceSnapshot.value as Map<dynamic, dynamic>;
                  totalAttendance += studentData.length;
                }
              }
            }

            double attendanceRate =
                totalClasses > 0 ? (totalAttendance / totalClasses) * 100 : 0.0;

            setState(() {
              _attendanceResults[classID] = {'attendanceRate': attendanceRate};
            });
          }
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

            // 課程列表
            Expanded(
              child: _courses.isEmpty
                  ? Center(child: Text("関連する授業が見つかりませんでした"))
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
                                '教室: ${course['classroom']}, 時間: ${course['day']} - ${course['time']}限'),
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
