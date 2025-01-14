import 'package:flutter/material.dart';

class studentData {
  final String studentName;
  final String description;

  studentData(this.studentName, this.description);
}

class teacherAttendanceManagementPage extends StatelessWidget {
  List<studentData> studentList = [
    studentData('Apple', 'A red fruit'),
    studentData('Banana', 'A yellow fruit'),
    studentData('Orange', 'A citrus fruit'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('出席管理ページ'),
        ),
        body: ListView.builder(
          itemCount: studentList.length,
          itemBuilder: (BuildContext context, int index) {
            final student = studentList[index];
            return ListTile(
                title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  student.studentName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                Text(student.description),
              ],
            ));
          },
        ));
  }

  // Widget buildHeader(){
  //   return Padding(padding:
  //   const EdgeInsets.all(8),
  //   child: Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Text('学生番号',style: TextStyle(
  //         fontSize: 24,
  //         fontWeight: Font
  //       ),)
  //     ],
  //   ),)
  // }
}
