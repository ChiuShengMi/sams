import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/utils/log.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class SubjecttableEdit extends StatefulWidget {
  final Map<String, dynamic> lessonData;
  final String id;
  final String course;

  SubjecttableEdit({
    required this.lessonData,
    required this.id,
    required this.course,
  });

  @override
  _SubjecttableEditState createState() => _SubjecttableEditState();
}

class _SubjecttableEditState extends State<SubjecttableEdit> {
  late TextEditingController _classController;
  late TextEditingController _courseController;
  late TextEditingController _qrCodeController;
  late TextEditingController _classroomController;
  bool isSnackbarActive = false;

  String? _selectedDay;
  String? _selectedTime;
  String? _selectedPlace;

  // 教師データ
  List<Map<String, dynamic>> _teacherDropdownData = [];
  List<String> _selectedTeachers = [];

  final List<String> _days = ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日'];
  final List<String> _times = ['1', '2', '3', '4', '5'];
  final List<String> _place = [
    '国際1号館',
    '国際2号館',
    '国際3号館',
    '1号館',
    '2号館',
    '3号館',
    '4号館'
  ];

  @override
  void initState() {
    super.initState();
    _classController = TextEditingController(
        text: widget.lessonData['CLASS']?.toString() ?? '');
    _courseController =
        TextEditingController(text: widget.course.toString() ?? '');
    _qrCodeController = TextEditingController(
        text: widget.lessonData['QR_CODE']?.toString() ?? '');
    _classroomController = TextEditingController(
        text: widget.lessonData['CLASSROOM']?.toString() ?? '');
    _selectedDay = widget.lessonData['DAY']?.toString();
    _selectedTime = widget.lessonData['TIME']?.toString();
    _selectedPlace = widget.lessonData['PLACE']?.toString();

    _initializeSelectedTeachers();
    _fetchTeachersData();
  }

  @override
  void dispose() {
    _classController.dispose();
    _qrCodeController.dispose();
    _classroomController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (isSnackbarActive) return;
    isSnackbarActive = true;

    scaffoldMessengerKey.currentState
        ?.showSnackBar(
          SnackBar(
            content: Text(message),
            duration: Duration(seconds: 3),
          ),
        )
        .closed
        .then((_) {
      isSnackbarActive = false;
    });
  }

  void _initializeSelectedTeachers() {
    if (widget.lessonData['TEACHER_ID'] is Map) {
      Map<dynamic, dynamic> teacherMap =
          widget.lessonData['TEACHER_ID'] as Map<dynamic, dynamic>;

      _selectedTeachers = teacherMap.values
          .map((e) {
            String teacherName = e['NAME']?.toString() ?? '';
            var matchedTeacher = _teacherDropdownData.firstWhere(
                (teacher) => teacher['name'] == teacherName,
                orElse: () => {});
            if (matchedTeacher.isNotEmpty) {
              return matchedTeacher['id'] as String;
            } else {
              return '';
            }
          })
          .where((id) => id.isNotEmpty)
          .toList();
    }
  }

  Future<void> _fetchTeachersData() async {
    List<Map<String, dynamic>> teacherList = [];
    try {
      final itTeachers = await FirebaseFirestore.instance
          .collection('Users')
          .doc('Teachers')
          .collection('IT')
          .get();
      final gameTeachers = await FirebaseFirestore.instance
          .collection('Users')
          .doc('Teachers')
          .collection('GAME')
          .get();

      teacherList.addAll(itTeachers.docs.map((doc) => {
            'id': doc.id,
            'name': doc['NAME'] ?? '',
            'course': 'IT',
          }));
      teacherList.addAll(gameTeachers.docs.map((doc) => {
            'id': doc.id,
            'name': doc['NAME'] ?? '',
            'course': 'GAME',
          }));

      setState(() {
        _teacherDropdownData = teacherList;
        _initializeSelectedTeachers();
      });
    } catch (e) {
      print('Error fetching teachers data: $e');
    }
  }

