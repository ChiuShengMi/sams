import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sams/pages/mainPages/homepage_admin.dart';
import 'firebase_options.dart';
import './pages/mainPages/homepage_admin.dart'; // Homeページのパスを設定
import './pages/loginPages/login.dart'; // Loginページのパスを設定

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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // ユーザーのログイン状態を監視
      builder: (context, snapshot) {
        // ログイン状態を確認
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // ログインしている場合、HomePageに遷移
          return HomePageAdmin();
        } else {
          // ログインしていない場合、LoginPageに遷移
          return LoginPage();
        }
      },
    );
  }
}
