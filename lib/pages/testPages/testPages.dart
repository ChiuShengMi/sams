import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreのパッケージをインポート
import 'package:firebase_database/firebase_database.dart';
import 'package:sams/pages/loginPages/login.dart';
import 'package:sams/pages/testPages/testPages_link.dart';
class TestPage extends StatelessWidget {

  // ログアウトメソッド
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();  // FirebaseAuth の signOut メソッドを使ってログアウト
      // ログアウト後、ログインページに戻る
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('ログアウトエラー: $e');  // エラーハンドリング
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
    List<String?> selectedTeacherIds = [null]; // 複数の教師を選択するリスト

    List<String> teacherNames = [];
    Map<String, String> teacherMap = {};  // 教師UIDと教師名を保存するマップ

    // Firestoreから教師のデータを取得
    Future<void> fetchTeachers() async {
      QuerySnapshot itTeachers = await FirebaseFirestore.instance
          .collection('Users')
          .doc('Teachers')
          .collection('IT')
          .get();
      QuerySnapshot gameTeachers = await FirebaseFirestore.instance
          .collection('Users')
          .doc('Teachers')
          .collection('GAME')
          .get();

      for (var doc in itTeachers.docs) {
        teacherMap[doc['NAME']] = doc.id; // 教師名をキー、UIDを値に保存
        teacherNames.add('IT - ${doc['NAME']}');
      }
      for (var doc in gameTeachers.docs) {
        teacherMap[doc['NAME']] = doc.id; // 教師名をキー、UIDを値に保存
        teacherNames.add('GAME - ${doc['NAME']}');
      }
    }

    // 授業IDを生成する
    Future<String> generateClassId(String course) async {
      DatabaseReference dbRef = FirebaseDatabase.instance.ref(); // reference()からref()に変更
      DatabaseEvent event = await dbRef.child('CLASS/$course').once();
      DataSnapshot snapshot = event.snapshot; // DatabaseEventからDataSnapshotを取得
      int nextId = 1;

      if (snapshot.value != null) {
        Map<dynamic, dynamic> classes = snapshot.value as Map<dynamic, dynamic>; // キャスト
        List<String> ids = classes.keys.map((key) => key.toString()).toList();
        ids.sort();
        String lastId = ids.last;
        nextId = int.parse(lastId.split('_').last) + 1;
      }

      return '${course.toUpperCase()}_subject_${nextId.toString().padLeft(3, '0')}';
    }


    // ダイアログを表示する際に教師情報を取得
    await fetchTeachers();

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
                          selectedTeacherIds.add(null); // 新しいSelectBoxを追加
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
                        '１号館', '2号館', '3号館', '4号館'
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
                    Navigator.of(context).pop();  // 破棄
                  },
                  child: Text('破棄'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      print("確定ボタンが押されました");

                      // クラスIDの生成
                      if (classController.text.isNotEmpty && selectedCourse != null) {
                        String course = selectedCourse == 'IT' ? 'IT' : 'GAME';
                        String classId = await generateClassId(course);

                        print("生成されたクラスID: $classId");

                        // デバッグ: teacherMap の内容を確認
                        print("teacherMapの内容: $teacherMap");

                        // 教師の UID と名前を保存するための Map を準備
                        Map<String, dynamic> teacherData = {};

                        // 教師の名前を UID に変換し、UID に対応する名前も保存
                        selectedTeacherIds.where((id) => id != null).forEach((id) {
                          // "IT - " または "GAME - " を取り除く
                          String cleanedTeacherName = id!.replaceFirst(RegExp(r'^(IT|GAME) - '), '');

                          print("選択された教師名 (加工後): $cleanedTeacherName"); // デバッグ: 選択された教師名をプリント
                          
                          if (teacherMap.containsKey(cleanedTeacherName)) {
                            String teacherUid = teacherMap[cleanedTeacherName]!;
                            print("対応するUID: $teacherUid"); // デバッグ: 取得したUIDをプリント
                            teacherData[teacherUid] = {
                              'NAME': cleanedTeacherName  // UID の下に名前を保存
                            };
                          } else {
                            print("教師のUIDが見つかりませんでした: $cleanedTeacherName");
                          }
                        });

                        print("保存する教師データ: $teacherData");

                        // QRコードの生成ロジック（ここでは仮の値を使用）
                        String qrCode = "https://example.com/qr/$classId"; // 仮のQRコードURL

                        // Realtime Database への保存
                        DatabaseReference dbRef = FirebaseDatabase.instance.ref();

                        // 非同期処理が完了するまで待機
                        await dbRef.child('CLASS/$course/$classId').set({
                          'CLASS': classController.text,
                          'TEACHER_ID': teacherData, // 教師の UID と名前を保存
                          'DAY': selectedDay,
                          'TIME': selectedTime,
                          'CLASSROOM': classroomController.text,
                          'PLACE': selectedPlace,
                          'QR_CODE': qrCode, // QRコードのURLを保存
                        });

                        print('データが保存されました');
                        Navigator.of(context).pop();  // ダイアログを閉じる
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
    String errorMessage = ''; // エラーメッセージ用の変数

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
                      items: ['教師', '学生', '管理者'].map<DropdownMenuItem<String>>((String value) {
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
                      items: ['IT', 'GAME'].map<DropdownMenuItem<String>>((String value) {
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
                    if (errorMessage.isNotEmpty) // エラーメッセージがある場合のみ表示
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
                    Navigator.of(context).pop();  // 破棄
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
                      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                      String uid = userCredential.user!.uid;

                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(job == '教師' ? 'Teachers' : job == '学生' ? 'Students' : 'Managers')
                          .collection(course == 'IT' ? 'IT' : 'GAME')
                          .doc(uid)
                          .set({
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
                      });

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
                _showAddUserDialog(context);  // ユーザ追加ダイアログを表示
              },
              child: Text('ユーザ追加'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showAddClassDialog(context);  // 授業追加ダイアログを表示
              },
              child: Text('授業追加'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TestPageLink()), // 遷移先を指定
                );
              },
              child: Text('授業と学生紐付け'),
            ),
          ],
        ),
      ),
    );
  }
}
