import 'package:flutter/material.dart';
import 'custom_modal.dart';

class DeleteModalSubEdit extends StatelessWidget {
  final VoidCallback onConfirmDelete;

  const DeleteModalSubEdit({required this.onConfirmDelete});

  @override
  Widget build(BuildContext context) {
    return CustomModal(
      title: "削除", // 제목
      content: "このユーザーを削除しますか？", // 내용
      onConfirm: onConfirmDelete, // 확인 버튼 콜백
      onCancel: () {
        print("削除がキャンセルされました");
      },
    );
  }
}
