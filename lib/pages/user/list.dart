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
import 'classLists.dart';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final TextEditingController searchInputController = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  String selectedUserType = 'Students'; // Default user type
  String selectedCourse = 'IT'; // Default course
  String? selectedClass; // No default class
  int currentPage = 0; // 현재 페이지
  int itemsPerPage = 10; // 한 페이지에 표시되는 아이템 수
  int startPage = 0; // 현재 보여지는 페이지 그룹의 첫 번째 페이지
  int endPage = 9; // 현재 보여지는 페이지 그룹의 마지막 페이지

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

  // Firestore에서 데이터를 검색하는 쿼리
  Stream<QuerySnapshot> _getUserStream() {
    var query = firestore
        .collection('Users')
        .doc(selectedUserType)
        .collection(selectedCourse)
        .where('DELETE_FLG', isEqualTo: 0); // DELETE_FLG가 0인 데이터만 필터링

    // 검색 필터 추가
    if (searchInputController.text.isNotEmpty) {
      query = query
          .orderBy('NAME')
          .where('NAME', isGreaterThanOrEqualTo: searchInputController.text)
          .where('NAME',
              isLessThanOrEqualTo: searchInputController.text + '\uf8ff');
    }

    if (selectedClass != null && selectedClass!.isNotEmpty) {
      query = query.where('CLASS', isEqualTo: selectedClass);
    }

    return query.snapshots();
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
                        value: selectedUserType,
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
                    SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: Customdropdown(
                        hintText: 'コース',
                        value: selectedCourse,
                        items: [
                          DropdownMenuItem(child: Text('IT'), value: 'IT'),
                          DropdownMenuItem(child: Text('GAME'), value: 'GAME'),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCourse = value!;
                            selectedClass = null;
                          });
                        },
                        size: DropboxSize.small,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: Customdropdown(
                        hintText: 'クラス',
                        value: selectedClass,
                        items: ClassLists.getClassesByCourse(selectedCourse)
                            .map((className) => DropdownMenuItem<String>(
                                  value: className,
                                  child: Text(className),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedClass = value;
                          });
                        },
                        size: DropboxSize.small,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: CustomInput(
                        controller: searchInputController,
                        hintText: '名前を入力してください。',
                        onChanged: (value) {
                          setState(() {}); // 상태를 갱신하여 검색 조건 반영
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: MediumButton(
                        text: '検索',
                        onPressed: () {
                          setState(() {
                            // 검색 버튼 클릭 시 상태 갱신
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ]),

              // 유저 리스트
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

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            '該当するユーザが見つかりません。',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }

                      final List<List<String>> allData = snapshot.hasData
                          ? _mapSnapshotToData(snapshot.data!)
                          : [];

                      // 페이지네이션 데이터 계산
                      final totalItems = allData.length;
                      final totalPages = (totalItems / itemsPerPage).ceil();
                      final pageData = allData.sublist(
                        currentPage * itemsPerPage,
                        ((currentPage + 1) * itemsPerPage).clamp(0, totalItems),
                      );

                      return Column(
                        children: [
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
                                    MaterialPageRoute(
                                        builder: (context) => UserAdd()),
                                  );
                                },
                              ),
                              SizedBox(width: 16),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(
                                height: 30,
                              )
                            ],
                          ),
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
                                        'Users/$selectedUserType/$selectedCourse/${rowData.last}',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    currentPage = currentPage.clamp(0, totalPages - 1);

    int startPage = (currentPage ~/ 10) * 10;
    int endPage =
        (startPage + 9) < totalPages ? (startPage + 9) : totalPages - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (startPage > 0)
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                currentPage = (startPage - 10).clamp(0, totalPages - 1);
              });
            },
          ),
        ...List.generate(
          endPage - startPage + 1,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                currentPage = startPage + index;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: currentPage == startPage + index
                    ? Color(0xFF7B1FA2)
                    : Colors.white,
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(
                  color: currentPage == startPage + index
                      ? Color(0xFF7B1FA2)
                      : Colors.white,
                  width: 1.0,
                ),
              ),
              child: Text(
                '${startPage + index + 1}',
                style: TextStyle(
                  color: currentPage == startPage + index
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        if (endPage < totalPages - 1)
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                currentPage = (endPage + 1).clamp(0, totalPages - 1);
              });
            },
          ),
      ],
    );
  }
}
