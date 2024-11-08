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

  @override
  void initState() {
    super.initState();
    _classController = TextEditingController(
        text: widget.lessonData['CLASS']?.toString() ?? '');
    _courseController =
        TextEditingController(text: widget.course.toString() ?? '');
    _teacherController = TextEditingController(
        text: widget.lessonData['TEACHER_ID']?.toString() ?? '');
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
    // ClassType and lessonId are fetched from widget's properties
    String classType = widget.course;
    String lessonId = widget.id;

    Map<String, dynamic> updatedData = {
      'CLASS': _classController.text,
      'COURSE': _courseController.text,
      'TEACHER_ID': _teacherController.text,
      'DAY': _dayController.text,
      'TIME': _timeController.text,
      'QR_CODE': _qrCodeController.text,
      'CLASSROOM': _classroomController.text,
      'PLACE': _placeController.text,
    };

    Map<String, dynamic> firestoreUpdatedData = {
      'CLASS':
          _classController.text, // Update only the CLASS field in Firestore
    };

    try {
      await FirebaseFirestore.instance
          .collection('Class')
          .doc(classType)
          .collection('Subjects')
          .doc(lessonId)
          .update(firestoreUpdatedData);

      await FirebaseDatabase.instance
          .ref('CLASS/$classType/$lessonId')
          .update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('授業情報が更新されました')),
      );
      Navigator.of(context).pop();
    } catch (e) {
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
      // Deleting lesson from Firestore and Realtime Database
      await FirebaseFirestore.instance
          .collection('Class')
          .doc(classType)
          .collection('Subjects')
          .doc(lessonId)
          .delete();

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            decoration: InputDecoration(labelText: '授業名'),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _courseController,
                            decoration: InputDecoration(labelText: 'コース'),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _teacherController,
                            decoration: InputDecoration(labelText: '教師'),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _dayController,
                            decoration: InputDecoration(labelText: '授業曜日'),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _timeController,
                            decoration: InputDecoration(labelText: '時間割'),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _qrCodeController,
                            decoration: InputDecoration(labelText: 'QRコード'),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _classroomController,
                            decoration: InputDecoration(labelText: '教室'),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _placeController,
                            decoration: InputDecoration(labelText: '号館'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  //右側ボタン

                  Expanded(
                    flex: 1,
                    child: Container(
                      //alignment: Alignment.topCenter, // Align to the right
                      padding: EdgeInsets.all(100),
                      //color: Colors.grey[200], // background color
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
                                builder: (context) => DeleteModalSubEdit(
                                  onConfirmDelete: () async {
                                    Navigator.of(context).pop();
                                    await _deleteLesson(context);
                                  },
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
                                builder: (context) => EditModalSubEdit(
                                  onConfirmEdit: () async {
                                    await _updateLesson(context);
                                  },
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
