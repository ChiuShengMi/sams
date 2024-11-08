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

  String selectedRole = 'student';

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
        'CLASS': passwordConfirmInputController.text,
        'COURSE': 'IT', 
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
        collectionPath = 'Users/Students/IT';
      } else if (selectedRole == 'teacher') {
        collectionPath = 'Users/Teachers/IT';
      } else {
        collectionPath = 'Users/Managers';
      }

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
                              value: 'student',
                              child: Text('学生'),
                            ),
                            DropdownMenuItem(
                              value: 'teacher',
                              child: Text('教員'),
                            ),
                            DropdownMenuItem(
                              value: 'admin',
                              child: Text('管理者'),
                            ),
                          ],
                          onChanged: (value) {
                            selectedRole = value!;
                            print(" $selectedRole");
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
                          hintText: 'Select classGroup',
                          items: [
                            DropdownMenuItem(
                                value: 'class1', child: Text('Class 1')),
                            DropdownMenuItem(
                                value: 'class2', child: Text('Class 2')),
                          ],
                          onChanged: (value) {},
                        ),
                      ),
                    ],
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
