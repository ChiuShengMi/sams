import 'package:flutter/material.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'modal_styles.dart';

class CustomModal extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm; // onConfirm 콜백 추가

  CustomModal({
    required this.title,
    required this.content,
    required this.onConfirm, // onConfirm 사용
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
            Text(
              title,
              style: ModalStyles.modalTitleStyle,
            ),
            SizedBox(height: 8),
            Divider(thickness: 1, color: Colors.grey[300]),
            SizedBox(height: 20),
            Text(
              content,
              style: ModalStyles.modalContentStyle,
            ),
            SizedBox(height: 80),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MediumButton(
                    text: '確認',
                    onPressed: () {
                      onConfirm(); // 데이터베이스에 저장 실행
                      Navigator.of(context).pop(); // 모달 닫기
                    },
                  ),
                  SizedBox(width: 8),
                  MediumButton(
                    text: 'キャンセル',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
