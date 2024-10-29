import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/widget/lessontable.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubjectTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(), // Apply custom AppBar
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "授業リスト",
            style: TextStyle(
              fontSize: 24, // Customize font size
              fontWeight: FontWeight.bold, // Make the font bold
              color: Colors.black, // Adjust the color as needed
            ),
          ),
          Divider(
            color: Colors.grey,
            thickness: 1.5,
            height: 15.0,
          ),

          // Add spacing below the Divider
          SizedBox(height: 20), // Add 20 pixels of vertical space

          // Rest of your content
          Expanded(
            child: Center(
              child: Lessontable(), // Load the LessonTable widget
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(), // Optional BottomBar
    );
  }
}
