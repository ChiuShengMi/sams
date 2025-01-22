import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dummyData_Name.dart'; // generateJapaneseName 함수 import
import 'package:sams/utils/log.dart'; // Utils 클래스에서 logMessage를 가져옵니다

class DummyDataScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 중복된 이메일, 전화번호, ID, UID를 피하기 위한 Set
  Set<String> generatedEmails = Set();
  Set<String> generatedPhoneNumbers = Set();
  Set<int> generatedIds = Set();
  Set<String> generatedUids = Set();

  // 중복 데이터를 확인하는 함수
  Future<bool> checkForDuplicate(
      String email, String phoneNumber, int userId) async {
    // 이메일 중복 확인
    QuerySnapshot emailSnapshot = await _firestore
        .collection('Users/Students/IT')
        .where('MAIL', isEqualTo: email)
        .get();
    if (emailSnapshot.docs.isNotEmpty) {
      return true; // 이메일 중복
    }

    // 전화번호 중복 확인
    QuerySnapshot phoneSnapshot = await _firestore
        .collection('Users/Students/IT')
        .where('TEL', isEqualTo: phoneNumber)
        .get();
    if (phoneSnapshot.docs.isNotEmpty) {
      return true; // 전화번호 중복
    }

    // 유저 번호(ID) 중복 확인
    QuerySnapshot idSnapshot = await _firestore
        .collection('Users/Students/IT')
        .where('ID', isEqualTo: userId)
        .get();
    if (idSnapshot.docs.isNotEmpty) {
      return true; // 유저 번호 중복
    }

    return false; // 중복 없음
  }

  // 더미 데이터 생성 함수
  Future<void> generateDummyData(BuildContext context) async {
    for (int i = 0; i < 5; i++) {
      String email;
      String phoneNumber;
      int userId;

      // ID 생성: 22로 시작하고 뒤는 랜덤 숫자
      do {
        userId = int.parse(
            "22" + Random().nextInt(100000).toString().padLeft(5, '0'));
      } while (generatedIds.contains(userId));

      // 전화번호 생성: 080으로 시작하고 뒤는 랜덤
      do {
        phoneNumber =
            "080" + Random().nextInt(10000000).toString().padLeft(8, '0');
      } while (generatedPhoneNumbers.contains(phoneNumber));

      // 이메일 생성: 학적번호를 이메일 앞자리로 사용
      String emailDomain = "ecc.ac.jp";
      email = "$userId@$emailDomain"; // ID를 이메일 앞자리로 사용

      // 랜덤 일본인 이름 생성
      String fullName = generateJapaneseName(); // generateJapaneseName 사용

      // 중복 데이터가 없으면 Firestore에 저장
      bool isDuplicate = await checkForDuplicate(email, phoneNumber, userId);
      if (isDuplicate) {
        print('중복 데이터가 발견되어 건너뜁니다: $email, $phoneNumber, $userId');
        continue; // 중복 데이터가 있으면 건너뜁니다
      }

      try {
        // Firebase에서 UID 생성 (고유한 값)
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: "asd123", // 비밀번호는 "asd123"으로 통일
        );
        String uid = userCredential.user!.uid;

        // 학생 데이터 생성
        Map<String, dynamic> studentData = {
          'CLASS': 'SE2A', // 고정된 클래스
          'COURSE': 'IT', // 고정된 코스
          'CREATE_AT': Timestamp.now(),
          'DELETE_FLG': 0,
          'ID': userId,
          'JOB': '学生', // 학생으로 고정
          'MAIL': email,
          'NAME': fullName, // 랜덤 생성된 이름 사용
          'PHOTO': null, // 사진은 null로 고정
          'TEL': phoneNumber,
          'UID': uid,
        };

        // Firestore에 더미 데이터 저장
        await _firestore
            .collection('Users/Students/IT')
            .doc(uid)
            .set(studentData);

        // 생성된 이메일, 전화번호, ID를 중복 방지용 Set에 추가
        generatedEmails.add(email);
        generatedPhoneNumbers.add(phoneNumber);
        generatedIds.add(userId);
        generatedUids.add(uid);

        print("Student added: $email, $userId, $phoneNumber");

        // 로그 메시지 생성
        await Utils.logMessage(
            "$fullNameがダミーの$fullNameを${studentData['COURSE']}の${studentData['JOB']}として登録しました。");
      } catch (e) {
        print("Error creating user: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('ユーザー作成エラー: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ダミーデータ生成')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await generateDummyData(context); // context를 파라미터로 전달
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('ダミーデータ完了'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ));
          },
          child: Text('ダミーデータ生成'),
        ),
      ),
    );
  }
}
