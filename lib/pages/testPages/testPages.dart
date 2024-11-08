import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sams/utils/firebase_firestore.dart';
import 'package:sams/utils/firebase_realtime.dart';
import 'package:sams/pages/loginPages/login.dart';
import 'package:sams/pages/testPages/testPages_leaves.dart';
import 'package:sams/pages/testPages/testPages_link.dart';

class TestPage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();
  final RealtimeDatabaseService _realtimeDatabaseService = RealtimeDatabaseService();

  // ログアウトメソッド
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('ログアウトエラー: $e');
    }
  }

  // 授業追加ダイアログ
  Future<void> _showAddClassDialog(BuildContext context) async {
    TextEditingController classController = TextEditingController();
    TextEditingController classroomController = TextEditingController();
    String? selectedCourse;
    String? selectedPlace;
    String? selectedDay;
    String? selectedTime;
    List<String?> selectedTeacherIds = [null];

    List<String> teacherNames = [];
    Map<String, String> teacherMap = {};

    await _firestoreService.fetchTeachers(teacherMap).then((names) {
      teacherNames = names;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('授業追加'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: classController,
                      decoration: InputDecoration(labelText: 'Class Name'),
                    ),
                    ...selectedTeacherIds.asMap().entries.map((entry) {
                      int index = entry.key;
                      return DropdownButtonFormField<String>(
                        value: selectedTeacherIds[index],
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedTeacherIds[index] = newValue;
                          });
                        },
                        items: teacherNames.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(labelText: 'Teacher'),
                      );
                    }).toList(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedTeacherIds.add(null);
                        });
                      },
                      child: Text('追加の教師を選択'),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedDay,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDay = newValue;
                        });
                      },
                      items: ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(labelText: 'Day'),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedTime,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedTime = newValue;
                        });
                      },
                      items: ['1', '2', '3', '4', '5'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(labelText: 'Time'),
                    ),
                    TextField(
                      controller: classroomController,
                      decoration: InputDecoration(labelText: 'Classroom'),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedCourse,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCourse = newValue;
                        });
                      },
                      items: ['IT', 'GAME'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(labelText: 'Course'),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedPlace,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedPlace = newValue;
                        });
                      },
                      items: [
                        '国際１号館', '国際2号館', '国際3号館',
                        '1号館', '2号館', '3号館', '4号館'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(labelText: 'Place'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('破棄'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      print("確定ボタンが押されました");

                      if (classController.text.isNotEmpty && selectedCourse != null) {
                        String course = selectedCourse!;
                        String classId = await _realtimeDatabaseService.generateClassId(course);

                        Map<String, dynamic> teacherData = {};
                        selectedTeacherIds.where((id) => id != null).forEach((id) {
                          String cleanedTeacherName = id!.replaceFirst(RegExp(r'^(IT|GAME) - '), '');
                          if (teacherMap.containsKey(cleanedTeacherName)) {
                            String teacherUid = teacherMap[cleanedTeacherName]!;
                            teacherData[teacherUid] = {'NAME': cleanedTeacherName};
                          }
                        });

                        String qrCode = "https://example.com/qr/$classId";

                        await _realtimeDatabaseService.saveClassData(course, classId, {
                          'CLASS': classController.text,
                          'TEACHER_ID': teacherData,
                          'DAY': selectedDay,
                          'TIME': selectedTime,
                          'CLASSROOM': classroomController.text,
                          'PLACE': selectedPlace,
                          'QR_CODE': qrCode,
                        });

                        print('データが保存されました');
                        Navigator.of(context).pop();
                      } else {
                        print("クラス名かコースが空です");
                      }
                    } catch (e) {
                      print("エラー: $e");
                    }
                  },
                  child: Text('確定'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ユーザ追加ダイアログ
  Future<void> _showAddUserDialog(BuildContext context) async {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    String? job;
    TextEditingController classController = TextEditingController();
    String? course;
    TextEditingController idController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController telController = TextEditingController();
    String errorMessage = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('新規ユーザ追加'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                    ),
                    TextField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(labelText: 'Confirm Password'),
                    ),
                    DropdownButtonFormField<String>(
                      value: job,
                      onChanged: (String? newValue) {
                        setState(() {
                          job = newValue;
                        });
                      },
                      items: ['教師', '学生', '管理者']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(labelText: 'Job'),
                    ),
                    TextField(
                      controller: classController,
                      decoration: InputDecoration(labelText: 'Class'),
                    ),
                    DropdownButtonFormField<String>(
                      value: course,
                      onChanged: (String? newValue) {
                        setState(() {
                          course = newValue;
                        });
                      },
                      items: ['IT', 'GAME']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(labelText: 'Course'),
                    ),
                    TextField(
                      controller: idController,
                      decoration: InputDecoration(labelText: 'ID'),
                    ),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: telController,
                      decoration: InputDecoration(labelText: 'TEL'),
                    ),
                    if (errorMessage.isNotEmpty)
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('破棄'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (passwordController.text != confirmPasswordController.text) {
                      setState(() {
                        errorMessage = 'パスワードが一致しません';
                      });
                      return;
                    }

                    try {
                      // Firestoreにユーザデータを追加するg前にエラーチェック
                      Map<String, dynamic> userData = {
                        'CLASS': classController.text,
                        'COURSE': course,
                        'CREATE_AT': Timestamp.now(),
                        'DELETE_FLG': 0,
                        'ID': int.parse(idController.text),
                        'JOB': job,
                        'MAIL': emailController.text,
                        'NAME': nameController.text,
                        'PHOTO': null,
                        'TEL': telController.text,
                      };

                      // Firestoreにユーザデータを追加
                      await _firestoreService.addUser(
                          job ?? '学生', course ?? 'IT', '', userData);

                      // Firebase Authのユーザー作成はデータ保存が成功した場合のみ実行
                      UserCredential userCredential = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                      String uid = userCredential.user!.uid;

                      // Firestoreにユーザデータを保存
                      await _firestoreService.addUser(
                          job ?? '学生', course ?? 'IT', uid, userData);

                      Navigator.of(context).pop();
                      print('ユーザが作成されました');
                    } catch (e) {
                      setState(() {
                        errorMessage = 'エラー: $e';
                      });
                    }
                  },
                  child: Text('確定'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _showAddUserDialog(context);
              },
              child: Text('ユーザ追加'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showAddClassDialog(context);
              },
              child: Text('授業追加'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TestPageLink()),
                );
              },
              child: Text('授業と学生紐付け'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TestPageLeaves()),
                );
              },
              child: Text('休暇届出'),
            ),
          ],
        ),
      ),
    );
  }
}
