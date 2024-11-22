import 'package:flutter/material.dart';
import 'package:sams/utils/firebase_firestore.dart';
import 'package:sams/utils/firebase_auth.dart';
import 'package:sams/utils/firebase_realtime.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveManagementPage extends StatefulWidget {
  const LeaveManagementPage({super.key});

  @override
  State<LeaveManagementPage> createState() => _LeaveManagementPageState();
}

class _LeaveManagementPageState extends State<LeaveManagementPage> {
  bool? isManager;
  List<Map<String, dynamic>> leaveData = []; // 儲存所有的請假資料

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
          "CLASS": leaveData["CLASS"] ?? "不明",
          "CLASS_ID": leaveData["CLASS_ID"] ?? "不明",
          "CLASS_NAME": leaveData["CLASS_NAME"] ?? "不明",
          "LEAVE_CATEGORY": leaveData["LEAVE_CATEGORY"] ?? "不明",
          "LEAVE_DATE": leaveData["LEAVE_DATE"] ?? "不明",
          "LEAVE_REASON": leaveData["LEAVE_REASON"] ?? "不明",
          "LEAVE_STATUS": leaveData["LEAVE_STATUS"] ?? 0,
          "LEAVE_TEXT": leaveData["LEAVE_TEXT"] ?? "",
          "NAME": leaveData["NAME"] ?? "不明",
          "UID": leaveData["UID"] ?? "不明",
        });
      }

      setState(() {
        leaveData = tempLeaveData; // 更新請假資料
      });

      print("取得的請假資料筆數: ${leaveData.length}");
    } catch (e) {
      print("エラー: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('休暇管理'),
      ),
      body: isManager == null
          ? const Center(child: CircularProgressIndicator()) // 確認中
          : isManager == false
              ? const Center(
                  child: Text(
                    '休暇管理の権限がなかった',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : leaveData.isEmpty
                  ? const Center(child: Text('休暇データがありません'))
                  : ListView.builder(
                      itemCount: leaveData.length,
                      itemBuilder: (context, index) {
                        final leave = leaveData[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(
                              '授業名: ${leave["CLASS_NAME"] ?? "不明"}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              '日付: ${leave["LEAVE_DATE"] ?? "不明"}\n種別: ${leave["LEAVE_CATEGORY"] ?? "不明"}\n状態: ${leave["LEAVE_STATUS"] == 0 ? "未承認" : "承認済み"}',
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
