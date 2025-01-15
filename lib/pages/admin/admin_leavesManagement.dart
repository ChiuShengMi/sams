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
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // タイトル行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "休暇管理",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomButton(
                        text: '戻る',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Header Section
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.filter_list,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'フィルター:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: DropdownButton<int>(
                                value: filterStatus,
                                underline: SizedBox(),
                                items: [
                                  _buildDropdownItem(0, '未承認', Colors.orange),
                                  _buildDropdownItem(1, '承認済み', Colors.green),
                                  _buildDropdownItem(2, '却下', Colors.red),
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
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: Colors.blue.shade700,
                          ),
                          onPressed: fetchAllLeaves,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: isManager == null
                  ? _buildLoadingState()
                  : isManager == false
                      ? _buildNoPermissionState()
                      : filteredLeaveData.isEmpty
                          ? _buildEmptyState()
                          : _buildLeaveList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }

  DropdownMenuItem<int> _buildDropdownItem(
      int value, String text, Color color) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 16),
          Text(
            'データを読み込んでいます...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPermissionState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            '休暇管理の権限がありません',
            style: TextStyle(
              color: Colors.red.shade400,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            '休暇データがありません',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredLeaveData.length,
      itemBuilder: (context, index) {
        final leave = filteredLeaveData[index];
        final status = leave["LEAVE_STATUS"] as int;

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LeaveEditPage(
                      leaveDetails: leave,
                    ),
                  ),
                );
                if (result == 'refresh') {
                  fetchAllLeaves();
                }
              },
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            leave["CLASS_NAME"] ?? "不明",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        _buildStatusBadge(status),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildInfoRow(
                        Icons.calendar_today, leave["LEAVE_DATE"] ?? "不明"),
                    SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.person_outline,
                      "${leave["USER_CLASS"] ?? "不明"} ${leave["USER_NAME"] ?? "不明"}",
                    ),
                    SizedBox(height: 8),
                    _buildInfoRow(
                        Icons.label_outline, leave["LEAVE_CATEGORY"] ?? "不明"),
                    SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LeaveEditPage(
                                leaveDetails: leave,
                              ),
                            ),
                          );
                          if (result == 'refresh') {
                            fetchAllLeaves();
                          }
                        },
                        icon: Icon(Icons.edit, size: 18),
                        label: Text('休暇編集'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(int status) {
    final statusConfig = {
          0: {'text': '未承認', 'color': Colors.orange},
          1: {'text': '承認済み', 'color': Colors.green},
          2: {'text': '却下', 'color': Colors.red},
        }[status] ??
        {'text': '不明', 'color': Colors.grey};

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (statusConfig['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusConfig['color'] as Color),
      ),
      child: Text(
        statusConfig['text'] as String,
        style: TextStyle(
          color: statusConfig['color'] as Color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.purple.shade600,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.purple.shade700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
