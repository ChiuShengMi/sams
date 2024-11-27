import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/modal/confirmation_modal.dart';

class SubjecttableEdit extends StatefulWidget {
  final Map<String, dynamic> lessonData;
  final String id;
  final String course;

  SubjecttableEdit(
      {required this.lessonData, required this.id, required this.course});

  @override
  _SubjecttableEditState createState() => _SubjecttableEditState();
}

class _SubjecttableEditState extends State<SubjecttableEdit> {
  late TextEditingController _classController;
  late TextEditingController _courseController;
  late TextEditingController _teacherController;
  late TextEditingController _dayController;
  late TextEditingController _timeController;
  late TextEditingController _qrCodeController;
  late TextEditingController _classroomController;
  late TextEditingController _placeController;

  String? _selectedDay;

  String? _selectedTime;

  String? _selectedPlace;

  final List<String> _days = ['月曜日', '火曜日', '水曜日', '木曜日', '金曜', '土曜日', '日曜日'];
  final List<String> _times = ['1', '2', '3', '4', '5', '6'];
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

    String teacherDisplay = 'N/A';

    if (widget.lessonData['TEACHER_ID'] is Map) {
      Map<dynamic, dynamic> teacherMap =
          widget.lessonData['TEACHER_ID'] as Map<dynamic, dynamic>;

      teacherDisplay = teacherMap.values
          .map((teacher) => teacher['NAME'].toString())
          .join('\n'); // 用逗号分隔名字
    }

    _teacherController = TextEditingController(text: teacherDisplay);

    _dayController =
        TextEditingController(text: widget.lessonData['DAY']?.toString() ?? '');
    _timeController = TextEditingController(
        text: widget.lessonData['TIME']?.toString() ?? '');
    _qrCodeController = TextEditingController(
        text: widget.lessonData['QR_CODE']?.toString() ?? '');
    _classroomController = TextEditingController(
        text: widget.lessonData['CLASSROOM']?.toString() ?? '');
    _placeController = TextEditingController(
        text: widget.lessonData['PLACE']?.toString() ?? '');
  }

  @override
  void dispose() {
    _classController.dispose();
    _courseController.dispose();
    _teacherController.dispose();
    _dayController.dispose();
    _timeController.dispose();
    _qrCodeController.dispose();
    _classroomController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _updateLesson(BuildContext context) async {
    // classTypeとlessonIdはwidgetのプロパティから取得
    String classType = widget.course;
    String lessonId = widget.id;

    // 更新用のデータをMap形式で保持
    Map<dynamic, dynamic> teacherMap =
        widget.lessonData['TEACHER_ID'] as Map<dynamic, dynamic>? ?? {};

    // updatedDataに`TEACHER_ID`フィールドをもとのMap形式で追加
    Map<String, dynamic> updatedData = {
      'CLASS': _classController.text,
      'COURSE': _courseController.text,
      'TEACHER_ID': teacherMap,
      'DAY': _selectedDay,
      'TIME': _selectedTime,
      'QR_CODE': _qrCodeController.text,
      'CLASSROOM': _classroomController.text,
      'PLACE': _selectedPlace,
    };

    // Firestore用のデータ（ここでは例として`CLASS`フィールドのみ更新）
    Map<String, dynamic> firestoreUpdatedData = {
      'CLASS': _classController.text,
    };

    try {
      // Firestoreでドキュメントが存在するかを確認してから更新する
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('Class')
          .doc(classType)
          .collection('Subjects')
          .doc(lessonId);

      // ドキュメントが存在するか確認
      DocumentSnapshot docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        // ドキュメントが存在する場合は更新
        await docRef.update(firestoreUpdatedData);
      } else {
        // ドキュメントが存在しない場合は新規作成
        await docRef.set(firestoreUpdatedData);
      }
      // Firestoreの更新
      await FirebaseFirestore.instance
          .collection('Class')
          .doc(classType)
          .collection('Subjects')
          .doc(lessonId)
          .update(firestoreUpdatedData);

      // Firebase Realtime Databaseの更新
      await FirebaseDatabase.instance
          .ref('CLASS/$classType/$lessonId')
          .update(updatedData);

      // 更新成功メッセージ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('授業情報が更新されました')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      // エラー処理
      print('Error updating lesson: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新中にエラーが発生しました: $e')),
      );
    }
  }

  Future<void> _deleteLesson(BuildContext context) async {
    String classType = widget.course;
    String lessonId = widget.id;

    try {
      // Firestoreから授業データを削除
      await FirebaseFirestore.instance
          .collection('Class')
          .doc(classType)
          .collection('Subjects')
          .doc(lessonId)
          .delete();

      // Realtime Databaseから授業データを削除
      await FirebaseDatabase.instance
          .ref('CLASS/$classType/$lessonId')
          .remove();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('授業が削除されました')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print('Error deleting lesson: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('削除中にエラーが発生しました: $e')),
      );
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "授業リスト編集",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.grey, thickness: 1.5, height: 15.0),
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.grey[200], //  background color
                      child: Column(
                        children: [
                          TextField(
                              controller: _classController,
                              decoration: InputDecoration(labelText: '授業名')),
                          TextField(
                              controller: _courseController,
                              decoration: InputDecoration(labelText: 'コース')),
                          TextField(
                              controller: _teacherController,
                              decoration: InputDecoration(labelText: '教師')),
                          DropdownButtonFormField<String>(
                            value: _selectedDay,
                            items: _days
                                .map((day) => DropdownMenuItem(
                                    value: day, child: Text(day)))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedDay = value),
                            decoration: InputDecoration(labelText: '授業曜日'),
                          ),
                          DropdownButtonFormField<String>(
                            value: _selectedTime,
                            items: _times
                                .map((time) => DropdownMenuItem(
                                    value: time, child: Text(time)))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedTime = value),
                            decoration: InputDecoration(labelText: '時間割'),
                          ),
                          TextField(
                              controller: _qrCodeController,
                              decoration: InputDecoration(labelText: 'QRコード')),
                          TextField(
                              controller: _classroomController,
                              decoration: InputDecoration(labelText: '教室')),
                          DropdownButtonFormField<String>(
                            value: _selectedPlace,
                            items: _place
                                .map((place) => DropdownMenuItem(
                                    value: place, child: Text(place)))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedPlace = value),
                            decoration: InputDecoration(labelText: '号館'),
                          ),
                          SizedBox(height: 20),
                          // ElevatedButton(
                          //   onPressed: () => _updateLesson(context),
                          //   child: Text('更新'),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  //右側ボタン

                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.all(100),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Center vertically
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Center horizontally
                        children: [
                          CustomButton(
                            text: '削除',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("削除の確認"),
                                  content: Text("授業リストから削除しますか?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text("キャンセル"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        await _deleteLesson(context);
                                      },
                                      child: Text("削除"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          CustomButton(
                            text: '戻る',
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(height: 10),
                          CustomButton(
                            text: '更新',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("変更の確認"),
                                  content: Text("授業リストを編集しますか?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text("キャンセル"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        await _updateLesson(context);
                                      },
                                      child: Text("確認"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
