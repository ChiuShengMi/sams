import 'package:flutter/material.dart';
import 'custom_modal.dart';
import 'package:sams/pages/mainPages/subjectlist/subjecttable_edit.dart';

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

class EditModalSubEdit extends StatelessWidget {
  final VoidCallback onConfirmEdit;
  final String title;
  final String content;

  //const EditModalSubEdit({required this.onConfirmEdit});
  const EditModalSubEdit(
      {required this.title,
      required this.content,
      required this.onConfirmEdit});

  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("変更の確認"),
      content: Text("授業リストを編集しますか?"),
      actions: [
        TextButton(
          child: Text("キャンセル"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text("確認"),
          onPressed: () {
            onConfirmEdit();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class DeleteModalSubEdit extends StatelessWidget {
  final VoidCallback onConfirmDelete;

  const DeleteModalSubEdit({required this.onConfirmDelete});

  @override
  Widget build(BuildContext context) {
    return CustomModal(
      title: "削除",
      content: "削除しますか？?",
      onConfirm: onConfirmDelete,
    );
  }
}
