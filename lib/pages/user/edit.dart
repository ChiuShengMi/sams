import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/widget/actionbar.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/custom_input_container.dart';
import 'package:sams/widget/dropbox/custom_dropdown.dart';
import 'package:sams/widget/searchbar/custom_input.dart';
import 'package:sams/pages/user/list.dart'; // UserList 페이지를 import

class UserEdit extends StatelessWidget {
  final String documentPath;
  final TextEditingController loginEmailInputController;
  final TextEditingController dataIdInputController;
  final TextEditingController userNameInputController;
  final TextEditingController phoneNumberController;
  final TextEditingController classInputController;
  String selectedRole;
  String selectedCourse;

  UserEdit({
    Key? key,
    required this.documentPath,
    required String loginEmail,
    required String dataId,
    required String userName,
    required String phoneNumber,
    required String className,
    required String role,
    required String course,
  })  : loginEmailInputController = TextEditingController(text: loginEmail),
        dataIdInputController = TextEditingController(text: dataId),
        userNameInputController = TextEditingController(text: userName),
        phoneNumberController = TextEditingController(text: phoneNumber),
        classInputController = TextEditingController(text: className),
        selectedRole = role,
        selectedCourse = course,
        super(key: key);

  Future<void> _updateUser(BuildContext context) async {
    try {
      Map<String, dynamic> updatedData = {
        'MAIL': loginEmailInputController.text,
        'ID': int.tryParse(dataIdInputController.text) ?? 0,
        'NAME': userNameInputController.text,
        'TEL': phoneNumberController.text,
        'CLASS': classInputController.text,
        'JOB': selectedRole,
        'COURSE': selectedCourse,
      };

      await FirebaseFirestore.instance.doc(documentPath).update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User updated successfully!"),
        backgroundColor: Colors.green,
      ));

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => UserList()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to update user: $e"),
        backgroundColor: Colors.red,
      ));
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
            children: [
              Actionbar(children: []),
              CustomInputContainer(
                title: 'Edit User',
                inputWidgets: [
                  CustomInput(
                      controller: loginEmailInputController,
                      hintText: 'Login E-mail'),
                  SizedBox(height: 16),
                  CustomInput(
                      controller: dataIdInputController, hintText: 'Data ID'),
                  SizedBox(height: 16),
                  CustomInput(
                      controller: userNameInputController,
                      hintText: 'User Name'),
                  SizedBox(height: 16),
                  CustomInput(
                      controller: phoneNumberController,
                      hintText: 'Phone Number'),
                  SizedBox(height: 16),
                  CustomInput(
                      controller: classInputController, hintText: 'Class Name'),
                  SizedBox(height: 16),
                  Customdropdown(
                    hintText: 'Select Role',
                    items: [
                      DropdownMenuItem(value: '学生', child: Text('学生')),
                      DropdownMenuItem(value: '教員', child: Text('教員')),
                      DropdownMenuItem(value: '管理者', child: Text('管理者')),
                    ],
                    value: selectedRole,
                    onChanged: (value) {
                      selectedRole = value!;
                    },
                  ),
                  SizedBox(height: 16),
                  Customdropdown(
                    hintText: 'Select Course',
                    items: [
                      DropdownMenuItem(value: 'IT', child: Text('IT')),
                      DropdownMenuItem(value: 'GAME', child: Text('GAME')),
                    ],
                    value: selectedCourse,
                    onChanged: (value) {
                      selectedCourse = value!;
                    },
                  ),
                ],
              ),
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
                    text: '保存',
                    onPressed: () => _updateUser(context),
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