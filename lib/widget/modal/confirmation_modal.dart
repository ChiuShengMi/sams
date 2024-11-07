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

class ConfirmationModalSubEdit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomModal(
        title: "授業リスト編集",
        content: "授業リスト変更しますか",
        onPressed: () {
          Navigator.of(context).pop();
        });
  }
}

class DeleteModalSubEdit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomModal(
        title: "授業リスト削除",
        content: "授業リスト削除しますか",
        onPressed: () {
          Navigator.of(context).pop();
        });
  }
}
