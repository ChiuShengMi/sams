import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sams/utils/firebase_firestore.dart';
import 'package:sams/utils/firebase_realtime.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/custom_input_container.dart';
import 'package:sams/widget/searchbar/custom_input.dart';
import 'package:sams/widget/bottombar.dart';

class SubjecttableNew extends StatefulWidget {
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
  final FirestoreService _firestoreService = FirestoreService();
  final RealtimeDatabaseService _realtimeDatabaseService =
      RealtimeDatabaseService();

  List<String> teacherNames = [];
  Map<String, String> teacherMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    try {
      final names = await _firestoreService.fetchTeachers(teacherMap);
      setState(() {
        teacherNames = names;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching teachers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: CustomAppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                text: '授業作成確定',
                onPressed: _submitClassData,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }

  Future<void> _submitClassData() async {
    // Validate required fields
    if (classController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('クラス名を入力してください')),
      );
      return;
    }

    if (selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('コースを選択してください')),
      );
      return;
    }

    if (selectedTeacherIds.every((id) => id == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('少なくとも1人の教師を選択してください')),
      );
      return;
    }

    if (selectedDay == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('曜日と時間を選択してください')),
      );
      return;
    }

    if (classroomController.text.isEmpty || selectedPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('教室名と場所を選択してください')),
      );
      return;
    }

    try {
      String course = selectedCourse!;
      String classId = await _realtimeDatabaseService.generateClassId(course);

      Map<String, dynamic> teacherData = {};
      selectedTeacherIds.where((id) => id != null).forEach((id) {
        String cleanedTeacherName =
            id!.replaceFirst(RegExp(r'^(IT|GAME) - '), '');
        if (teacherMap.containsKey(cleanedTeacherName)) {
          String teacherUid = teacherMap[cleanedTeacherName]!;
          teacherData[teacherUid] = {'NAME': cleanedTeacherName};
        }
      });

      String qrCode = "https://example.com/qr/$classId";

      await _realtimeDatabaseService.saveClassData(course, classId, {
        'CLASS': classController.text,
        'TEACHER_ID': teacherData,
        'DAY': selectedDay,
        'TIME': selectedTime,
        'CLASSROOM': classroomController.text,
        'PLACE': selectedPlace,
        'QR_CODE': qrCode,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('授業が正常に作成されました'),
          backgroundColor: Colors.green,
        ),
      );

      _clearForm();
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('授業の作成中にエラーが発生しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    classController.clear();
    classroomController.clear();
    setState(() {
      selectedCourse = null;
      selectedPlace = null;
      selectedDay = null;
      selectedTime = null;
      selectedTeacherIds = [null];
    });
  }
}

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
    print('Available teacher names: $items');
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
