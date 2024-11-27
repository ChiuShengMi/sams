import 'package:flutter/material.dart';
import './dropbox_styles.dart';

enum DropboxSize { small, medium, large }

class Customdropdown extends StatelessWidget {
  final String hintText;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final String? value;
  final DropboxSize size;

  Customdropdown({
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.value,
    this.size = DropboxSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final double width = getWidthForSize(size);

    return Container(
      width: width,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: DropboxStyles.dropdownDecoration.copyWith(
          contentPadding: EdgeInsets.fromLTRB(30, 0, 0, 0),
          alignLabelWithHint: true,
        ),
        isDense: false,
        style: DropboxStyles.dropdownItemStyle,
        hint: Container(
          alignment: Alignment.center,
          child: Text(
            hintText,
            style: TextStyle(color: Colors.grey, fontSize: 16.0),
          ),
        ),
        items: items,
        onChanged: onChanged,
        dropdownColor: Colors.white,
      ),
    );
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
}



// Customdropdown(
//                     hintText: 'ユーザ',
//                     items: [
//                       DropdownMenuItem(
//                         child: Text('1'),
//                         value: '1',
//                       ),
//                       DropdownMenuItem(
//                         child: Text('2'),
//                         value: '2',
//                       ),
//                       DropdownMenuItem(
//                         child: Text('3'),
//                         value: '3',
//                       ),
//                       DropdownMenuItem(
//                         child: Text('4'),
//                         value: '4',
//                       )
//                     ],
//                     onChanged: (value) {})