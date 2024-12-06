import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sams/utils/log.dart';

class LeaveEditPage extends StatelessWidget {
  final Map<String, dynamic> leaveDetails;

  const LeaveEditPage({super.key, required this.leaveDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('休暇資料編集画面'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左側：詳細情報
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
                  const SizedBox(width: 40), // 左右間隔
                  // 右側：画像と備考
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
                        Align(
                          alignment: Alignment.center,
                          child: Row(
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 下方のボタン
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      _confirmAction(context, '休暇不承認しますか？', 2);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 19, 19, 19),
                    ),
                    child: const Text('不承認'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      _confirmAction(context, '休暇を承認しますか？', 1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(79, 190, 198, 205),
                    ),
                    child: const Text('承認'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
      final approver = {
        'UID': uid,
        'ID': managerData['ID'].toString(),
        'NAME': managerData['NAME'],
      };

      await Utils.logMessage(
        '${managerData['NAME']}が${leaveDetails['USER_NAME']}の休暇を変動しました。',
      );

      // 申請データを更新
      String leaveId = leaveDetails['LEAVE_ID'];
      await FirebaseFirestore.instance.collection('Leaves').doc(leaveId).update(
        {
          'LEAVE_STATUS': status,
          'APPROVER': approver,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(status == 1 ? '承認しました' : '不承認にしました')),
      );

      // 前のページに戻る際にリフレッシュを指示
      Navigator.of(context).pop('refresh');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラーが発生しました: $e')),
      );
    }
  }

  // 確認ダイアログを表示する
  void _confirmAction(BuildContext context, String message, int status) {
    showDialog(
      context: context,
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
                _updateLeaveStatus(context, status); // 状態を更新する
              },
              child: const Text('はい'),
            ),
          ],
        );
      },
    );
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
