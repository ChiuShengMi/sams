import 'package:flutter/material.dart';
import 'package:sams/pages/testPages/testPages_leaves_edit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveManagementPage extends StatefulWidget {
  const LeaveManagementPage({super.key});

  @override
  State<LeaveManagementPage> createState() => _LeaveManagementPageState();
}

class _LeaveManagementPageState extends State<LeaveManagementPage> {
  bool? isManager;
  List<Map<String, dynamic>> leaveData = []; // 儲存所有的請假資料
  List<Map<String, dynamic>> filteredLeaveData = []; // 篩選後的請假資料
  int filterStatus = 0; // 篩選條件（預設顯示未承認資料）

  @override
  void initState() {
    super.initState();
    checkUserRole(); // 檢查是否為管理者
  }

  // 檢查使用者角色
  Future<void> checkUserRole() async {
    String role = "管理者"; // 假設角色檢測邏輯
    if (role == "管理者") {
      setState(() {
        isManager = true;
      });
      fetchAllLeaves(); // 如果是管理者，取得所有請假資料
    } else {
      setState(() {
        isManager = false;
      });
    }
  }

  // 動態遍歷所有分類，獲取所有請假資料
  Future<void> fetchAllLeaves() async {
    List<Map<String, dynamic>> tempLeaveData = [];
    try {
      // 取得 "Leaves" 集合下的所有文件
      final leavesSnapshot =
          await FirebaseFirestore.instance.collection("Leaves").get();

      for (var leaveDoc in leavesSnapshot.docs) {
        // 每個請假文檔的資料
        final leaveData = leaveDoc.data();

        // 添加請假文檔到臨時列表
        tempLeaveData.add({
          "LEAVE_ID": leaveDoc.id,
          "USER_CLASS": leaveData["USER_CLASS"] ?? "不明",
          "CLASS_ID": leaveData["CLASS_ID"] ?? "不明",
          "CLASS_NAME": leaveData["CLASS_NAME"] ?? "不明",
          "LEAVE_CATEGORY": leaveData["LEAVE_CATEGORY"] ?? "不明",
          "LEAVE_DATE": leaveData["LEAVE_DATE"] ?? "不明",
          "LEAVE_REASON": leaveData["LEAVE_REASON"] ?? "不明",
          "LEAVE_STATUS": leaveData["LEAVE_STATUS"] ?? 0,
          "LEAVE_TEXT": leaveData["LEAVE_TEXT"] ?? "",
          "USER_NAME": leaveData["USER_NAME"] ?? "不明",
          "USER_UID": leaveData["USER_UID"] ?? "不明",
          "FILE": leaveData["FILE"] ?? "不明",
          "APPROVER": leaveData["APPROVER"] ?? "",
        });
      }

      setState(() {
        leaveData = tempLeaveData; // 更新請假資料
        applyFilter(); // 根據篩選條件更新資料
      });

      print("取得したデータ: ${leaveData.length}");
    } catch (e) {
      print("エラー: $e");
    }
  }

  // 根據篩選條件過濾資料
  void applyFilter() {
    setState(() {
      filteredLeaveData = leaveData
          .where((leave) => leave["LEAVE_STATUS"] == filterStatus)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('休暇管理'),
      ),
      body: Column(
        children: [
          // 篩選器和重新整理按鈕
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'フィルター: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<int>(
                  value: filterStatus,
                  items: const [
                    DropdownMenuItem(
                      value: 0,
                      child: Text('未承認'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('承認済み'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('却下'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        filterStatus = value;
                        applyFilter(); // 更新篩選結果
                      });
                    }
                  },
                ),
                const SizedBox(width: 16), // 空隙
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    fetchAllLeaves(); // 重新取得資料
                  },
                ),
              ],
            ),
          ),
          // 主體內容
          Expanded(
            child: isManager == null
                ? const Center(child: CircularProgressIndicator()) // 確認中
                : isManager == false
                    ? const Center(
                        child: Text(
                          '休暇管理の権限がなかった',
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    : filteredLeaveData.isEmpty
                        ? const Center(child: Text('休暇データがありません'))
                        : ListView.builder(
                            itemCount: filteredLeaveData.length,
                            itemBuilder: (context, index) {
                              final leave = filteredLeaveData[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: ListTile(
                                  title: Text(
                                    '授業名: ${leave["CLASS_NAME"] ?? "不明"}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  subtitle: Text(
                                    '日付: ${leave["LEAVE_DATE"] ?? "不明"}\n申請者: ${leave["USER_CLASS"] ?? "不明"}\t${leave["USER_NAME"] ?? "不明"}\n種別: ${leave["LEAVE_CATEGORY"] ?? "不明"}\n状態: ${leave["LEAVE_STATUS"] == 0 ? "未承認" : (leave["LEAVE_STATUS"] == 1 ? "承認済み" : "却下")}',
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LeaveEditPage(
                                          leaveDetails: leave,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
