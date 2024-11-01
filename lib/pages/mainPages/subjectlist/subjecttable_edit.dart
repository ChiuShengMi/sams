// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:sams/pages/mainPages/homepage_admin.dart';
// import 'package:sams/pages/mainPages/subjectlist/subjecttable.dart';
// import 'package:firebase_database/firebase_database.dart';

// import 'package:sams/widget/appbar.dart';
// import 'package:sams/widget/bottombar.dart';
// import 'package:sams/widget/lessontable.dart';
// import 'package:flutter/material.dart';
// import 'package:sams/widget/button/custom_button.dart';
// import 'package:sams/widget/lessontable_edit.dart';

// class SubjecttableEdit extends StatelessWidget {
//   final Map<String, dynamic> lessonData;

//   SubjecttableEdit({required this.lessonData});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "授業リスト編集",
//                 style: TextStyle(
//                   fontSize: 24, // Customize font size
//                   fontWeight: FontWeight.bold, // Make the font bold
//                   color: Colors.black, // Adjust the color as needed
//                 ),
//               ),
//             ],
//           ),
//           Divider(
//             color: Colors.grey,
//             thickness: 1.5,
//             height: 15.0,
//           ),
//           SizedBox(height: 20), // Additional space after the divider

//           // Container with the LessonTable and Back Home button, arranged vertically
//           Expanded(
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("授業名: ${lessonData['CLASS'] ?? 'N/A'}"),
//                       Text("教師: ${lessonData['TEACHER_ID'] ?? 'N/A'}"),
//                       Text("授業曜日: ${lessonData['DAY'] ?? 'N/A'}"),
//                       Text("時間割: ${lessonData['TIME'] ?? 'N/A'}"),
//                       Text("QRコード: ${lessonData['QR_CODE'] ?? 'N/A'}"),
//                       Text("教室: ${lessonData['CLASSROOM'] ?? 'N/A'}"),
//                       Text("号館: ${lessonData['PLACE'] ?? 'N/A'}"),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 10), // Space between table and buttons
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         // Code for the Delete button
//                       },
//                       icon: Icon(Icons.delete, color: Colors.white),
//                       label: Text("削除"),
//                       style: ElevatedButton.styleFrom(iconColor: Colors.red),
//                     ),
//                     SizedBox(
//                         height:
//                             20), // Space between Delete and the bottom buttons
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         ElevatedButton.icon(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => SubjectTable()),
//                             );
//                           },
//                           icon: Icon(Icons.arrow_back, color: Colors.white),
//                           label: Text("戻る"),
//                           style: ElevatedButton.styleFrom(
//                               shadowColor: Colors.purple),
//                         ),
//                         SizedBox(
//                             width:
//                                 10), // Space between Back and Confirm buttons
//                         ElevatedButton.icon(
//                           onPressed: () {},
//                           icon: Icon(Icons.check, color: Colors.white),
//                           label: Text("確定"),
//                           style: ElevatedButton.styleFrom(
//                               shadowColor: Colors.green),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: BottomBar(), // Optional BottomBar
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/pages/mainPages/homepage_admin.dart';
import 'package:sams/pages/mainPages/subjectlist/subjecttable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/widget/lessontable_edit.dart';

class SubjecttableEdit extends StatefulWidget {
  final Map<String, dynamic> lessonData;
  // Map<String, dynamic> lessonData = documentSnapshot.data() as Map<String, dynamic>;

  SubjecttableEdit({required this.lessonData});

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
    //_classController = TextEditingController(text: widget.lessonData['CLASS']);
    _classController = TextEditingController(
        text: widget.lessonData['CLASS']?.toString() ?? '');
    _courseController = TextEditingController(
        text: widget.lessonData['COURSE']?.toString() ?? '');
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

  Future<void> _updateLesson() async {
    String lessonId = widget.lessonData['id']; // Ensure 'id' is in lessonData
    String classType = 'GAME'; // Example: Replace with actual logic or variable
    String classID = lessonId; // Example: Replace with your classID value

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

    try {
      await FirebaseFirestore.instance
          .collection('Class')
          .doc(classType)
          .collection('Subjects')
          .doc(classID)
          .update(updatedData);
      Navigator.of(context).pop();
    } catch (e) {
      print('Error updating lesson: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _classController,
                    decoration: InputDecoration(labelText: '授業名'),
                  ),
                  TextField(
                    controller: _courseController,
                    decoration: InputDecoration(labelText: 'コース'),
                  ),
                  TextField(
                    controller: _teacherController,
                    decoration: InputDecoration(labelText: '教師'),
                  ),
                  TextField(
                    controller: _dayController,
                    decoration: InputDecoration(labelText: '授業曜日'),
                  ),
                  TextField(
                    controller: _timeController,
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
                  TextField(
                    controller: _placeController,
                    decoration: InputDecoration(labelText: '号館'),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // Code for the Delete button
                },
                icon: Icon(Icons.delete, color: Colors.white),
                label: Text("削除"),
                style: ElevatedButton.styleFrom(iconColor: Colors.red),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Go back to the previous page
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    label: Text("戻る"),
                    style: ElevatedButton.styleFrom(shadowColor: Colors.purple),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _updateLesson,
                    icon: Icon(Icons.check, color: Colors.white),
                    label: Text("確定"),
                    style: ElevatedButton.styleFrom(shadowColor: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
