import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart'; // 用於獲取檔案名稱

class TestPageLeaves extends StatefulWidget {
  @override
  _TestPageLeavesState createState() => _TestPageLeavesState();
}

class _TestPageLeavesState extends State<TestPageLeaves> {
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  List<String> selectedDays = [];
  List<String> classNames = [];
  String? selectedClass;
  File? uploadedFile;
  String? currentUserId;
  String? selectedCategory;
  String? selectedReason;
  String? fileName; // 顯示的檔案名稱

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: isStart ? DateTime(2020) : startDate ?? DateTime(2020),
      lastDate: isStart ? endDate ?? DateTime(2030) : DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (endDate != null && endDate!.isBefore(startDate!)) {
            endDate = null;
          }
        } else {
          endDate = picked;
          if (startDate != null && startDate!.isAfter(endDate!)) {
            startDate = null;
          }
        }
        selectedClass = null;
        _calculateSelectedDays();
        _fetchClassesFromRealtimeDatabase();
      });
    }
  }

  void _calculateSelectedDays() {
    if (startDate == null || endDate == null) return;

    List<String> days = ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日'];
    selectedDays.clear();
    DateTime currentDate = startDate!;

    while (currentDate.isBefore(endDate!.add(Duration(days: 1)))) {
      String dayOfWeek = days[currentDate.weekday - 1];
      if (!selectedDays.contains(dayOfWeek)) {
        selectedDays.add(dayOfWeek);
      }
      currentDate = currentDate.add(Duration(days: 1));
    }
  }

  Future<void> _fetchClassesFromRealtimeDatabase() async {
    if (selectedDays.isEmpty || currentUserId == null) return;

    List<Map<String, dynamic>> matchingClasses = [];

    DatabaseReference itRef = FirebaseDatabase.instance.ref("CLASS/IT");
    DatabaseEvent itEvent = await itRef.once();
    matchingClasses.addAll(_getMatchingClasses(itEvent.snapshot, "IT"));

    DatabaseReference gameRef = FirebaseDatabase.instance.ref("CLASS/GAME");
    DatabaseEvent gameEvent = await gameRef.once();
    matchingClasses.addAll(_getMatchingClasses(gameEvent.snapshot, "GAME"));

    await _fetchClassNamesFromFirestore(matchingClasses);
  }

  List<Map<String, dynamic>> _getMatchingClasses(DataSnapshot snapshot, String course) {
    List<Map<String, dynamic>> classes = [];
    for (var child in snapshot.children) {
      String classId = child.key ?? "";
      Map<String, dynamic> data = Map<String, dynamic>.from(child.value as Map);

      if (selectedDays.contains(data['DAY'])) {
        int time = int.tryParse(data['TIME'].toString()) ?? 0;
        classes.add({
          'id': classId,
          'day': data['DAY'],
          'time': time,
          'course': course
        });
      }
    }
    return classes;
  }

  Future<void> _fetchClassNamesFromFirestore(List<Map<String, dynamic>> classes) async {
    List<String> fetchedClassNames = [];

    for (var classInfo in classes) {
      String classId = classInfo['id'];
      String course = classInfo['course'];
      String day = classInfo['day'];
      int time = classInfo['time'];

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Class')
          .doc(course)
          .collection('Subjects')
          .doc(classId)
          .get();

      if (doc.exists) {
        bool isEnrolled = false;

        Map<String, dynamic> students = doc['STD'] as Map<String, dynamic>;
        
        for (var student in students.values) {
          if (student['UID'] == currentUserId) {
            isEnrolled = true;
            break;
          }
        }

        if (isEnrolled) {
          String className = doc['CLASS'];
          String timeFormatted = '${time}限目';
          String formattedClass = '$className - $day - $timeFormatted';
          fetchedClassNames.add(formattedClass);
        }
      }
    }

    setState(() {
      classNames = fetchedClassNames;
    });
  }

  void _onClassSelected(String className) {
    setState(() {
      selectedClass = className;
      classNames.clear();
    });
  }

  void _resetSelection() {
    setState(() {
      selectedClass = null;
      _fetchClassesFromRealtimeDatabase();
    });
  }

  Future<void> _pickFile() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        uploadedFile = File(pickedFile.path);
        fileName = Uri.decodeFull(basename(uploadedFile!.path)); // 解碼檔名以防止亂碼
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('休暇届出'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '休暇の開始日と終了日を選択してください:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text('開始日を選択'),
                  ),
                  SizedBox(width: 20),
                  Text(
                    startDate != null
                        ? "${startDate!.year}/${startDate!.month}/${startDate!.day}"
                        : "未選択",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text('終了日を選択'),
                  ),
                  SizedBox(width: 20),
                  Text(
                    endDate != null
                        ? "${endDate!.year}/${endDate!.month}/${endDate!.day}"
                        : "未選択",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (selectedClass == null)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: classNames.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(classNames[index]),
                      onTap: () => _onClassSelected(classNames[index]),
                    );
                  },
                ),
              if (selectedClass != null) ...[
                Row(
                  children: [
                    Text(
                      '選択された授業：',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      selectedClass!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextButton(
                      onPressed: _resetSelection,
                      child: Text('選びなおす'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: Text('ファイル追加'),
                ),
                if (fileName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      fileName!,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: '種別選択'),
                  value: selectedCategory,
                  items: ['欠席', '遅刻', '早退', 'その他'].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                      selectedReason = null;
                    });
                  },
                ),
                if (selectedCategory == '欠席' || selectedCategory == '遅刻') ...[
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: '理由'),
                    value: selectedReason,
                    items: ['体調不良', '怪我', '公欠', '就職活動', '電車遅延', 'その他']
                        .map((reason) => DropdownMenuItem(
                              value: reason,
                              child: Text(reason),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                ] else if (selectedCategory == '早退') ...[
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: '理由'),
                    value: selectedReason,
                    items: ['体調不良', '怪我', 'その他']
                        .map((reason) => DropdownMenuItem(
                              value: reason,
                              child: Text(reason),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                ],
                if (selectedCategory != null) ...[
                  SizedBox(height: 10),
                  TextField(
                    controller: remarksController,
                    decoration: InputDecoration(labelText: '備考'),
                    maxLines: 3,
                  ),
                ],
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // 申請按鍵動作(目前無動作)
                  },
                  child: Text('申請を提出'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