  Future<void> _updateLesson() async {
    if (_classController.text.isEmpty) {
      _showSnackBar('授業名を入力してください');
      return;
    }
    if (_qrCodeController.text.isEmpty) {
      _showSnackBar('QRコードを入力してください');
      return;
    }
    if (_classroomController.text.isEmpty) {
      _showSnackBar('教室名を入力してください');
      return;
    }
    if (_selectedDay == null || _selectedDay!.isEmpty) {
      _showSnackBar('曜日を選択してください');
      return;
    }
    if (_selectedTime == null || _selectedTime!.isEmpty) {
      _showSnackBar('時間を選択してください');
      return;
    }
    if (_selectedPlace == null || _selectedPlace!.isEmpty) {
      _showSnackBar('号館を選択してください');
      return;
    }
    if (_selectedTeachers.isEmpty ||
        _selectedTeachers.any((teacher) => teacher.isEmpty)) {
      _showSnackBar('教師を選択してください');
      return;
    }

    String classType = widget.course;
    String lessonId = widget.id;

    // get login account data
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('ユーザーがログインしていません');
    final uid = user.uid;

    // user data here
    DocumentSnapshot? managerSnapshot;
    managerSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc('Managers')
        .collection('IT')
        .doc(uid)
        .get();

    if (!managerSnapshot.exists) {
      managerSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc('Managers')
          .collection('GAME')
          .doc(uid)
          .get();
    }

    if (!managerSnapshot.exists) {
      throw Exception('管理者情報が見つかりません');
    }

    final managerData = managerSnapshot.data() as Map<String, dynamic>;
    final userId = managerData['ID'];
    final userName = managerData['NAME'];

    // update data
    Map<String, dynamic> updatedData = {
      'CLASS': _classController.text,
      'COURSE': _courseController.text,
      'TEACHER_ID': {
        for (var teacherId in _selectedTeachers)
          teacherId: {
            'NAME': _teacherDropdownData.firstWhere(
              (teacher) => teacher['id'] == teacherId,
              orElse: () => {'name': 'Unknown'},
            )['name'],
          }
      },
      'DAY': _selectedDay,
      'TIME': _selectedTime,
      'QR_CODE': _qrCodeController.text,
      'CLASSROOM': _classroomController.text,
      'PLACE': _selectedPlace,
    };

    try {
      final docRef = FirebaseFirestore.instance
          .collection('Class')
          .doc(classType)
          .collection('Subjects')
          .doc(lessonId);

      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        await docRef.update(updatedData);
      } else {
        print('Firestore 文檔不存在：$lessonId');
      }

      final dbRef = FirebaseDatabase.instance.ref('CLASS/$classType/$lessonId');
      final dbSnapshot = await dbRef.get();
      if (dbSnapshot.exists) {
        await dbRef.update(updatedData);
      } else {
        print('Realtime Database 文檔不存在：$lessonId');
      }

      await Utils.logMessage(
        '$userName-$userId が授業 (${_classController.text}) を編集しました。',
      );

      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('授業情報が更新されました')),
      );

      Future.delayed(Duration(milliseconds: 300), () {
        Navigator.of(context).pop(true);
      });
    } catch (e) {
      print('Error updating lesson: $e');
      if (scaffoldMessengerKey.currentState != null) {
        scaffoldMessengerKey.currentState!.showSnackBar(
          SnackBar(content: Text('更新中にエラーが発生しました: $e')),
        );
      }
    }
  }

  Future<void> _deleteLesson() async {
    String classType = widget.course;
    String lessonId = widget.id;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('ユーザーがログインしていません');
      final uid = user.uid;

      DocumentSnapshot? managerSnapshot;
      managerSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc('Managers')
          .collection('IT')
          .doc(uid)
          .get();

      if (!managerSnapshot.exists) {
        managerSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc('Managers')
            .collection('GAME')
            .doc(uid)
            .get();
      }

      if (!managerSnapshot.exists) {
        throw Exception('管理者情報が見つかりません');
      }

      final managerData = managerSnapshot.data() as Map<String, dynamic>;
      final userId = managerData['ID'];
      final userName = managerData['NAME'];

      await FirebaseFirestore.instance
          .collection('Class')
          .doc(classType)
          .collection('Subjects')
          .doc(lessonId)
          .delete();

      await FirebaseDatabase.instance
          .ref('CLASS/$classType/$lessonId')
          .remove();

      await Utils.logMessage(
        '$userName-$userId が授業 (${_classController.text}) を削除しました。',
      );

      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('授業が削除されました')),
      );

      Future.delayed(Duration(milliseconds: 300), () {
        Navigator.of(context).pop();
      });
    } catch (e) {
      print('Error deleting lesson: $e');
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('削除中にエラーが発生しました: $e')),
      );
    }
  }

  List<Widget> _buildTeacherSelection() {
    return _selectedTeachers.asMap().entries.map((entry) {
      int index = entry.key;
      String teacherId = entry.value;

      return Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: teacherId.isNotEmpty ? teacherId : null,
              items: [
                DropdownMenuItem(
                  value: null,
                  enabled: false,
                  child: Text(
                    '教師を選択してください',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ..._teacherDropdownData
                    .map<DropdownMenuItem<String>>((teacher) {
                  return DropdownMenuItem<String>(
                    value: teacher['id'] as String,
                    child: Text('${teacher['name']} (${teacher['course']})'),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    _selectedTeachers[index] = value;
                  }
                });
              },
              decoration: InputDecoration(labelText: '教師'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                _selectedTeachers.removeAt(index);
              });
            },
          ),
        ],
      );
    }).toList();
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextField(
          controller: _classController,
          decoration: InputDecoration(labelText: '授業名'),
        ),
        ..._buildTeacherSelection(),
        ElevatedButton(
          onPressed: () => setState(() => _selectedTeachers.add('')),
          child: Text('教師を追加'),
        ),
        DropdownButtonFormField<String>(
          value: _selectedDay,
          items: _days
              .map((day) => DropdownMenuItem(value: day, child: Text(day)))
              .toList(),
          onChanged: (value) => setState(() => _selectedDay = value),
          decoration: InputDecoration(labelText: '授業曜日'),
        ),
        DropdownButtonFormField<String>(
          value: _selectedTime,
          items: _times
              .map((time) => DropdownMenuItem(value: time, child: Text(time)))
              .toList(),
          onChanged: (value) => setState(() => _selectedTime = value),
          decoration: InputDecoration(labelText: '時間割'),
        ),
        TextField(
          controller: _qrCodeController,
          decoration: InputDecoration(labelText: 'QRコード'),
        ),
        TextField(
          controller: _classroomController,
          decoration: InputDecoration(labelText: '教室'),
        ),
        DropdownButtonFormField<String>(
          value: _selectedPlace,
          items: _place
              .map(
                  (place) => DropdownMenuItem(value: place, child: Text(place)))
              .toList(),
          onChanged: (value) => setState(() => _selectedPlace = value),
          decoration: InputDecoration(labelText: '号館'),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CustomButton(
            text: '戻る',
            onPressed: () => Navigator.pop(context),
          ),
          CustomButton(
            text: '更新',
            onPressed: () => _showConfirmationDialog(
              title: "変更の確認",
              content: "授業リストを更新しますか?",
              onConfirm: _updateLesson,
            ),
          ),
          CustomButton(
            text: '削除',
            onPressed: () => _showConfirmationDialog(
              title: "削除の確認",
              content: "授業リストから削除しますか?",
              onConfirm: _deleteLesson,
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String content,
    required Future<void> Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("キャンセル"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await onConfirm();
            },
            child: Text("確認"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: CustomAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '授業編集',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildFormFields(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }
}
