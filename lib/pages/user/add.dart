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

  // Firestore에 유저 데이터를 추가하는 메서드
  Future<void> _addUserToDatabase(BuildContext context) async {
    if (passwordInputController.text != passwordConfirmInputController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Passwords do not match!"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      // Firestore에 저장할 유저 데이터
      Map<String, dynamic> userData = {
        'email': loginEmailInputController.text,
        'dataId': dataIdInputController.text,
        'userName': userNameInputController.text,
        'phoneNumber': phoneNumberController.text,
        'classGroup': passwordConfirmInputController.text,
      };

      await FirebaseFirestore.instance.collection('Users').add(userData);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User added successfully!"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to add user: $e"),
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
                          onChanged: (value) {},
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
                              value: 'class1',
                              child: Text('Class 1'),
                            ),
                            DropdownMenuItem(
                              value: 'class2',
                              child: Text('Class 2'),
                            ),
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
                      // 확인 모달을 표시하고, 확인 버튼이 눌리면 Firebase에 유저 추가
                      showDialog(
                        context: context,
                        builder: (context) => ConfirmationModal(
                          onConfirm: () =>
                              _addUserToDatabase(context), // 데이터베이스 등록
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
