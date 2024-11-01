import 'package:flutter/foundation.dart'; // kIsWeb用
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

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
  List<Map<String, dynamic>> classNames = []; // コース情報を保持するために更新
  List<Map<String, dynamic>> selectedClasses = []; // 選択されたコースを保持
  String? currentUserId;
  String? selectedCategory;
  String? selectedReason;
  String? userClass; // 現在のユーザーのクラスを保存
  String? selectedCourse; // 選択されたコースタイプ（ITまたはGAME）を保存
  File? uploadedFile; // モバイル/デスクトップでファイルを保存
  Uint8List? uploadedFileData; // Web上でファイルデータを保存

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  // 日付を選択するための関数
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? now : (startDate ?? now),
      firstDate: isStart
          ? DateTime(2020)
          : (startDate != null ? startDate! : DateTime(2020)),
      lastDate: isStart
          ? DateTime(2030)
          : (startDate != null
              ? startDate!.add(Duration(days: 7))
              : DateTime(2030)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (endDate != null &&
              (endDate!.isBefore(startDate!) ||
                  endDate!.isAfter(startDate!.add(Duration(days: 7))))) {
            endDate = null;
          }
        } else {
          endDate = picked;
        }
        _calculateSelectedDays();
        _fetchClassesFromRealtimeDatabase();
      });
    }
  }

  // 選択された日付範囲の曜日を計算
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

  // Realtime Databaseからクラス情報を取得
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

  // 指定されたスナップショットから一致するクラス情報を取得
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

  // Firestoreからクラス名を取得
  Future<void> _fetchClassNamesFromFirestore(List<Map<String, dynamic>> classes) async {
    List<Map<String, dynamic>> fetchedClassNames = [];

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
            userClass = student['CLASS'];
            selectedCourse = course;
            break;
          }
        }

        if (isEnrolled) {
          String className = doc['CLASS'];
          String timeFormatted = '${time}限目';
          String formattedClass = '$className - $day - $timeFormatted';
          fetchedClassNames.add({
            'id': classId,
            'name': formattedClass,
            'selected': false,
            'day': day, // 後で使用するために曜日を含める
          });
        }
      }
    }

    setState(() {
      classNames = fetchedClassNames;
    });
  }

  // クラスの選択を確定
  void _confirmSelection() {
    setState(() {
      selectedClasses = classNames.where((classItem) => classItem['selected']).toList();
      classNames.clear();
    });
  }

  // クラスの選択をリセット
  void _resetSelection() {
    setState(() {
      classNames.forEach((classItem) => classItem['selected'] = false);
      selectedClasses.clear();
      _fetchClassesFromRealtimeDatabase();
    });
  }

  // 画像ファイルを選択
  Future<void> _pickFile() async {
    final picker = ImagePicker();
    if (kIsWeb) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final fileData = await pickedFile.readAsBytes();
        setState(() {
          uploadedFileData = fileData;
        });
      }
    } else {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          uploadedFile = File(pickedFile.path);
        });
      }
    }
  }

// 休暇申請を提出
Future<void> _submitLeaveRequest() async {
  
  if (startDate == null || endDate == null || selectedClasses.isEmpty || selectedCategory == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('未完成の欄位が存在します。すべての必須項目を記入してください。')),
    );
    return;
  }
  
 
  if ((selectedCategory != 'その他' && (selectedReason == null || selectedReason!.isEmpty)) ||
      (selectedCategory == 'その他' && (remarksController.text.isEmpty))) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('理由または備考を記入してください。')),
    );
    return;
  }

  String timestamp = DateTime.now().toLocal().toString().replaceAll(':', '').split('.')[0];
  String fileName = '$timestamp.jpg';

  String? fileUrl;
  if (kIsWeb) {
    if (uploadedFileData != null) {
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('Leaves/$currentUserId/$fileName');
      await storageRef.putData(uploadedFileData!);
      fileUrl = await storageRef.getDownloadURL();
    }
  } else {
    if (uploadedFile != null) {
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('Leaves/$currentUserId/$fileName');
      await storageRef.putFile(uploadedFile!);
      fileUrl = await storageRef.getDownloadURL();
    }
  }

  for (var classItem in selectedClasses) {
    String classId = classItem['id'];
    String course = selectedCourse ?? 'UNKNOWN';
    String day = classItem['day']; // 正しい日付を取得
    DateTime leaveDate = _getCorrectLeaveDate(day);

    CollectionReference leaveCollection = FirebaseFirestore.instance
        .collection('Leaves')
        .doc(course)
        .collection(currentUserId!);

    QuerySnapshot leaveDocs = await leaveCollection.get();
    String leaveId = 'Leaves_${(leaveDocs.docs.length + 1).toString().padLeft(3, '0')}';

    Map<String, dynamic> leaveData = {
      'CLASS_ID': classId,
      'CLASS': userClass,
      'FILE': fileUrl,
      'LEAVE_DATE': '${leaveDate.year}-${leaveDate.month}-${leaveDate.day}',
      'LEAVE_CATEGORY': selectedCategory,
      'LEAVE_REASON': selectedReason,
      'LEAVE_STATUS': 0,
      'LEAVE_TEXT': remarksController.text,
    };

    await leaveCollection.doc(leaveId).set(leaveData);
  }

  setState(() {
    startDate = null;
    endDate = null;
    selectedCategory = null;
    selectedReason = null;
    remarksController.clear();
    uploadedFile = null;
    uploadedFileData = null;
    selectedClasses.clear();
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('申請が成功しました')),
  );
}


  // 正しい休暇日を取得
  DateTime _getCorrectLeaveDate(String day) {
    List<String> days = ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日'];
    int dayIndex = days.indexOf(day) + 1;

    DateTime currentDate = startDate!;
    while (currentDate.isBefore(endDate!.add(Duration(days: 1)))) {
      if (currentDate.weekday == dayIndex) {
        return currentDate;
      }
      currentDate = currentDate.add(Duration(days: 1));
    }

    return startDate!; // ここに到達することは基本的にないはず
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
              if (classNames.isNotEmpty)
                Column(
                  children: [
                    ...classNames.map((classItem) {
                      return CheckboxListTile(
                        title: Text(classItem['name']),
                        value: classItem['selected'],
                        onChanged: (bool? value) {
                          setState(() {
                            classItem['selected'] = value ?? false;
                          });
                        },
                      );
                    }).toList(),
                    ElevatedButton(
                      onPressed: _confirmSelection,
                      child: Text('確定'),
                    ),
                  ],
                ),
              if (selectedClasses.isNotEmpty) ...[
                Text(
                  '選択された授業：',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ...selectedClasses.map((classItem) {
                  return Text(
                    classItem['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  );
                }).toList(),
                TextButton(
                  onPressed: _resetSelection,
                  child: Text('選びなおす'),
                ),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickFile,
                child: Text('ファイル追加'),
              ),
              if (uploadedFile != null || uploadedFileData != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'ファイルが追加されました',
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
                  items: ['体調不良', '怪我', '就職活動', '電車遅延', 'その他']
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
                  items: ['体調不良', '怪我', '就職活動', 'その他']
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
                onPressed: _submitLeaveRequest,
                child: Text('申請を提出'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
