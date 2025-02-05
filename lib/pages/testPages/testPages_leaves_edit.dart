import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sams/utils/log.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/widget/button/custom_button.dart';

class LeaveEditPage extends StatelessWidget {
  final Map<String, dynamic> leaveDetails;

  const LeaveEditPage({super.key, required this.leaveDetails});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  // SizedBox(width: 15),
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
                        detailRow('授業名', leaveDetails['CLASS_NAME']),
                        detailRow('授業ID', leaveDetails['CLASS_ID']),
                        detailRow('申請者', leaveDetails['USER_NAME']),
                        detailRow('申請別', leaveDetails['LEAVE_CATEGORY']),
                        detailRow('申請日付', leaveDetails['LEAVE_DATE']),
                        detailRow('理由', leaveDetails['LEAVE_REASON']),
                        detailRow(
                          '審査者',
                          leaveDetails['APPROVER'] != null &&
                                  leaveDetails['APPROVER']
                                      is Map<String, dynamic>
                              ? '${leaveDetails['APPROVER']['NAME'] ?? ''}-${leaveDetails['APPROVER']['ID'] ?? ''}'
                              : '',
                        ),
                        detailRow(
                          '申請状態',
                          leaveDetails['LEAVE_STATUS'] == 0
                              ? '未承認'
                              : (leaveDetails['LEAVE_STATUS'] == 1
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
                        if (leaveDetails['FILE'] != null &&
                            leaveDetails['FILE'] != '' &&
                            leaveDetails['FILE'] != 'null')
                          GestureDetector(
                            onTap: () {
                              _showImageDialog(context, leaveDetails['FILE']);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: _buildImageWidget(leaveDetails['FILE']),
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
                                leaveDetails['LEAVE_TEXT'] ?? '不明',
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
                    _confirmAction(context, '休暇不承認しますか？', 2);
                  },
                ),
                SizedBox(width: 10),
                CustomButton(
                  text: '承認',
                  onPressed: () {
                    _confirmAction(context, '休暇を承認しますか？', 1);
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

  void _confirmAction(BuildContext rootContext, String message, int status) {
    showDialog(
      context: rootContext,
      builder: (context) {
        return AlertDialog(
          title: const Text('確認'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('いいえ'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateLeaveStatus(rootContext, status); // rootContext を渡す
              },
              child: const Text('はい'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateLeaveStatus(BuildContext rootContext, int status) async {
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
        '${managerData['NAME']}が${leaveDetails['USER_NAME']}の休暇を変動しました。',
      );

      String leaveId = leaveDetails['LEAVE_ID'];
      await FirebaseFirestore.instance.collection('Leaves').doc(leaveId).update(
        {
          'LEAVE_STATUS': status,
          'APPROVER': approver,
        },
      );

      if (status == 1 || status == 2) {
        final leaveDate = leaveDetails['LEAVE_DATE'];
        final userUid = leaveDetails['USER_UID'];
        final classType =
            leaveDetails['CLASS_NAME'].contains('GAME') ? 'GAME' : 'IT';
        final classID = leaveDetails['CLASS_ID'];

        final ref = FirebaseDatabase.instance.ref(
          'ATTENDANCE/$classType/$classID/$leaveDate/$userUid/',
        );

        await ref.update({
          'APPROVE': status,
        });
      }

      // SnackBar を表示
      ScaffoldMessenger.of(rootContext).showSnackBar(
        SnackBar(
          content: Text(status == 1 ? '承認しました' : '不承認にしました'),
          backgroundColor:
              status == 1 ? Colors.green : Colors.red, // ✅ 状態に応じて色を変更
        ),
      );

      // 画面を閉じる
      Navigator.of(rootContext).pop('refresh');
    } catch (e) {
      ScaffoldMessenger.of(rootContext).showSnackBar(
        SnackBar(content: Text('エラーが発生しました: $e')),
      );
    }
  }

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
