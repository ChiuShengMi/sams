import 'package:sams/pages/mainPages/homepage_admin.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/lessontable.dart';
import 'package:flutter/material.dart';
import 'package:sams/pages/mainPages/subjectlist/subjecttable_new.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubjectTable extends StatefulWidget {
  @override
  _SubjectTableState createState() => _SubjectTableState();
}

class _SubjectTableState extends State<SubjectTable> {
  // Track selected category and search term
  String selectedCategory = 'IT';
  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "授業リスト",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          Divider(
            color: Colors.grey,
            thickness: 1.5,
            height: 15.0,
          ),
          SizedBox(height: 20),
// Row for New Lesson, Search Field, Category Buttons, and Back Button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                text: "戻る",
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePageAdmin()),
                  );
                },
              ),
              SizedBox(width: 10),
              Container(
                width: 1000,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '検索する授業名を入力',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onChanged: (value) {},
                ),
              ),
              SizedBox(width: 10),
              ToggleButtons(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('IT'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('GAME'),
                  ),
                ],
                isSelected: [
                  selectedCategory == 'IT',
                  selectedCategory == 'GAME'
                ],
                onPressed: (index) {
                  setState(() {
                    selectedCategory = index == 0 ? 'IT' : 'GAME';
                  });
                  // Additional filter logic for selected category
                },
                borderRadius: BorderRadius.circular(10),
              ),
              SizedBox(width: 10),
              CustomButton(
                text: "新しい授業作成",
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SubjecttableNew()),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 20),

          // Main content with Lesson Table
          Expanded(
            child: Center(
              child: Lessontable(), // Load the LessonTable widget
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
