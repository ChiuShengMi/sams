import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Firebase Database package

class TestPageLink extends StatefulWidget {
  @override
  _TestPageLinkState createState() => _TestPageLinkState();
}

class _TestPageLinkState extends State<TestPageLink> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Page Link'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddStudentDialog();
              },
            );
          },
          child: Text('授業に学生を追加'),
        ),
      ),
    );
  }
}

class AddStudentDialog extends StatefulWidget {
  @override
  _AddStudentDialogState createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  TextEditingController searchController = TextEditingController();
  bool isITSelected = false;
  bool isGameSelected = false;
  List<Map<String, dynamic>> classList = [];

  @override
  void initState() {
    super.initState();
    searchClasses(); // Fetch initial data
  }

  // Method to fetch data from Firebase Database
  Future<void> searchClasses() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('CLASS');
    List<Map<String, dynamic>> results = [];

    // Search based on the selection of IT and GAME
    if (isITSelected || isGameSelected) {
      if (isITSelected) {
        results.addAll(await _fetchClassData(dbRef.child('IT')));
      }
      if (isGameSelected) {
        results.addAll(await _fetchClassData(dbRef.child('GAME')));
      }
    } else {
      // If neither IT nor GAME is selected, fetch both
      results.addAll(await _fetchClassData(dbRef.child('IT')));
      results.addAll(await _fetchClassData(dbRef.child('GAME')));
    }

    // Filter results based on the search text
    if (searchController.text.isNotEmpty) {
      results = results.where((classData) {
        final className = classData['className'].toString().toLowerCase();
        final searchText = searchController.text.toLowerCase();
        return className.contains(searchText);
      }).toList();
    }

    setState(() {
      classList = results;
    });
  }

  // Fetch CLASS, DAY, TIME from the specified path
  Future<List<Map<String, dynamic>>> _fetchClassData(DatabaseReference path) async {
    DataSnapshot snapshot = await path.get();
    List<Map<String, dynamic>> result = [];

    if (snapshot.exists) {
      Map<dynamic, dynamic> classes = snapshot.value as Map<dynamic, dynamic>;
      classes.forEach((key, value) {
        result.add({
          'className': value['CLASS'],
          'day': value['DAY'],
          'time': value['TIME'],
        });
      });
    }

    return result;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the maximum height for the dialog content
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return Dialog(
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '授業に学生を追加',
                style: TextStyle(fontSize: 20),
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: '検索', // 'Search' in Japanese
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (text) {
                  searchClasses(); // Perform search whenever text changes
                },
              ),
            ),
            SizedBox(height: 10),
            // IT / GAME Toggle buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FittedBox(
                child: ToggleButtons(
                  isSelected: [isITSelected, isGameSelected],
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
                  onPressed: (int index) {
                    setState(() {
                      if (index == 0) {
                        isITSelected = !isITSelected;
                      } else if (index == 1) {
                        isGameSelected = !isGameSelected;
                      }
                      searchClasses(); // Perform search whenever selection changes
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            // Display search results
            Expanded(
              child: classList.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: classList.length,
                      itemBuilder: (context, index) {
                        final classData = classList[index];
                        return ListTile(
                          title: Text(
                            '${classData['className']} - ${classData['day']} - ${classData['time']}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    )
                  : Center(child: Text('No classes found')),
            ),
            // Buttons at the bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel Button
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('取消', style: TextStyle(fontSize: 16)),
                  ),
                  // Confirm Button
                  TextButton(
                    onPressed: () {
                      // Do nothing for now
                    },
                    child: Text('確定', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
