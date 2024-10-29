import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestPageLink extends StatefulWidget {
  @override
  _TestPageLinkState createState() => _TestPageLinkState();
}

class _TestPageLinkState extends State<TestPageLink> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Page Link'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ClassSelectionDialog(
                  onClassSelected: (selectedClass, classType, classID) {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StudentSelectionDialog(
                          selectedClass: selectedClass,
                          classType: classType,
                          classID: classID,
                        );
                      },
                    );
                  },
                );
              },
            );
          },
          child: Text('授業に学生を追加'),
        ),
      ),
    );
  }
}

// 授業検索のダイアログ
class ClassSelectionDialog extends StatefulWidget {
  final Function(String selectedClass, String classType, String classID) onClassSelected;

  ClassSelectionDialog({required this.onClassSelected});

  @override
  _ClassSelectionDialogState createState() => _ClassSelectionDialogState();
}

class _ClassSelectionDialogState extends State<ClassSelectionDialog> {
  TextEditingController classSearchController = TextEditingController();
  bool isITSelected = false;
  bool isGameSelected = false;
  List<Map<String, dynamic>> classList = [];
  List<Map<String, dynamic>> filteredClassList = [];

  @override
  void initState() {
    super.initState();
    fetchClasses();
    classSearchController.addListener(() => filterClassList());
  }

  Future<void> fetchClasses() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('CLASS');
    List<Map<String, dynamic>> results = [];

    if (isITSelected || isGameSelected) {
      if (isITSelected) results.addAll(await _fetchClassData(dbRef.child('IT')));
      if (isGameSelected) results.addAll(await _fetchClassData(dbRef.child('GAME')));
    } else {
      results.addAll(await _fetchClassData(dbRef.child('IT')));
      results.addAll(await _fetchClassData(dbRef.child('GAME')));
    }

