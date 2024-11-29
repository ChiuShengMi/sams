import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
                          '申請状態',
                          leaveDetails['LEAVE_STATUS'] == 0 ? '未承認' : '承認済み',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40), // 左右間隔
                  // 右側：圖片和備考
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
            // 右下方的按鈕
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 取消按鈕
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 19, 19, 19),
                    ),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 16),
                  // 保存按鈕
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(79, 190, 198, 205),
                    ),
                    child: const Text('保存'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
    return Text(
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
