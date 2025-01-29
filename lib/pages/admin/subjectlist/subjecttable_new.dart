import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/pages/admin/subjectlist/subjecttable.dart';

import 'package:sams/utils/firebase_firestore.dart';
import 'package:sams/utils/firebase_realtime.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/custom_input_container.dart';
import 'package:sams/widget/searchbar/custom_input.dart';
import 'package:sams/widget/bottombar.dart';

import 'package:sams/utils/log.dart';

class SubjecttableNew extends StatefulWidget {
  @override
  _SubjecttableNewState createState() => _SubjecttableNewState();
}

class _SubjecttableNewState extends State<SubjecttableNew> {
  final TextEditingController classController = TextEditingController();
  final TextEditingController classroomController = TextEditingController();

  String? selectedCourse;
  String? selectedPlace;
  String? selectedDay;
  String? selectedTime;
  List<String?> selectedTeacherIds = [null];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final RealtimeDatabaseService _realtimeDatabaseService =
      RealtimeDatabaseService();

  List<String> teacherNames = [];
  Map<String, String> teacherMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    try {
      final names = await _firestoreService.fetchTeachers(teacherMap);
      setState(() {
        teacherNames = names;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching teachers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateLeaveStatus(BuildContext context, int status) async {
    try {
      // ログインユーザーのUIDを取得
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('ユーザーがログインしていません');
      final uid = user.uid;

      // FirestoreでUIDを使用して管理者情報を取得（ITとGAME両方を検索）
      DocumentSnapshot? managerSnapshot;
      managerSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc('Managers')
          .collection('IT')
          .doc(uid)
          .get();

      if (!managerSnapshot.exists) {
        managerSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc('Managers')
            .collection('GAME')
            .doc(uid)
            .get();
      }

      if (!managerSnapshot.exists) {
        throw Exception('管理者情報が見つかりません');
      }

      final managerData = managerSnapshot.data() as Map<String, dynamic>;
      final userData = {
        'UID': uid,
        'ID': managerData['ID'].toString(),
        'NAME': managerData['NAME'],
      };
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラーが発生しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //SizedBox(height: 20),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '新しい授業作成',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomButton(
                            text: 'キャンセル',
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SubjectTable(),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            width: 90,
                          ),
                          CustomButton(
                            text: '確定',
                            onPressed: _showConfirmationDialog,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                //SizedBox(height: 5),

                // Scrollable content area
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 1.0),
                    child: CustomInputContainer(
                      inputWidgets: [
                        CustomInput(
                          controller: classController,
                          hintText: 'クラス名',
                          keyboardType: TextInputType.name,
                        ),
                        SizedBox(height: 16),
                        Customdropdown(
                          items: ['IT', 'GAME'],
                          value: selectedCourse,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCourse = newValue;
                            });
                          },
                          hintText: 'コースを選択',
                        ),
                        SizedBox(height: 16),
                        ...selectedTeacherIds.asMap().entries.map((entry) {
                          int index = entry.key;
                          return Column(
                            children: [
                              Customdropdown(
                                items: teacherNames,
                                value: selectedTeacherIds[index],
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedTeacherIds[index] = newValue;
                                  });
                                },
                                hintText: '教師を選択',
                              ),
                              SizedBox(height: 8),
                            ],
                          );
                        }).toList(),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedTeacherIds.add(null);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 18), // Plus arrow icon
                              SizedBox(width: 8), // Space between icon and text
                              Text('追加の教員'),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Customdropdown(
                          items: [
                            '月曜日',
                            '火曜日',
                            '水曜日',
                            '木曜日',
                            '金曜日',
                            '土曜日',
                            '日曜日'
                          ],
                          value: selectedDay,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDay = newValue;
                            });
                          },
                          hintText: '曜日を選択',
                        ),
                        SizedBox(height: 16),
                        Customdropdown(
                          items: ['1', '2', '3', '4', '5'],
                          value: selectedTime,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedTime = newValue;
                            });
                          },
                          hintText: '時間を選択',
                        ),
                        SizedBox(height: 16),
                        CustomInput(
                          controller: classroomController,
                          hintText: '教室名',
                          keyboardType: TextInputType.name,
                        ),
                        SizedBox(height: 16),
                        Customdropdown(
                          items: [
                            '国際１号館',
                            '国際2号館',
                            '国際3号館',
                            '1号館',
                            '2号館',
                            '3号館',
                            '4号館'
                          ],
                          value: selectedPlace,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedPlace = newValue;
                            });
                          },
                          hintText: '場所を選択',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomBar(),
    );
  }

  Future<void> _submitClassData() async {
    if (classController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('クラス名を入力してください')),
      );
      return;
    }

    if (selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('コースを選択してください')),
      );
      return;
    }

    if (selectedTeacherIds.every((id) => id == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('少なくとも1人の教師を選択してください')),
      );
      return;
    }

    if (selectedDay == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('曜日と時間を選択してください')),
      );
      return;
    }

    if (classroomController.text.isEmpty || selectedPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('教室名と場所を選択してください')),
      );
      return;
    }

    try {
      // get login user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('ユーザーがログインしていません');
      final uid = user.uid;

      // get user data
      DocumentSnapshot? managerSnapshot;
      managerSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc('Managers')
          .collection('IT')
          .doc(uid)
          .get();

      if (!managerSnapshot.exists) {
        managerSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc('Managers')
            .collection('GAME')
            .doc(uid)
            .get();
      }

      if (!managerSnapshot.exists) {
        throw Exception('管理者情報が見つかりません');
      }

      final managerData = managerSnapshot.data() as Map<String, dynamic>;
      final userId = managerData['ID'];
      final userName = managerData['NAME'];

      // 授業データを保存
      String course = selectedCourse!;
      String classId = await _realtimeDatabaseService.generateClassId(course);

      Map<String, dynamic> teacherData = {};
      selectedTeacherIds.where((id) => id != null).forEach((id) {
        String cleanedTeacherName =
            id!.replaceFirst(RegExp(r'^(IT|GAME) - '), '');
        if (teacherMap.containsKey(cleanedTeacherName)) {
          String teacherUid = teacherMap[cleanedTeacherName]!;
          teacherData[teacherUid] = {'NAME': cleanedTeacherName};
        }
      });

      // String qrCode = "https://example.com/qr/$classId";

      await _realtimeDatabaseService.saveClassData(course, classId, {
        'CLASS': classController.text,
        'TEACHER_ID': teacherData,
        'DAY': selectedDay,
        'TIME': selectedTime,
        'CLASSROOM': classroomController.text,
        'PLACE': selectedPlace,
        // 'QR_CODE': qrCode,
      });

      // Log に保存
      await Utils.logMessage(
        '$userName-$userId が新しい授業（${classController.text}） を追加しました。',
      );

      // 成功メッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('授業が正常に作成されました'),
          backgroundColor: Colors.green,
        ),
      );

      _clearForm();
    } catch (e) {
      // エラーメッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('授業の作成中にエラーが発生しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    classController.clear();
    classroomController.clear();
    setState(() {
      selectedCourse = null;
      selectedPlace = null;
      selectedDay = null;
      selectedTime = null;
      selectedTeacherIds = [null];
    });
  }

  Future<void> _showConfirmationDialog() async {
    // 教師名の処理を改善
    String teacherDisplay = selectedTeacherIds.any((id) => id != null)
        ? selectedTeacherIds
            .where((id) => id != null)
            .map((id) {
              if (id != null) {
                // 先頭の "IT - " や "GAME - " を削除
                return id.replaceFirst(RegExp(r'^(IT|GAME) - '), '');
              }
              return '';
            })
            .where((name) => name.isNotEmpty)
            .join('、')
        : '未選択';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '入力内容の確認',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildConfirmationField('クラス名', classController.text),
                _buildConfirmationField('コース', selectedCourse ?? '未選択'),
                _buildConfirmationField('教師', teacherDisplay),
                _buildConfirmationField('曜日', selectedDay ?? '未選択'),
                _buildConfirmationField('時間', selectedTime ?? '未選択'),
                _buildConfirmationField('教室名', classroomController.text),
                _buildConfirmationField('場所', selectedPlace ?? '未選択'),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                iconColor: Color(0xFF7B1FA2), // 背景色
                padding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10), // テキスト色
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('戻る'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                iconColor: Color(0xFF7B1FA2),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text('確定'),
              onPressed: () {
                Navigator.of(context).pop();
                _submitClassData();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfirmationField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Divider(height: 1),
        ],
      ),
    );
  }
}

class Customdropdown extends StatelessWidget {
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String hintText;

  const Customdropdown({
    required this.items,
    required this.value,
    required this.onChanged,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    print('利用可能な教師名: $items');
    return InputDecorator(
      decoration: InputDecoration(
        labelText: hintText,
        border: OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }
}
