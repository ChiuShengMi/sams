import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/custom_input_container.dart';
;
import 'package:sams/widget/searchbar/custom_input.dart';
import 'package:sams/widget/bottombar.dart';

class SubjecttableNew extends StatefulWidget {
  //final FirestoreService _firestoreService = FirestoreService();
  @override
  _SubjecttableNewState createState() => _SubjecttableNewState();
}

class _SubjecttableNewState extends State<SubjecttableNew> {
  final TextEditingController classController = TextEditingController();
  final TextEditingController classroomController = TextEditingController();
  String? selectedCourse;
  String? selectedPlace;
  String? selectedDay;
  String? selectedTime;
  List<String?> selectedTeacherIds = [null];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<String> teacherNames = [];
  Map<String, String> teacherMap = {};

  // Fetch the teacher list from Firestore and update the teacher names and map
  @override
  void initState() {
    super.initState();
    fetchTeacherList();
  }

  Future<void> fetchTeacherList() async {
    try {
      final snapshot = await firestore.collection('teachers').get();
      if (snapshot.docs.isEmpty) {
        print('教師が見つかりません');
      }
      setState(() {
        teacherNames =
            snapshot.docs.map((doc) => doc['name'].toString()).toList();
        teacherMap = {
          for (var doc in snapshot.docs) doc['name'].toString(): doc.id
        };
      });
      print('Teacher names loaded: $teacherNames');
    } catch (e) {
      print('Error fetching teacher list: $e');
    }
  }

  void debugPrintTeachers() async {
    final snapshot = await firestore.collection('teachers').get();
    snapshot.docs.forEach((doc) {
      print('Teacher ID: ${doc.id}, Name: ${doc['name']}');
    });
  }

  Future<void> saveLessonInfo() async {
    if (classController.text.isEmpty ||
        selectedCourse == null ||
        selectedDay == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('すべてのフィールドは必須です。フォームに記入してください'),
      ));
      return;
    }

    try {
      Map<String, dynamic> teacherData = {};
      selectedTeacherIds.where((id) => id != null).forEach((id) {
        String cleanedTeacherName =
            id!.replaceFirst(RegExp(r'^(IT|GAME) - '), '');
        if (teacherMap.containsKey(cleanedTeacherName)) {
          String teacherUid = teacherMap[cleanedTeacherName]!;
          teacherData[teacherUid] = {'NAME': cleanedTeacherName};
        }
      });

      await firestore.collection('lessons').add({
        'class': classController.text,
        'course': selectedCourse,
        'teachers': teacherData,
        'classroom': classroomController.text,
        'time': selectedTime,
        'day': selectedDay,
        'place': selectedPlace,
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lesson information saved successfully!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving lesson information: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInputContainer(
                title: '新しい授業作成',
                inputWidgets: [
                  CustomInput(
                    controller: classController,
                    hintText: 'クラス名',
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: 16),
                  Customdropdown(
                    items: ['IT', 'GAME'],
                    value: selectedCourse,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCourse = newValue;
                      });
                    },
                    hintText: 'コースを選択',
                  ),
                  SizedBox(height: 16),
                  ...selectedTeacherIds.asMap().entries.map((entry) {
                    int index = entry.key;
                    return Column(
                      children: [
                        Customdropdown(
                          items: teacherNames,
                          value: selectedTeacherIds[index],
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedTeacherIds[index] = newValue;
                            });
                          },
                          hintText: '教師を選択',
                        ),
                        SizedBox(height: 8),
                      ],
                    );
                  }).toList(),
                  CustomButton(
                    text: '追加の教員を選択',
                    onPressed: () {
                      setState(() {
                        selectedTeacherIds.add(null);
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Customdropdown(
                    items: ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日'],
                    value: selectedDay,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDay = newValue;
                      });
                    },
                    hintText: '曜日を選択',
                  ),
                  SizedBox(height: 16),
                  Customdropdown(
                    items: ['1', '2', '3', '4', '5'],
                    value: selectedTime,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTime = newValue;
                      });
                    },
                    hintText: '時間を選択',
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    controller: classroomController,
                    hintText: '教室名',
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: 16),
                  Customdropdown(
                    items: [
                      '国際１号館',
                      '国際2号館',
                      '国際3号館',
                      '1号館',
                      '2号館',
                      '3号館',
                      '4号館'
                    ],
                    value: selectedPlace,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPlace = newValue;
                      });
                    },
                    hintText: '場所を選択',
                  ),
                ],
              ),
              SizedBox(height: 24),
              CustomButton(
                text: '確定',
                onPressed: saveLessonInfo,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}

// Custom Dropdown Widget
class Customdropdown extends StatelessWidget {
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String hintText;

  const Customdropdown({
    required this.items,
    required this.value,
    required this.onChanged,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: hintText,
        border: OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }
}
