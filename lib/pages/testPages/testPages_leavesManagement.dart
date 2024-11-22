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

  // 動態遍歷所有分類和 UID，獲取所有請假資料
  Future<void> fetchAllLeaves() async {
    List<Map<String, dynamic>> tempLeaveData = [];
    try {
      final List<String> collections = ["IT", "GAME"]; // 父集合名稱列表

      for (String collection in collections) {
        // 取得分類下的所有 UID 文件
        final uidsSnapshot = await FirebaseFirestore.instance
            .collection("Leaves")
            .doc(collection)
            .collection("UIDs") // 假設 UID 子集合統一存放在這裡
            .get();

        for (var uidDoc in uidsSnapshot.docs) {
          final uid = uidDoc.id; // UID 文件的 ID

          // 遍歷該 UID 下的所有請假 ID 文件
          final leaveDocsSnapshot = await FirebaseFirestore.instance
              .collection("Leaves")
              .doc(collection)
              .collection(uid) // 指定 UID 子集合
              .get();

          for (var leaveDoc in leaveDocsSnapshot.docs) {
            tempLeaveData.add(leaveDoc.data()); // 添加每個請假文件到列表
          }
        }
      }

      setState(() {
        leaveData = tempLeaveData; // 更新資料
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
                              '理由: ${leave["LEAVE_REASON"] ?? "不明"}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              '日付: ${leave["LEAVE_DATE"] ?? "不明"}\n状態: ${leave["LEAVE_STATUS"] == 0 ? "未承認" : "承認済み"}',
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
