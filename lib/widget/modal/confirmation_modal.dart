import 'package:flutter/material.dart';
import 'custom_modal.dart';

class ConfirmationModal extends StatelessWidget {
  final VoidCallback onConfirm;

  ConfirmationModal({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return CustomModal(
      title: "お知らせ",
      content: "上記の内容で登録しますか？",
      onConfirm: onConfirm, // onConfirm 전달
    );
  }
}
