import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sams/utils/log.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/widget/button/custom_button.dart';

class LeaveEditPage extends StatefulWidget {
  final Map<String, dynamic> leaveDetails;

  const LeaveEditPage({super.key, required this.leaveDetails});

  @override
  _LeaveEditPageState createState() => _LeaveEditPageState();
}

class _LeaveEditPageState extends State<LeaveEditPage> {
  bool isLeaveUpdated = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                      '休暇資料編集',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
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
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Details
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        detailRow('授業名', widget.leaveDetails['CLASS_NAME']),
                        detailRow('授業ID', widget.leaveDetails['CLASS_ID']),
                        detailRow('申請者', widget.leaveDetails['USER_NAME']),
                        detailRow('申請別', widget.leaveDetails['LEAVE_CATEGORY']),
                        detailRow('申請日付', widget.leaveDetails['LEAVE_DATE']),
                        detailRow('理由', widget.leaveDetails['LEAVE_REASON']),
                        detailRow(
                          '審査者',
                          widget.leaveDetails['APPROVER'] != null &&
                                  widget.leaveDetails['APPROVER']
                                      is Map<String, dynamic>
                              ? '${widget.leaveDetails['APPROVER']['NAME'] ?? ''}-${widget.leaveDetails['APPROVER']['ID'] ?? ''}'
                              : '',
                        ),
                        detailRow(
                          '申請状態',
                          widget.leaveDetails['LEAVE_STATUS'] == 0
                              ? '未承認'
                              : (widget.leaveDetails['LEAVE_STATUS'] == 1
                                  ? '承認済み'
                                  : '却下'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  // Right Column: Image and Notes
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (widget.leaveDetails['FILE'] != null &&
                            widget.leaveDetails['FILE'] != '' &&
                            widget.leaveDetails['FILE'] != 'null')
                          GestureDetector(
                            onTap: () {
                              _showImageDialog(
                                  context, widget.leaveDetails['FILE']);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: _buildImageWidget(
                                  widget.leaveDetails['FILE']),
                            ),
                          ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '備考: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                widget.leaveDetails['LEAVE_TEXT'] ?? '不明',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Show confirmation message if leave status is updated
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  text: '不承認',
                  onPressed: () {
                    // _confirmAction(context, '休暇不承認しますか？', 2);
                    _updateLeaveStatus(context, 2);
                  },
                ),
                SizedBox(width: 10),
                CustomButton(
                  text: '承認',
                  onPressed: () {
                    //_confirmAction(context, '休暇を承認しますか？', 1);
                    _updateLeaveStatus(context, 1);
                  },
                ),
              ],
            ),
          ),
          BottomBar(),
        ],
      ),
    );
  }

  Future<void> _updateLeaveStatus(BuildContext context, int status) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('ユーザーがログインしていません');
      final uid = user.uid;

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
      final approver = {
        'UID': uid,
        'ID': managerData['ID'].toString(),
        'NAME': managerData['NAME'],
      };

      await Utils.logMessage(
        '${managerData['NAME']}が${widget.leaveDetails['USER_NAME']}の休暇を変動しました。',
      );

      String leaveId = widget.leaveDetails['LEAVE_ID'];
      await FirebaseFirestore.instance.collection('Leaves').doc(leaveId).update(
        {
          'LEAVE_STATUS': status,
          'APPROVER': approver,
        },
      );

      if (status == 1) {
        final leaveDate = widget.leaveDetails['LEAVE_DATE'];
        final userUid = widget.leaveDetails['USER_UID'];
        final classType =
            widget.leaveDetails['CLASS_NAME'].contains('GAME') ? 'GAME' : 'IT';
        final classID = widget.leaveDetails['CLASS_ID'];

        final ref = FirebaseDatabase.instance.ref(
          'ATTENDANCE/$classType/$classID/$leaveDate/$userUid/',
        );

        await ref.update({
          'APPROVE': 1,
        });
      }

      if (status == 2) {
        final leaveDate = widget.leaveDetails['LEAVE_DATE'];
        final userUid = widget.leaveDetails['USER_UID'];
        final classType =
            widget.leaveDetails['CLASS_NAME'].contains('GAME') ? 'GAME' : 'IT';
        final classID = widget.leaveDetails['CLASS_ID'];

        final ref = FirebaseDatabase.instance.ref(
          'ATTENDANCE/$classType/$classID/$leaveDate/$userUid/',
        );

        await ref.update({
          'APPROVE': 2,
        });
      }

      setState(() {
        isLeaveUpdated = true; // Flag to show the confirmation message
      });

      // `ScaffoldMessenger.of(context)` биш, `ScaffoldMessengerKey` ашиглах
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(status == 1 ? '承認しました' : '不承認にしました')),
      );

      Navigator.of(context).pop('refresh');
    } catch (e) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('エラーが発生しました: $e')),
      );
    }
  }
  // Future<void> _updateLeaveStatus(BuildContext context, int status) async {
  //   try {
  //     final user = FirebaseAuth.instance.currentUser;
  //     if (user == null) throw Exception('ユーザーがログインしていません');
  //     final uid = user.uid;

  //     DocumentSnapshot? managerSnapshot;
  //     managerSnapshot = await FirebaseFirestore.instance
  //         .collection('Users')
  //         .doc('Managers')
  //         .collection('IT')
  //         .doc(uid)
  //         .get();

  //     if (!managerSnapshot.exists) {
  //       managerSnapshot = await FirebaseFirestore.instance
  //           .collection('Users')
  //           .doc('Managers')
  //           .collection('GAME')
  //           .doc(uid)
  //           .get();
  //     }

  //     if (!managerSnapshot.exists) {
  //       throw Exception('管理者情報が見つかりません');
  //     }

  //     final managerData = managerSnapshot.data() as Map<String, dynamic>;
  //     final approver = {
  //       'UID': uid,
  //       'ID': managerData['ID'].toString(),
  //       'NAME': managerData['NAME'],
  //     };

  //     await Utils.logMessage(
  //       '${managerData['NAME']}が${widget.leaveDetails['USER_NAME']}の休暇を変動しました。',
  //     );

  //     String leaveId = widget.leaveDetails['LEAVE_ID'];
  //     await FirebaseFirestore.instance.collection('Leaves').doc(leaveId).update(
  //       {
  //         'LEAVE_STATUS': status,
  //         'APPROVER': approver,
  //       },
  //     );

  //     if (status == 1) {
  //       final leaveDate = widget.leaveDetails['LEAVE_DATE'];
  //       final userUid = widget.leaveDetails['USER_UID'];
  //       final classType =
  //           widget.leaveDetails['CLASS_NAME'].contains('GAME') ? 'GAME' : 'IT';
  //       final classID = widget.leaveDetails['CLASS_ID'];

  //       final ref = FirebaseDatabase.instance.ref(
  //         'ATTENDANCE/$classType/$classID/$leaveDate/$userUid/',
  //       );

  //       await ref.update({
  //         'APPROVE': 1,
  //       });
  //     }

  //     if (status == 2) {
  //       final leaveDate = widget.leaveDetails['LEAVE_DATE'];
  //       final userUid = widget.leaveDetails['USER_UID'];
  //       final classType =
  //           widget.leaveDetails['CLASS_NAME'].contains('GAME') ? 'GAME' : 'IT';
  //       final classID = widget.leaveDetails['CLASS_ID'];

  //       final ref = FirebaseDatabase.instance.ref(
  //         'ATTENDANCE/$classType/$classID/$leaveDate/$userUid/',
  //       );

  //       await ref.update({
  //         'APPROVE': 2,
  //       });
  //     }

  //     setState(() {
  //       isLeaveUpdated = true; // Flag to show the confirmation message
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(status == 1 ? '承認しました' : '不承認にしました')),
  //     );

  //     Navigator.of(context).pop('refresh');
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('エラーが発生しました: $e')),
  //     );
  //   }
  // }

  // void _confirmAction(BuildContext context, String message, int status) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('確認'),
  //         content: Text(message),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('いいえ'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               _updateLeaveStatus(context, status);
  //             },
  //             child: const Text('はい'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildImageWidget(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    try {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        height: 150,
        width: 150,
        fit: BoxFit.contain,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) {
          _logImageError(error, null, imageUrl);
          return _buildErrorWidget();
        },
      );
    } catch (error, stackTrace) {
      _logImageError(error, stackTrace, imageUrl);
      return _buildErrorWidget();
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) {
              _logImageError(error, null, imageUrl);
              return _buildErrorWidget();
            },
          ),
        ),
      ),
    );
  }

  void _logImageError(Object error, StackTrace? stackTrace, String imageUrl) {
    debugPrint('画像読み込みエラー: $error');
    if (stackTrace != null) debugPrint('スタックトレース: $stackTrace');
    debugPrint('画像URL: $imageUrl');
  }

  Widget _buildErrorWidget() {
    return const Text(
      '添付ファイルなし',
      style: TextStyle(fontSize: 12, color: Colors.black54),
    );
  }

  Widget detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value ?? '不明',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
