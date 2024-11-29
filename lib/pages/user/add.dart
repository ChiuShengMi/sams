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
    // 필드 검증
    if (loginEmailInputController.text.isEmpty ||
        dataIdInputController.text.isEmpty ||
        passwordInputController.text.isEmpty ||
        passwordConfirmInputController.text.isEmpty ||
        userNameInputController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        classInputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("모든 필드를 입력해주세요."),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
      return;
    }

    // 비밀번호 일치 여부 확인
    if (passwordInputController.text != passwordConfirmInputController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Passwords do not match!"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
      return;
    }

    try {
      // Firebase Authentication 계정 생성
      final UserCredential authResult =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: loginEmailInputController.text.trim(),
        password: passwordInputController.text.trim(),
      );

      // Firestore에 사용자 데이터 저장
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
        'UID': authResult.user!.uid, // Authentication UID
      };

      String collectionPath;
      if (selectedRole == 'student') {
        collectionPath = 'Users/Students/$selectedCourse';
      } else if (selectedRole == 'teacher') {
        collectionPath = 'Users/Teachers/$selectedCourse';
      } else {
        collectionPath = 'Users/Managers';
      }

      // Authentication UID를 Firestore 문서 ID로 설정
      await FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(authResult.user!.uid) // UID 사용
          .set(userData); // 데이터 저장

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User registered successfully!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      String errorMessage = 'Failed to register user: $e';
      print(errorMessage);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
  }

  bool _isValidEmail(String value) {
    final RegExp emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegExp.hasMatch(value);
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
                        child: Focus(
                          onFocusChange: (hasFocus) {
                            if (!hasFocus &&
                                !_isValidEmail(
                                    loginEmailInputController.text)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('有効なE-mail形式で入力してください。'),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: CustomInput(
                            controller: loginEmailInputController,
                            hintText: 'Login E-mail',
                            keyboardType: TextInputType.emailAddress,
                            InputFormatter: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9@._-]'))
                            ],
                          ),
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
                          keyboardType: TextInputType.number,
                          InputFormatter: [
                            FilteringTextInputFormatter.allow(RegExp(r'\d'))
                          ],
                          onChanged: (value) {
                            if (value.length > 7) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("IDは最長7桁まで入力可能です。"),
                                duration: Duration(seconds: 1),
                              ));
                              dataIdInputController.text =
                                  value.substring(0, 7);
                              dataIdInputController.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset:
                                          dataIdInputController.text.length));
                            }
                          },
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
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: CustomInput(
                          controller: phoneNumberController,
                          hintText: 'Phone Number',
                          keyboardType: TextInputType.number,
                          InputFormatter: [
                            FilteringTextInputFormatter.allow(RegExp(r'\d'))
                          ],
                          onChanged: (value) {
                            if (value.length > 11) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("電話番号は11桁以内で入力してください。"),
                                duration: Duration(seconds: 1),
                                backgroundColor: Colors.red,
                              ));
                              phoneNumberController.text =
                                  value.substring(0, 11);
                              phoneNumberController.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset:
                                          phoneNumberController.text.length));
                            }
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
                        child: Focus(
                          onFocusChange: (hasFocus) {
                            if (!hasFocus &&
                                passwordConfirmInputController.text !=
                                    passwordInputController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('パスワードが一致してません。'),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: CustomInput(
                            controller: passwordConfirmInputController,
                            hintText: 'Confirm Password',
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                          ),
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
                      if (loginEmailInputController.text.isEmpty ||
                          dataIdInputController.text.isEmpty ||
                          passwordInputController.text.isEmpty ||
                          passwordConfirmInputController.text.isEmpty ||
                          userNameInputController.text.isEmpty ||
                          phoneNumberController.text.isEmpty ||
                          classInputController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("入力されてない欄があります。"),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ));
                        return;
                      }
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
