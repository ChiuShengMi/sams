import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sams/pages/mainPages/homepage_admin.dart';
import 'package:sams/pages/mainPages/homepage_student.dart';
import 'package:sams/pages/mainPages/homepage_teacher.dart';
import 'package:sams/pages/loginPages/login.dart';
import 'package:sams/utils/firebase_auth.dart'; // 修正：FiresbaseAuthクラスをインポート
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase App',
      home: AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  final FiresbaseAuth _firebaseAuthService = FiresbaseAuth();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // ログインしている場合、ユーザーの役割を取得して適切なページに遷移
          return FutureBuilder<String>(
            future: _firebaseAuthService.getUserRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (roleSnapshot.hasError) {
                return Center(child: Text("エラー: ${roleSnapshot.error}"));
              } else if (roleSnapshot.hasData) {
                String role = roleSnapshot.data!;
                print("取得した役割: $role");

                // 正しいページに遷移
                if (role == "管理者") {
                  return HomePageAdmin();
                } else if (role == "学生") {
                  return HomePageStudent();
                } else if (role == "教師") {
                  return HomePageTeacher();
                } else {
                  return Center(child: Text("役割が見つかりませんでした"));
                }
              } else {
                // 役割が取得できない場合にローディング画面を表示
                return Center(child: CircularProgressIndicator());
              }
            },
          );
        } else {
          // ログインしていない場合、LoginPageに遷移
          return LoginPage();
        }
      },
    );
  }
}
