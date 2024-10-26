import 'package:flutter/material.dart';

class TestPageLeaves extends StatefulWidget {
  @override
  _TestPageLeavesState createState() => _TestPageLeavesState();
}

class _TestPageLeavesState extends State<TestPageLeaves> {
  final TextEditingController reasonController = TextEditingController(); // 休暇理由のコントローラー
  DateTime? selectedDate; // 選択した日付

  // 日付選択ダイアログ
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('休暇届出'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '休暇の日付を選択してください:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('日付を選択'),
                ),
                SizedBox(width: 20),
                Text(
                  selectedDate != null
                      ? "${selectedDate!.year}/${selectedDate!.month}/${selectedDate!.day}"
                      : "未選択",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: '休暇の理由',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 休暇申請処理の追加
                  print("日付: $selectedDate, 理由: ${reasonController.text}");
                },
                child: Text('申請を提出'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
