import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/widget/lessontable.dart';
import 'package:flutter/material.dart';
import 'package:sams/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Subjecttable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(), // Apply custom AppBar
      body: Column(
        children: [
          Text("授業リスト"),
          Divider(
            color: Colors.red,
            thickness: 15.0,
            height: 15.0,
          ),

          // Add spacing below the Divider
          SizedBox(height: 20), // Add 20 pixels of vertical space

          // Rest of your content
          Expanded(
            child: Center(
              child: Text("Your content here"),
            ),
          ),
        ],
      ),
    );
  }
}
