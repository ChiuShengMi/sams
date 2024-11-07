// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:sams/pages/mainPages/homepage_admin.dart';
// // import 'package:sams/pages/mainPages/subjectlist/subjecttable.dart';
// // import 'package:firebase_database/firebase_database.dart';

// // import 'package:sams/widget/appbar.dart';
// // import 'package:sams/widget/bottombar.dart';
// // import 'package:sams/widget/lessontable.dart';
// // import 'package:flutter/material.dart';
// // import 'package:sams/widget/button/custom_button.dart';
// // import 'package:sams/widget/lessontable_edit.dart';

// // class SubjecttableEdit extends StatelessWidget {
// //   final Map<String, dynamic> lessonData;

// //   SubjecttableEdit({required this.lessonData});
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: CustomAppBar(),
// //       body: Column(
// //         crossAxisAlignment: CrossAxisAlignment.center,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text(
// //                 "授業リスト編集",
// //                 style: TextStyle(
// //                   fontSize: 24, // Customize font size
// //                   fontWeight: FontWeight.bold, // Make the font bold
// //                   color: Colors.black, // Adjust the color as needed
// //                 ),
// //               ),
// //             ],
// //           ),
// //           Divider(
// //             color: Colors.grey,
// //             thickness: 1.5,
// //             height: 15.0,
// //           ),
// //           SizedBox(height: 20), // Additional space after the divider

// //           // Container with the LessonTable and Back Home button, arranged vertically
// //           Expanded(
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   flex: 2,
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text("授業名: ${lessonData['CLASS'] ?? 'N/A'}"),
// //                       Text("教師: ${lessonData['TEACHER_ID'] ?? 'N/A'}"),
// //                       Text("授業曜日: ${lessonData['DAY'] ?? 'N/A'}"),
// //                       Text("時間割: ${lessonData['TIME'] ?? 'N/A'}"),
// //                       Text("QRコード: ${lessonData['QR_CODE'] ?? 'N/A'}"),
// //                       Text("教室: ${lessonData['CLASSROOM'] ?? 'N/A'}"),
// //                       Text("号館: ${lessonData['PLACE'] ?? 'N/A'}"),
// //                     ],
// //                   ),
// //                 ),
// //                 SizedBox(width: 10), // Space between table and buttons
// //                 Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     ElevatedButton.icon(
// //                       onPressed: () {
// //                         // Code for the Delete button
// //                       },
// //                       icon: Icon(Icons.delete, color: Colors.white),
// //                       label: Text("削除"),
// //                       style: ElevatedButton.styleFrom(iconColor: Colors.red),
// //                     ),
// //                     SizedBox(
// //                         height:
// //                             20), // Space between Delete and the bottom buttons
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         ElevatedButton.icon(
// //                           onPressed: () {
// //                             Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                   builder: (context) => SubjectTable()),
// //                             );
// //                           },
// //                           icon: Icon(Icons.arrow_back, color: Colors.white),
// //                           label: Text("戻る"),
// //                           style: ElevatedButton.styleFrom(
// //                               shadowColor: Colors.purple),
// //                         ),
// //                         SizedBox(
// //                             width:
// //                                 10), // Space between Back and Confirm buttons
// //                         ElevatedButton.icon(
// //                           onPressed: () {},
// //                           icon: Icon(Icons.check, color: Colors.white),
// //                           label: Text("確定"),
// //                           style: ElevatedButton.styleFrom(
// //                               shadowColor: Colors.green),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //       bottomNavigationBar: BottomBar(), // Optional BottomBar
// //     );
// //   }
// // }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/widget/button/custom_button.dart';

class SubjecttableEdit extends StatefulWidget {
  final Map<String, dynamic> lessonData;
  final String id;
  final String course;

  SubjecttableEdit({
    required this.lessonData,
    required this.id,
    required this.course
    });
  

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
    _courseController = TextEditingController(
        text: widget.id.toString() ?? '');
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
    // classTypeとlessonIdはwidgetのプロパティから取得
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
    'CLASS': _classController.text, // FirestoreではCLASSのみを更新
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
        // スクロール可能にするために追加
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
              Divider(
                color: Colors.grey,
                thickness: 1.5,
                height: 15.0,
              ),
              SizedBox(height: 20),
              Column(
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
                  SizedBox(height: 20),
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
                                onPressed: () => Navigator.of(context).pop(),
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
                      }),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        text: '戻る',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 10),
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
                          }),
                    ],
                  ),
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
