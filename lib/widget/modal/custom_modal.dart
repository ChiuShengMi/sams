import 'package:flutter/material.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'modal_styles.dart';

class CustomModal extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  CustomModal({
    required this.title,
    required this.content,
    required this.onConfirm,
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
              child: MediumButton(
                text: '確定',
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
