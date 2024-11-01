import 'package:flutter/material.dart';
import 'package:sams/widget/actionbar.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/custom_input_container.dart';
import 'package:sams/widget/dropbox/custom_dropdown.dart';
import 'package:sams/widget/searchbar/custom_input.dart';

class UserAdd extends StatelessWidget {
  final TextEditingController loginEmailInputController =
      TextEditingController(); // Login E-mail Id
  final TextEditingController dataIdInputController =
      TextEditingController(); // Data Id
  final TextEditingController passwordInputController =
      TextEditingController(); // Password
  final TextEditingController passwordConfirmInputController =
      TextEditingController(); // Password Confirm
  final TextEditingController userNameInputController =
      TextEditingController(); // User Name
  final TextEditingController phoneNumberController =
      TextEditingController(); // Phone Number

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
                  CustomButton(text: '戻る', onPressed: () {}),
                  SizedBox(width: 16),
                  CustomButton(text: '確認', onPressed: () {}),
                  SizedBox(width: 16),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
