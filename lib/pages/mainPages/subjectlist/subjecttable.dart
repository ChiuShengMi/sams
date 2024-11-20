import 'package:flutter/foundation.dart';
import 'package:sams/pages/mainPages/homepage_admin.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/lessontable.dart';
import 'package:flutter/material.dart';
import 'package:sams/pages/mainPages/subjectlist/subjecttable_new.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SubjectTable extends StatefulWidget {
  @override
  _SubjectTableState createState() => _SubjectTableState();
}

class _SubjectTableState extends State<SubjectTable> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> lessonList = [];
  List<Map<String, dynamic>> filteredLessonList = [];
  String? selectedCategory; // null means "all categories"
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      isLoading = true;
    });

    lessonList = await fetchClasses(true, true); // Fetch both IT and GAME
    print('Fetched Lessons: ${lessonList.length}'); // Debug: Check the count
    filterLessonList();

    setState(() {
      isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> fetchClasses(
      bool isITSelected, bool isGameSelected) async {
    final FirebaseDatabase _realtimeDatabase = FirebaseDatabase.instance;
    DatabaseReference dbRef = _realtimeDatabase.ref('CLASS');
    List<Map<String, dynamic>> results = [];

    if (isITSelected) {
      results.addAll(await _fetchClassData(dbRef.child('IT')));
    }

    if (isGameSelected) {
      results.addAll(await _fetchClassData(dbRef.child('GAME')));
    }

    return results;
  }

  Future<List<Map<String, dynamic>>> _fetchClassData(
      DatabaseReference path) async {
    DataSnapshot snapshot = await path.get();
    List<Map<String, dynamic>> result = [];

    if (snapshot.exists) {
      Map<dynamic, dynamic> classes = snapshot.value as Map<dynamic, dynamic>;
      classes.forEach((key, value) {
        result.add({
          'subject': value['SUBJECT'] ?? 'Unknown',
          'day': value['DAY'] ?? 'Unknown',
          'time': value['TIME'] ?? 'Unknown',
          'classroom': value['CLASSROOM'] ?? 'Unknown',
          'place': value['PLACE'] ?? 'Unknown',
          'classID': key,
          'QRコード': value['QRコード'] ?? '124356',
          'classType': path.key,
          'TEACHER_ID': value['TEACHER_ID'] ?? {},
        });
      });
    }
    return result;
  }

  void filterLessonList() {
    setState(() {
      if (selectedCategory == null || selectedCategory == 'All') {
        // すべて授業リス表示
        filteredLessonList = List.from(lessonList);
      } else {
        // Filter by selected category
        filteredLessonList = lessonList
            .where((lesson) => lesson['classType'] == selectedCategory)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "授業リスト",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Divider(
                  color: Colors.grey,
                  thickness: 1.5,
                  height: 15.0,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                    SizedBox(width: 10),
                    Container(
                      width: 1000,
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: '検索する内容を入力',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
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
                      ],
                      isSelected: [
                        selectedCategory == 'IT',
                        selectedCategory == 'GAME',
                      ],
                      onPressed: (index) {
                        setState(() {
                          if (index == 0) {
                            selectedCategory = 'IT';
                          } else if (index == 1) {
                            selectedCategory = 'GAME';
                          } else {
                            selectedCategory = null; // Reset to "All"
                          }
                          filterLessonList();
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    CustomButton(
                      text: "新しい授業作成",
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SubjecttableNew()),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: filteredLessonList.isEmpty
                      ? Center(child: Text('データが見つかりませんでした。'))
                      : Column(
                          children: [
                            Text(
                                'Filtered Lessons: ${filteredLessonList.length}'),
                            Expanded(
                              child: Lessontable(
                                lessonData: filteredLessonList,
                                course: selectedCategory ?? 'All',
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
