import 'package:flutter/material.dart';
import 'custom_modal.dart';
import 'package:sams/pages/mainPages/subjectlist/subjecttable_edit.dart';

class ConfirmationModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomModal(
        title: "Modal Title",
        content: "Lorem ipsum dolor sit amet",
        onPressed: () {
          Navigator.of(context).pop();
        });
  }
}

class EditModalSubEdit extends StatelessWidget {
  final VoidCallback onConfirmEdit;

  const EditModalSubEdit({required this.onConfirmEdit});

  Widget build(BuildContext context) {
    return CustomModal(
        title: "変更の確認",
        content: "授業リストを編集しますか?",
        onPressed: () {
          Navigator.of(context).pop();
        });
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
        onPressed: () {
          Navigator.of(context).pop();
        });
  }
  // Widget build(BuildContext context) {
  //   return AlertDialog(
  //     title: Text("削除しますか？"),
  //     content: Text('data'),
  //     actions: [
  //       TextButton(
  //         onPressed: () => Navigator.of(context).pop(),
  //         child: Text('data'),
  //       ),
  //       TextButton(
  //         onPressed: onConfirmDelete,
  //         child: Text('data'),
  //       )
  //     ],
  //   );
  // }
}
