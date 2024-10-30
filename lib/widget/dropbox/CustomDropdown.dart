import 'package:flutter/material.dart';
import './dropbox_styles.dart';

enum DropboxSize { small, medium, large }

class Customdropdown extends StatelessWidget {
  final String hintText;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final String? value;
  final DropboxSize size;

  Customdropdown(
      {required this.hintText,
      required this.items,
      required this.onChanged,
      this.value,
      this.size = DropboxSize.medium});

  @override
  Widget build(BuildContext context) {
    final double width = getWidthForSize(size);
    final EdgeInsets padding = getPaddingForSize(size);

    return Container(
        width: width,
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: DropboxStyles.dropdownDecoration.copyWith(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey),
              contentPadding: padding),
          style: DropboxStyles.dropdownItemStyle,
          items: items,
          onChanged: onChanged,
          dropdownColor: Colors.white,
        ));
  }

  double getWidthForSize(DropboxSize size) {
    switch (size) {
      case DropboxSize.small:
        return 100.0;
      case DropboxSize.medium:
        return 200.0;
      case DropboxSize.large:
        return 300.0;
      default:
        return 200.0;
    }
  }

  EdgeInsets getPaddingForSize(DropboxSize size) {
    switch (size) {
      case DropboxSize.small:
        return EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0);
      case DropboxSize.medium:
        return EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0);
      case DropboxSize.large:
        return EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0);
      default:
        return EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0);
    }
  }
}
