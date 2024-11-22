import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication 추가
import 'package:sams/widget/actionbar.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/custom_input_container.dart';
import 'package:sams/widget/dropbox/custom_dropdown.dart';
import 'package:sams/widget/searchbar/custom_input.dart';
import 'package:sams/widget/modal/confirmation_modal.dart';

class SubjecttableNew extends StatelessWidget {
  final TextEditingController classController = TextEditingController();
  final TextEditingController teacherController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController classroomController = TextEditingController();
  final TextEditingController courseController = TextEditingController();
  final TextEditingController placeController = TextEditingController();

  Future<void> _registerLesson(BuildContext context) async {
    // Validate fields
    if (classController.text.isEmpty ||
        teacherController.text.isEmpty ||
        dayController.text.isEmpty ||
        timeController.text.isEmpty ||
        classroomController.text.isEmpty ||
        placeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("すべてのフィールドを入力してください。"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
      return;
    }
    // Add logic to register the lesson
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
                    hintText: 'コース',
                    items: [
                      DropdownMenuItem(value: 'IT', child: Text('IT')),
                      DropdownMenuItem(value: 'GAME', child: Text('GAME')),
                    ],
                    onChanged: (value) {
                      courseController.text = value.toString();
                    },
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    controller: teacherController,
                    hintText: '教師名',
                    keyboardType: TextInputType.name,
                    InputFormatter: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    ],
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    controller: dayController,
                    hintText: '授業曜日',
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    controller: timeController,
                    hintText: '教室',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  Customdropdown(
                    hintText: '時間割',
                    items: List.generate(
                        5,
                        (index) => DropdownMenuItem(
                              value: (index + 1).toString(),
                              child: Text('${index + 1}'),
                            )),
                    onChanged: (value) {
                      timeController.text = value.toString();
                    },
                  ),
                  SizedBox(height: 16),
                  Customdropdown(
                    hintText: '教室',
                    items: [
                      DropdownMenuItem(value: '国際1号館', child: Text('国際1号館')),
                      DropdownMenuItem(value: '国際2号館', child: Text('国際2号館')),
                      DropdownMenuItem(value: '国際3号館', child: Text('国際3号館')),
                      DropdownMenuItem(value: '1号館', child: Text('1号館')),
                      DropdownMenuItem(value: '2号館', child: Text('2号館')),
                      DropdownMenuItem(value: '3号館', child: Text('3号館')),
                      DropdownMenuItem(value: '4号館', child: Text('4号館')),
                    ],
                    onChanged: (value) {
                      placeController.text = value.toString();
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: '戻る',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 16),
                  CustomButton(
                    text: '確認',
                    onPressed: () {
                      _registerLesson(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
