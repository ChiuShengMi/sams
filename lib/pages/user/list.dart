import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/widget/actionbar.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/custom_input_container.dart';
import 'package:sams/widget/dropbox/custom_dropdown.dart';
import 'package:sams/widget/searchbar/custom_input.dart';
import 'package:sams/widget/table/custom_table.dart';
import 'package:sams/pages/user/add.dart';
import 'package:sams/pages/user/detail.dart';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final TextEditingController searchInputController = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  String selectedUserType = 'Students'; // Default user type
  int currentPage = 0; // 현재 페이지
  int itemsPerPage = 10; // 한 페이지에 표시되는 아이템 수

  List<List<String>> _mapSnapshotToData(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return [
        data['ID']?.toString() ?? 'N/A',
        data['COURSE']?.toString() ?? 'N/A',
        data['CLASS']?.toString() ?? 'N/A',
        data['JOB']?.toString() ?? 'N/A',
        data['MAIL']?.toString() ?? 'N/A',
        data['NAME']?.toString() ?? 'N/A',
        data['TEL']?.toString() ?? 'N/A',
        doc.id, // Firestore document ID 추가 (클릭 시 사용)
      ];
    }).toList();
  }

  Stream<QuerySnapshot> _getUserStream() {
    return firestore
        .collection('Users')
        .doc(selectedUserType)
        .collection(
            'IT') // Modify if needed based on user type and specific course
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Actionbar(children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Customdropdown(
                        hintText: 'ユーザ',
                        items: [
                          DropdownMenuItem(
                              child: Text('学生'), value: 'Students'),
                          DropdownMenuItem(
                              child: Text('教員'), value: 'Teachers'),
                          DropdownMenuItem(
                              child: Text('管理者'), value: 'Managers'),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedUserType = value!;
                          });
                        },
                        size: DropboxSize.small,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 4,
                      child: CustomInput(
                        controller: searchInputController,
                        hintText: 'Search',
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: MediumButton(
                        text: '検索',
                        onPressed: () {
                          // Add search functionality if needed
                        },
                      ),
                    ),
                  ],
                ),
              ]),
              CustomInputContainer(
                title: 'User List',
                inputWidgets: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _getUserStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final List<List<String>> allData = snapshot.hasData
                          ? _mapSnapshotToData(snapshot.data!)
                          : [];

                      // 페이지네이션 데이터 계산
                      final totalItems = allData.length;
                      final totalPages = (totalItems / itemsPerPage).ceil();
                      final pageData = allData
                          .skip(currentPage * itemsPerPage)
                          .take(itemsPerPage)
                          .toList();

                      return Column(
                        children: [
                          CustomTable(
                            headers: [
                              '学籍番号',
                              'コース',
                              'クラス名',
                              '属性',
                              'E-Mail',
                              '名前',
                              '電話番号',
                              '修正',
                            ],
                            data: pageData,
                            onRowTap: (rowIndex) {
                              final List<String> rowData = pageData[rowIndex];
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetail(
                                    documentPath:
                                        'Users/$selectedUserType/IT/${rowData.last}',
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 10),
                          _buildPaginationControls(totalPages),
                        ],
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MediumButton(
                    text: '戻る',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 16),
                  MediumButton(
                    text: '追加',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserAdd()),
                      );
                    },
                  ),
                  SizedBox(width: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => MouseRegion(
          cursor: SystemMouseCursors.click, // 포인터 효과 추가
          child: GestureDetector(
            onTap: () {
              setState(() {
                currentPage = index; // 페이지 변경
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: currentPage == index
                    ? Color(0xFF7B1FA2)
                    : Colors.white, // 선택 여부에 따른 색상
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(
                  color: currentPage == index
                      ? Color(0xFF7B1FA2)
                      : Colors.white, // 선택 여부에 따른 색상
                  width: 1.0,
                ),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: currentPage == index
                      ? Colors.white
                      : Colors.black, // 텍스트 색상
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
