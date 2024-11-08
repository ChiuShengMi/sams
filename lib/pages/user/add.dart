import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/widget/actionbar.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/custom_input_container.dart';
import 'package:sams/widget/dropbox/custom_dropdown.dart';
import 'package:sams/widget/modal/confirmation_modal.dart';
import 'package:sams/widget/searchbar/custom_input.dart';

class UserAdd extends StatelessWidget {
  final TextEditingController loginEmailInputController =
      TextEditingController();
  final TextEditingController dataIdInputController = TextEditingController();
  final TextEditingController passwordInputController = TextEditingController();
  final TextEditingController passwordConfirmInputController =
      TextEditingController();
  final TextEditingController userNameInputController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController classInputController = TextEditingController();

  String selectedRole = 'student';
  String selectedCourse = 'IT';

  Future<void> _registerUser(BuildContext context) async {
    if (passwordInputController.text != passwordConfirmInputController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Passwords do not match!"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      Map<String, dynamic> userData = {
        'CLASS': classInputController.text,
        'COURSE': selectedCourse,
        'CREATE_AT': Timestamp.now(),
        'DELETE_FLG': 0,
        'ID': int.tryParse(dataIdInputController.text) ?? 0,
        'JOB': selectedRole == 'student'
            ? '学生'
            : (selectedRole == 'teacher' ? '教員' : '管理者'),
        'MAIL': loginEmailInputController.text,
        'NAME': userNameInputController.text,
        'PHOTO': null,
        'TEL': phoneNumberController.text,
      };

      String collectionPath;
      if (selectedRole == 'student') {
        collectionPath = 'Users/Students/$selectedCourse';
      } else if (selectedRole == 'teacher') {
        collectionPath = 'Users/Teachers/$selectedCourse';
      } else {
        collectionPath = 'Users/Managers';
      }

      print("Storing user in Firestore path: $collectionPath");
      print("User data: $userData");

      await FirebaseFirestore.instance.collection(collectionPath).add(userData);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User registered successfully!"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      String errorMessage = 'Failed to register user: $e';
      print(errorMessage);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
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
                title: 'User Add',
                inputWidgets: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 5,
                        child: CustomInput(
                          controller: loginEmailInputController,
                          hintText: 'Login E-mail',
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: Customdropdown(
                          hintText: 'Select property',
                          items: [
                            DropdownMenuItem(
                                value: 'student', child: Text('学生')),
                            DropdownMenuItem(
                                value: 'teacher', child: Text('教員')),
                            DropdownMenuItem(
                                value: 'admin', child: Text('管理者')),
                          ],
                          onChanged: (value) {
                            selectedRole = value!;
                            print("Selected role: $selectedRole");
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: CustomInput(
                          controller: dataIdInputController,
                          hintText: 'Data ID',
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: CustomInput(
                          controller: userNameInputController,
                          hintText: 'User Name',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: CustomInput(
                          controller: passwordInputController,
                          hintText: 'Password',
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: CustomInput(
                          controller: phoneNumberController,
                          hintText: 'Phone Number',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: CustomInput(
                          controller: passwordConfirmInputController,
                          hintText: 'Confirm Password',
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Customdropdown(
                          hintText: 'Select Course',
                          items: [
                            DropdownMenuItem(value: 'IT', child: Text('IT')),
                            DropdownMenuItem(
                                value: 'GAME', child: Text('GAME')),
                          ],
                          onChanged: (value) {
                            selectedCourse = value!;
                            print("Selected course: $selectedCourse");
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    controller: classInputController,
                    hintText: 'Class Name',
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
                    text: '確認',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ConfirmationModal(
                          onConfirm: () async {
                            Navigator.pop(context);
                            await _registerUser(context);
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
