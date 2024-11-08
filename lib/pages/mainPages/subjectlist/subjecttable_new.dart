import 'package:flutter/material.dart';
import 'package:sams/pages/mainPages/subjectlist/subjecttable_new.dart';

class SubjecttableNew extends StatefulWidget {
  @override
  _SubjecttableNewState createState() => _SubjecttableNewState();
}

class _SubjecttableNewState extends State<SubjecttableNew> {
  // Define necessary controllers for input fields (e.g., for the new lesson form)
  late TextEditingController _classController;
  late TextEditingController _teacherController;
  late TextEditingController _dayController;
  late TextEditingController _timeController;
  late TextEditingController _classroomController;
  late TextEditingController _placeController;
  late TextEditingController _qrCodeController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _classController = TextEditingController();
    _teacherController = TextEditingController();
    _dayController = TextEditingController();
    _timeController = TextEditingController();
    _classroomController = TextEditingController();
    _placeController = TextEditingController();
    _qrCodeController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose controllers when done
    _classController.dispose();
    _teacherController.dispose();
    _dayController.dispose();
    _timeController.dispose();
    _classroomController.dispose();
    _placeController.dispose();
    _qrCodeController.dispose();
    super.dispose();
  }

  // Method to handle saving the new lesson data
  void _saveNewLesson() {
    // Your save logic goes here (e.g., saving to Firebase)
    print("New lesson saved: ${_classController.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("新しい授業作成"), // Title of the page
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _classController,
              decoration: InputDecoration(labelText: "授業名"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _teacherController,
              decoration: InputDecoration(labelText: "教師名"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _dayController,
              decoration: InputDecoration(labelText: "授業曜日"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(labelText: "時間割"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _classroomController,
              decoration: InputDecoration(labelText: "教室"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _placeController,
              decoration: InputDecoration(labelText: "号館"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _qrCodeController,
              decoration: InputDecoration(labelText: "QRコード"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveNewLesson, // Call the save method when pressed
              child: Text("保存"),
            ),
          ],
        ),
      ),
    );
  }
}
