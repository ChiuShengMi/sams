import 'package:flutter/material.dart';
import './input_styles.dart';

class CustomSearchbar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  CustomSearchbar({required this.controller, this.hintText = 'Search'});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextField(
        controller: controller,
        decoration: InputStyles.searchBarStyle.copyWith(
          hintText: hintText,
        ),
      ),
    );
  }
}
