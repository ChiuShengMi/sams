import 'package:flutter/material.dart';
import 'package:sams/pages/testPages/testPages_leaves_edit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/widget/button/custom_button.dart';

class adminLeaveManagement extends StatefulWidget {
  const adminLeaveManagement({super.key});

  @override
  State<adminLeaveManagement> createState() => _adminLeaveManagementState();
}

class _adminLeaveManagementState extends State<adminLeaveManagement> {
  bool? isManager;
  List<Map<String, dynamic>> leaveData = []; // 全ての休暇データを保存する
  List<Map<String, dynamic>> filteredLeaveData = []; // フィルタリングされた休暇データ
  int filterStatus = 0; // フィルター条件（デフォルトは未承認データを表示）

  @override
  void initState() {
    super.initState();
    checkUserRole(); // ユーザーが管理者かどうかを確認する
  }

  // ユーザーの役割を確認する
  Future<void> checkUserRole() async {
    String role = "管理者"; // 仮の役割チェックロジック
    if (role == "管理者") {
      setState(() {
        isManager = true;
      });
      fetchAllLeaves(); // 管理者であれば、全ての休暇データを取得する
    } else {
      setState(() {
        isManager = false;
      });
    }
  }

  // 全てのカテゴリーを動的に遍歴し、休暇データを取得する
  Future<void> fetchAllLeaves() async {
    List<Map<String, dynamic>> tempLeaveData = [];
    try {
      // "Leaves" コレクション内の全てのドキュメントを取得
      final leavesSnapshot =
          await FirebaseFirestore.instance.collection("Leaves").get();

      for (var leaveDoc in leavesSnapshot.docs) {
        // 各休暇ドキュメントのデータ
        final leaveData = leaveDoc.data();

        // 一時リストに休暇ドキュメントを追加
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
        leaveData = tempLeaveData; // 休暇データを更新
        applyFilter(); // フィルター条件に基づいてデータを更新
      });

      print("取得したデータ: ${leaveData.length}");
    } catch (e) {
      print("エラー: $e");
    }
  }

  // フィルター条件に基づいてデータをフィルタリングする
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
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  '休暇管理',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Filter and Reload Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'フィルター: ',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<int>(
                      value: filterStatus,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('未承認')),
                        DropdownMenuItem(value: 1, child: Text('承認済み')),
                        DropdownMenuItem(value: 2, child: Text('却下')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            filterStatus = value;
                            applyFilter();
                          });
                        }
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: fetchAllLeaves,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Main Content Section

            Expanded(
              child: isManager == null
                  ? const Center(child: CircularProgressIndicator())
                  : isManager == false
                      ? const Center(
                          child: Text(
                            '休暇管理の権限がありません',
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
                                  elevation: 4,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '授業名: ${leave["CLASS_NAME"] ?? "不明"}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '日付: ${leave["LEAVE_DATE"] ?? "不明"}\n'
                                              '申請者: ${leave["USER_CLASS"] ?? "不明"}\t${leave["USER_NAME"] ?? "不明"}\n'
                                              '種別: ${leave["LEAVE_CATEGORY"] ?? "不明"}\n'
                                              '状態: ${{
                                                    0: "未承認",
                                                    1: "承認済み",
                                                    2: "却下"
                                                  }[leave["LEAVE_STATUS"]] ?? "不明"}',
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 60,
                                        right: 20,
                                        child: InkWell(
                                          onTap: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    LeaveEditPage(
                                                  leaveDetails: leave,
                                                ),
                                              ),
                                            );
                                            if (result == 'refresh') {
                                              fetchAllLeaves();
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              '休暇編集',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  text: '戻る',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          BottomBar(),
        ],
      ),
    );
  }
}
