import 'package:flutter/material.dart';
import 'custom_modal.dart';

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
