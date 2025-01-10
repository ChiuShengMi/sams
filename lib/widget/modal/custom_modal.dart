import 'package:flutter/material.dart';
import 'modal_styles.dart';

class CustomModal extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  CustomModal({
    required this.title,
    required this.content,
    required this.onConfirm,
    this.onCancel, // 취소 콜백 추가
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        padding: const EdgeInsets.all(40.0),
        width: MediaQuery.of(context).size.width * 0.6,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              title,
              style: ModalStyles.modalTitleStyle,
            ),
            SizedBox(height: 8),
            Divider(thickness: 1, color: Colors.grey[300]),
            SizedBox(height: 20),

            // 내용
            Text(
              content,
              style: ModalStyles.modalContentStyle,
            ),
            SizedBox(height: 40),

            // 버튼 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ModalStyles.cancelButtonStyle,
                  onPressed: () {
                    Navigator.pop(context);
                    if (onCancel != null) onCancel!();
                  },
                  child: Text("キャンセル"),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  style: ModalStyles.modalButtonStyle,
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  child: Text("確認"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