    setState(() {
      classList = results;
      filterClassList();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchClassData(DatabaseReference path) async {
    DataSnapshot snapshot = await path.get();
    List<Map<String, dynamic>> result = [];

    if (snapshot.exists) {
      Map<dynamic, dynamic> classes = snapshot.value as Map<dynamic, dynamic>;
      classes.forEach((key, value) {
        result.add({
          'className': value['CLASS'],
          'day': value['DAY'],
          'time': value['TIME'],
          'classID': key,
          'classType': path.key,
        });
      });
    }

    return result;
  }

  void filterClassList() {
    String searchText = classSearchController.text.toLowerCase();
    setState(() {
      filteredClassList = classList.where((classData) {
        final className = classData['className'].toLowerCase();
        final day = classData['day'].toLowerCase();
        return className.contains(searchText) || day.contains(searchText);
      }).toList();
    });
  }

  @override
  void dispose() {
    classSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: classSearchController,
              decoration: InputDecoration(
                labelText: '授業検索',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ToggleButtons(
              isSelected: [isITSelected, isGameSelected],
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
              onPressed: (int index) {
                setState(() {
                  if (index == 0) {
                    isITSelected = !isITSelected;
                  } else if (index == 1) {
                    isGameSelected = !isGameSelected;
                  }
                  fetchClasses();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredClassList.length,
              itemBuilder: (context, index) {
                final classData = filteredClassList[index];
                return ListTile(
                  title: Text(
                      '${classData['className']} - ${classData['day']} - ${classData['time']}'),
                  onTap: () {
                    widget.onClassSelected(
                      classData['className'],
                      classData['classType'],
                      classData['classID'],
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

// 学生検索のダイアログ
class StudentSelectionDialog extends StatefulWidget {
  final String selectedClass;
  final String classType;
  final String classID;

  StudentSelectionDialog({
    required this.selectedClass,
    required this.classType,
    required this.classID,
  });

  @override
  _StudentSelectionDialogState createState() => _StudentSelectionDialogState();
}

class _StudentSelectionDialogState extends State<StudentSelectionDialog> {
  TextEditingController studentSearchController = TextEditingController();
  bool isITSelected = false;
  bool isGameSelected = false;
  List<Map<String, dynamic>> studentList = [];
  List<Map<String, dynamic>> filteredStudentList = [];
  Set<String> selectedStudentIds = {};

  @override
  void initState() {
    super.initState();
    fetchStudents();
    studentSearchController.addListener(() => filterStudentList());
  }

  Future<void> fetchStudents() async {
    List<Map<String, dynamic>> results = [];

    CollectionReference studentsITRef = FirebaseFirestore.instance.collection('Users/Students/IT');
    CollectionReference studentsGameRef = FirebaseFirestore.instance.collection('Users/Students/GAME');

    if (isITSelected || isGameSelected) {
      if (isITSelected) results.addAll(await _fetchStudentData(studentsITRef));
      if (isGameSelected) results.addAll(await _fetchStudentData(studentsGameRef));
    } else {
      results.addAll(await _fetchStudentData(studentsITRef));
      results.addAll(await _fetchStudentData(studentsGameRef));
    }

    setState(() {
      studentList = results;
      filterStudentList();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchStudentData(CollectionReference path) async {
    QuerySnapshot snapshot = await path.get();
    List<Map<String, dynamic>> result = [];

    if (snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        result.add({
          'id': data['ID'],
          'name': data['NAME'],
          'class': data['CLASS'],
          'uid': doc.id,
        });
      }
    }

    return result;
  }

  void filterStudentList() {
    String searchText = studentSearchController.text.toLowerCase();
    setState(() {
      filteredStudentList = studentList.where((studentData) {
        final studentName = (studentData['name'] ?? '').toString().toLowerCase();
        final studentClass = (studentData['class'] ?? '').toString().toLowerCase();
        final studentID = (studentData['id'] ?? '').toString();
        return selectedStudentIds.contains(studentData['uid']) ||
            studentName.contains(searchText) ||
            studentClass.contains(searchText) ||
            studentID.contains(searchText);
      }).toList();

      for (var student in studentList) {
        if (selectedStudentIds.contains(student['uid']) &&
            !filteredStudentList.contains(student)) {
          filteredStudentList.add(student);
        }
      }
    });
  }

  Future<void> saveSelectedStudents() async {
    String classType = widget.classType; // IT  OR GAME
    String classID = widget.classID;     // 授業ID

   
    Map<String, dynamic> studentData = {
      for (var i = 0; i < filteredStudentList.length; i++)
        if (selectedStudentIds.contains(filteredStudentList[i]['uid']))
          i.toString(): {
            'UID': filteredStudentList[i]['uid'],
            'NAME': filteredStudentList[i]['name'],
            'ID': filteredStudentList[i]['id'],
          },
    };

    Map<String, dynamic> data = {
      'CLASS': widget.selectedClass, // 授業名
      'STD': studentData,
    };

    // SAVE PATH
    await FirebaseFirestore.instance
        .collection('Class')              // メインコレクション
        .doc(classType)                   // IT or GAME ドキュメント
        .collection('Subjects')           // 授業をまとめるサブコレクション
        .doc(classID)                     // 授業IDに対応するドキュメント
        .set(data, SetOptions(merge: true));

    
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    studentSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ClassSelectionDialog(
                          onClassSelected: (selectedClass, classType, classID) {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return StudentSelectionDialog(
                                  selectedClass: selectedClass,
                                  classType: classType,
                                  classID: classID,
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                Text(
                  '選択中の授業: ${widget.selectedClass}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedStudentIds.clear();
                        });
                      },
                      child: Text('全体取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          for (var student in filteredStudentList) {
                            selectedStudentIds.add(student['uid'].toString());
                          }
                        });
                      },
                      child: Text('全体追加'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: studentSearchController,
              decoration: InputDecoration(
                labelText: '学生検索',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ToggleButtons(
              isSelected: [isITSelected, isGameSelected],
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
              onPressed: (int index) {
                setState(() {
                  if (index == 0) {
                    isITSelected = !isITSelected;
                  } else if (index == 1) {
                    isGameSelected = !isGameSelected;
                  }
                  fetchStudents();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredStudentList.length,
              itemBuilder: (context, index) {
                final studentData = filteredStudentList[index];
                final studentUID = studentData['uid'].toString();
                return ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${studentData['id']} - ${studentData['name']} - ${studentData['class']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Checkbox(
                        value: selectedStudentIds.contains(studentUID),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedStudentIds.add(studentUID);
                            } else {
                              selectedStudentIds.remove(studentUID);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: saveSelectedStudents,
              child: Text('確定'),
            ),
          ),
        ],
      ),
    );
  }
}
