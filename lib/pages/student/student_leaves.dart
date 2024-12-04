import 'package:flutter/foundation.dart'; // kIsWeb用
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sams/pages/mainPages/homepage_student.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/custom_input_container.dart';
import 'package:sams/widget/searchbar/custom_input.dart';
import 'package:sams/pages/mainPages/homepage_student.dart';

class StudentLeaves extends StatefulWidget {
  @override
  _StudentLeavesState createState() => _StudentLeavesState();
}

class _StudentLeavesState extends State<StudentLeaves> {
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  List<String> selectedDays = [];
  List<Map<String, dynamic>> classNames = []; // コース情報を保持するために更新
  List<Map<String, dynamic>> selectedClasses = []; // 選択されたコースを保持
  String? currentUserId;
  String? selectedCategory;
  String? selectedReason;
  String? userClass; // 現在のユーザーのクラスを保存
  String? userName; //username
  String? selectedCourse; // 選択されたコースタイプ（ITまたはGAME）を保存
  File? uploadedFile; // モバイル/デスクトップでファイルを保存
  Uint8List? uploadedFileData; // Web上でファイルデータを保存
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  // 日付を選択するための関数
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? now : (startDate ?? now),
      firstDate: isStart
          ? DateTime(2020)
          : (startDate != null ? startDate! : DateTime(2020)),
      lastDate: isStart
          ? DateTime(2030)
          : (startDate != null
              ? startDate!.add(Duration(days: 7))
              : DateTime(2030)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (endDate != null &&
              (endDate!.isBefore(startDate!) ||
                  endDate!.isAfter(startDate!.add(Duration(days: 7))))) {
            endDate = null;
          }
        } else {
          endDate = picked;
        }
        _calculateSelectedDays();
        _fetchClassesFromRealtimeDatabase();
      });
    }
  }

  // 選択された日付範囲の曜日を計算
  void _calculateSelectedDays() {
    if (startDate == null || endDate == null) return;

    List<String> days = ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日'];
    selectedDays.clear();
    DateTime currentDate = startDate!;

    while (currentDate.isBefore(endDate!.add(Duration(days: 1)))) {
      String dayOfWeek = days[currentDate.weekday - 1];
      if (!selectedDays.contains(dayOfWeek)) {
        selectedDays.add(dayOfWeek);
      }
      currentDate = currentDate.add(Duration(days: 1));
    }
  }

  // MIME タイプを設定してファイルをアップロード
  Future<String?> _uploadFileToStorage(String fileName) async {
    String? fileUrl; //
    try {
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('Leaves/$currentUserId/$fileName');

      if (kIsWeb && uploadedFileData != null) {
        // Web 環境
        await storageRef.putData(
          uploadedFileData!,
          SettableMetadata(contentType: 'image/jpeg'), // MIME
        );
        fileUrl = await storageRef.getDownloadURL();
      } else if (uploadedFile != null) {
        await storageRef.putFile(
          uploadedFile!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        fileUrl = await storageRef.getDownloadURL();
      }
    } catch (e) {
      print('ファイルアップロード中にエラーが発生しました: $e');
    }
    return fileUrl;
  }

  // Realtime Databaseからクラス情報を取得
  Future<void> _fetchClassesFromRealtimeDatabase() async {
    if (selectedDays.isEmpty || currentUserId == null) return;

    List<Map<String, dynamic>> matchingClasses = [];

    DatabaseReference itRef = FirebaseDatabase.instance.ref("CLASS/IT");
    DatabaseEvent itEvent = await itRef.once();
    matchingClasses.addAll(_getMatchingClasses(itEvent.snapshot, "IT"));

    DatabaseReference gameRef = FirebaseDatabase.instance.ref("CLASS/GAME");
    DatabaseEvent gameEvent = await gameRef.once();
    matchingClasses.addAll(_getMatchingClasses(gameEvent.snapshot, "GAME"));

    await _fetchClassNamesFromFirestore(matchingClasses);
  }

  // 指定されたスナップショットから一致するクラス情報を取得
  List<Map<String, dynamic>> _getMatchingClasses(
      DataSnapshot snapshot, String course) {
    List<Map<String, dynamic>> classes = [];
    for (var child in snapshot.children) {
      String classId = child.key ?? "";
      Map<String, dynamic> data = Map<String, dynamic>.from(child.value as Map);

      if (selectedDays.contains(data['DAY'])) {
        int time = int.tryParse(data['TIME'].toString()) ?? 0;
        classes.add({
          'id': classId,
          'day': data['DAY'],
          'time': time,
          'course': course
        });
      }
    }
    return classes;
  }

  // Firestoreからクラス名を取得
  Future<void> _fetchClassNamesFromFirestore(
      List<Map<String, dynamic>> classes) async {
    List<Map<String, dynamic>> fetchedClassNames = [];

    for (var classInfo in classes) {
      String classId = classInfo['id'];
      String course = classInfo['course'];
      String day = classInfo['day'];
      int time = classInfo['time'];

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Class')
          .doc(course)
          .collection('Subjects')
          .doc(classId)
          .get();

      if (doc.exists) {
        bool isEnrolled = false;

        Map<String, dynamic> students = doc['STD'] as Map<String, dynamic>;

        for (var student in students.values) {
          if (student['UID'] == currentUserId) {
            isEnrolled = true;
            userClass = student['CLASS'];
            userName = student['NAME'];
            break;
          }
        }

        if (isEnrolled) {
          String className = doc['CLASS'];
          String timeFormatted = '${time}限目';
          String formattedClass = '$className - $day - $timeFormatted';
          fetchedClassNames.add({
            'id': classId,
            'name': formattedClass,
            'selected': false,
            'day': day, // 後で使用するために曜日を含める
            'className': className, // 授業名をここに保存
          });
        }
      }
    }

    setState(() {
      classNames = fetchedClassNames;
    });
  }

  // クラスの選択を確定
  void _confirmSelection() {
    setState(() {
      selectedClasses =
          classNames.where((classItem) => classItem['selected']).toList();
      classNames.clear();
    });
  }

  // クラスの選択をリセット
  void _resetSelection() {
    setState(() {
      classNames.forEach((classItem) => classItem['selected'] = false);
      selectedClasses.clear();
      _fetchClassesFromRealtimeDatabase();
    });
  }

  // 画像ファイルを選択
  Future<void> _pickFile() async {
    final picker = ImagePicker();
    if (kIsWeb) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final fileData = await pickedFile.readAsBytes();
        setState(() {
          uploadedFileData = fileData;
        });
      }
    } else {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          uploadedFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _submitLeaveRequest() async {
    // 開始日、終了日、選択したクラス、またはカテゴリが未設定の場合、エラーを表示
    if (startDate == null ||
        endDate == null ||
        selectedClasses.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('未完成の欄位が存在します。すべての必須項目を記入してください。')),
      );
      return;
    }

    // 理由または備考が未入力の場合、エラーメッセージを表示
    if ((selectedCategory != 'その他' &&
            (selectedReason == null || selectedReason!.isEmpty)) ||
        (selectedCategory == 'その他' && (remarksController.text.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('理由または備考を記入してください。')),
      );
      return;
    }

    // 現在の日時を使用してユニークなファイル名を作成
    String timestamp =
        DateTime.now().toLocal().toString().replaceAll(':', '').split('.')[0];
    String fileName = '$timestamp.jpg';

    // ファイルをアップロードし、URLを取得
    String? fileUrl = await _uploadFileToStorage(fileName);

    // 選択されたクラスごとに休暇データを作成し、Firestoreに保存
    for (var classItem in selectedClasses) {
      String classId = classItem['id'];
      String className = classItem['className']; // クラス名を取得
      String day = classItem['day'];
      DateTime leaveDate = _getCorrectLeaveDate(day); // 正しい日付を取得

      // Firestoreコレクションへの参照を取得
      CollectionReference leaveCollection =
          FirebaseFirestore.instance.collection('Leaves');

      // 新しいドキュメントIDを作成
      QuerySnapshot leaveDocs = await leaveCollection.get();
      String leaveId =
          'Leaves_${(leaveDocs.docs.length + 1).toString().padLeft(3, '0')}';

      // 休暇データを作成
      Map<String, dynamic> leaveData = {
        'CLASS_ID': classId, // クラスID
        'CLASS_NAME': className, // クラス名
        'USER_CLASS': userClass, // ユーザークラス
        'FILE': fileUrl, // アップロードされたファイルのURL
        'LEAVE_DATE':
            '${leaveDate.year}-${leaveDate.month}-${leaveDate.day}', // 休暇日
        'LEAVE_CATEGORY': selectedCategory, // カテゴリ（欠席、遅刻など）
        'LEAVE_REASON': selectedReason, // 理由
        'LEAVE_STATUS': 0, // ステータス（0 = 未承認）
        'LEAVE_TEXT': remarksController.text, // 備考
        'USER_UID': currentUserId, // ユーザーUID
        'USER_NAME': userName, // ユーザー名
        'APPROVER': null,
      };

      // Firestoreにデータを保存
      await leaveCollection.doc(leaveId).set(leaveData);
    }

    // フォームデータをリセット
    setState(() {
      startDate = null;
      endDate = null;
      selectedCategory = null;
      selectedReason = null;
      remarksController.clear();
      uploadedFile = null;
      uploadedFileData = null;
      selectedClasses.clear();
    });

    // 成功メッセージを表示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('申請が成功しました')),
    );
  }

  // 正しい休暇日を取得
  DateTime _getCorrectLeaveDate(String day) {
    List<String> days = ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日'];
    int dayIndex = days.indexOf(day) + 1;

    DateTime currentDate = startDate!;
    while (currentDate.isBefore(endDate!.add(Duration(days: 1)))) {
      if (currentDate.weekday == dayIndex) {
        return currentDate;
      }
      currentDate = currentDate.add(Duration(days: 1));
    }

    return startDate!; // ここに到達することは基本的にないはず
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
              Text(
                '休暇届出',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Divider(color: Colors.grey, thickness: 1.5, height: 15.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '休暇期間を選択してください:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _selectDate(context, true),
                                icon: Icon(Icons.calendar_today),
                                label: Text('開始日を選択'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                ),
                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "選択された開始日:",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    startDate != null
                                        ? "${startDate!.year}/${startDate!.month}/${startDate!.day}"
                                        : "未選択",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _selectDate(context, false),
                                icon: Icon(Icons.calendar_today),
                                label: Text('終了日を選択'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                ),
                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "選択された終了日:",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    endDate != null
                                        ? "${endDate!.year}/${endDate!.month}/${endDate!.day}"
                                        : "未選択",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (classNames.isNotEmpty)
                Column(
                  children: [
                    ...classNames.map((classItem) {
                      return CheckboxListTile(
                        title: Text(classItem['name']),
                        value: classItem['selected'],
                        onChanged: (bool? value) {
                          setState(() {
                            classItem['selected'] = value ?? false;
                          });
                        },
                      );
                    }).toList(),
                    CustomButton(
                      onPressed: _confirmSelection,
                      text: '確定',
                    ),
                  ],
                ),
              if (selectedClasses.isNotEmpty) ...[
                Text(
                  '選択された授業：',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                if (classNames.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '授業を選択してください：',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: classNames.map((classItem) {
                            return CheckboxListTile(
                              title: Text(
                                classItem['name'],
                                style: TextStyle(fontSize: 16),
                              ),
                              value: classItem['selected'],
                              onChanged: (bool? value) {
                                setState(() {
                                  classItem['selected'] = value ?? false;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: _confirmSelection,
                          icon: Icon(Icons.check),
                          label: Text('確定'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ...selectedClasses.map((classItem) {
                  return Text(
                    classItem['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  );
                }).toList(),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton.icon(
                  onPressed: _resetSelection,
                  icon: Icon(Icons.refresh),
                  label: Text('選びなおす'),
                ),
              ],
              SizedBox(height: 20),
              // CustomButton(
              //   onPressed: _pickFile,
              //   text: 'ファイル追加',
              // ),
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF7B1FA2),
                        Color(0xFF7B1FA2)
                      ], // Gradient colors
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // Shadow position
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _pickFile,
                      borderRadius: BorderRadius.circular(12),
                      splashColor: Colors.white.withOpacity(0.2),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                        child: Text(
                          'ファイル追加',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (uploadedFile != null || uploadedFileData != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'ファイルが追加されました',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: '種別選択',
                  labelStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                value: selectedCategory,
                icon: Icon(Icons.arrow_drop_down, size: 24),
                iconEnabledColor: Colors.blueAccent,
                dropdownColor: Colors.white,
                items: ['欠席', '遅刻', '早退', 'その他']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            style: TextStyle(fontSize: 14),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                    selectedReason = null;
                  });
                },
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              SizedBox(
                height: 5,
              ),
              if (selectedCategory == '欠席' || selectedCategory == '遅刻') ...[
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: '理由',
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: selectedReason,
                  items: ['学校行事', '法定伝染病', '結婚式', '忌引', 'その他']
                      .map((reason) => DropdownMenuItem(
                            value: reason,
                            child: Text(reason),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedReason = value;
                    });
                  },
                ),
              ] else if (selectedCategory == '早退') ...[
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: '理由'),
                  value: selectedReason,
                  items: ['学校行事', '法定伝染病', '結婚式', '忌引', 'その他']
                      .map((reason) => DropdownMenuItem(
                            value: reason,
                            child: Text(reason),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedReason = value;
                    });
                  },
                ),
              ],
              if (selectedCategory != null) ...[
                SizedBox(height: 5),
                // TextField(
                //   controller: remarksController,
                //   decoration: InputDecoration(labelText: '備考'),
                //   maxLines: 3,
                // ),
                TextField(
                  controller: remarksController,
                  decoration: InputDecoration(
                    labelText: '備考',
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Colors.blue, width: 2), // Focused border color
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8), // Padding inside the text field
                  ),
                  maxLines: 3, // Allow up to 3 lines of text
                  keyboardType:
                      TextInputType.multiline, // Support multiline input
                  textInputAction: TextInputAction
                      .newline, // Ensure the Enter key moves to the next line
                ),
              ],
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: CustomButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePageStudent(),
                            ),
                          );
                        },
                        text: '戻る',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: CustomButton(
                        onPressed: _submitLeaveRequest,
                        text: '申請を提出',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
