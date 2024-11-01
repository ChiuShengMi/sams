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
