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
import 'package:sams/utils/log.dart'; // Utils 클래스에서 로그 기능을 사용
import 'classLists.dart';

class UserAdd extends StatefulWidget {
  @override
  _UserAddState createState() => _UserAddState();
}

class _UserAddState extends State<UserAdd> {
  final TextEditingController loginEmailInputController =
      TextEditingController();
  final TextEditingController dataIdInputController = TextEditingController();
  final TextEditingController passwordInputController = TextEditingController();
  final TextEditingController passwordConfirmInputController =
      TextEditingController();
  final TextEditingController userNameInputController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController classInputController = TextEditingController();

  Future<bool> _checkForDuplicates(BuildContext context) async {
    try {
      print("重複データ確認開始");

      String basePath;
      if (selectedRole == 'student') {
        basePath = 'Users/Students/$selectedCourse';
      } else if (selectedRole == 'teacher') {
        basePath = 'Users/Teachers/$selectedCourse';
      } else {
        basePath = 'Users/Managers';
      }

      QuerySnapshot emailSanpshot = await FirebaseFirestore.instance
          .collection(basePath)
          .where('MAIL', isEqualTo: loginEmailInputController.text.trim())
          .get();

      if (emailSanpshot.docs.isNotEmpty) {
        print("重複されたe-mailを検知");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("既に存在するメールです。"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ));
        return true;
      }
      QuerySnapshot idSnapshot = await FirebaseFirestore.instance
          .collection(basePath)
          .where('ID', isEqualTo: int.tryParse(dataIdInputController.text))
          .get();

      if (idSnapshot.docs.isNotEmpty) {
        print("重複されたID検知");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('ユーザ番号が既に存在します。'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ));
        return true;
      }

      QuerySnapshot phoneSnapshot = await FirebaseFirestore.instance
          .collection(basePath)
          .where('TEL', isEqualTo: phoneNumberController.text.trim())
          .get();
      if (phoneSnapshot.docs.isNotEmpty) {
        print("重複された電話番号検知");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("この携帯番号は既に存在します。"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ));
        return true;
      }
      print("重複無し");
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("エラーが発生しました。: $e"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
      return true;
    }
  }

  String selectedRole = 'student';
  String selectedCourse = 'IT';
  String? seletedClass;

  Future<void> _registerUser(BuildContext context) async {
    bool hasDuplicates = await _checkForDuplicates(context);
    if (hasDuplicates) {
      return;
    }

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

    if (passwordInputController.text != passwordConfirmInputController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("パスワードが一致しません。"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
      return;
    }

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      String adminName = "Unknown Admin";

      if (currentUser != null) {
        DocumentSnapshot adminDoc = await FirebaseFirestore.instance
            .collection('Users/Managers/IT') // 관리자 경로를 프로젝트에 맞게 수정
            .doc(currentUser.uid)
            .get();

        if (adminDoc.exists) {
          adminName = adminDoc.get('NAME') ?? "Unknown Admin";
        }
      }

      final UserCredential authResult =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: loginEmailInputController.text.trim(),
        password: passwordInputController.text.trim(),
      );

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
        'UID': authResult.user!.uid,
      };

      String collectionPath;
      if (selectedRole == 'student') {
        collectionPath = 'Users/Students/$selectedCourse';
      } else if (selectedRole == 'teacher') {
        collectionPath = 'Users/Teachers/$selectedCourse';
      } else {
        collectionPath = 'Users/Managers';
      }

      await FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(authResult.user!.uid)
          .set(userData);

      // Firestore에 로그 추가
      await Utils.logMessage(
          "$adminNameが${userData['NAME']}を${selectedCourse}の${userData['JOB']}として登録しました。");

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
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\$');
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
                title: 'ユーザ登録',
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
                            hintText: 'ログインE-mail',
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
                          hintText: '種類',
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
                          hintText: 'ユーザ番号',
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
                          hintText: '名前',
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
                          hintText: 'パスワード',
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: CustomInput(
                          controller: phoneNumberController,
                          hintText: '携帯番号',
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
                            hintText: 'パスワードをもう一度入力してください',
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Customdropdown(
                          hintText: 'コースを選択してください。',
                          items: [
                            DropdownMenuItem(value: 'IT', child: Text('IT')),
                            DropdownMenuItem(
                                value: 'GAME', child: Text('GAME')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedCourse = value!;
                              seletedClass = null;
                              print("Selected course: $selectedCourse");
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Customdropdown(
                              hintText: 'クラスを選択してください。',
                              items: ClassLists.getClassesByCourse(
                                      selectedCourse)
                                  .map((className) => DropdownMenuItem<String>(
                                        value: className,
                                        child: Text(className),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  seletedClass = value!;
                                  classInputController.text = value;
                                });
                              }))
                    ],
                  )
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
                    onPressed: () async {
                      print('確認ボタン、クリック');

                      bool hasDuplicates = await _checkForDuplicates(context);
                      if (hasDuplicates) {
                        print("重複されたデータにより登録中断");
                        return;
                      }

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
                        print("空欄があるたる登録中断");
                        return;
                      }
                      print("登録ロジック実行準備");
                      showDialog(
                        context: context,
                        builder: (context) => ConfirmationModal(
                          onConfirm: () async {
                            Navigator.pop(context);
                            print("登録開始");
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
