import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class logPage extends StatefulWidget {
  const logPage({Key? key}) : super(key: key);

  @override
  _logPageState createState() => _logPageState();
}

class _logPageState extends State<logPage> {
  final int logsPerPage = 20;
  DocumentSnapshot? lastDocument; // 用於分頁的最後一條記錄
  DocumentSnapshot? firstDocument; // 第一條記錄，用於回退
  bool hasMoreLogs = true;
  bool isLoading = false;

  List<QueryDocumentSnapshot> logs = [];
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs({bool isNextPage = true}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection('Log')
          .orderBy(FieldPath.documentId, descending: true)
          .limit(logsPerPage);

      // 如果是下一頁，基於最後一條記錄開始查詢
      if (isNextPage && lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }
      // 如果是上一頁，基於第一條記錄查詢
      if (!isNextPage && firstDocument != null) {
        query = query.endBeforeDocument(firstDocument!);
      }

      final querySnapshot = await query.get();
      final fetchedLogs = querySnapshot.docs;

      if (fetchedLogs.isEmpty) {
        setState(() {
          hasMoreLogs = false;
        });
        return;
      }

      setState(() {
        if (isNextPage) {
          logs.addAll(fetchedLogs);
          lastDocument = fetchedLogs.last;
          firstDocument ??= fetchedLogs.first; // 如果是第一頁，記錄第一條記錄
          // 只有在加載下一頁時遞增頁碼
          if (currentPage == 1 && lastDocument != null) {
            // 保持為第一頁
          } else {
            currentPage += 1;
          }
        } else {
          logs.insertAll(0, fetchedLogs);
          firstDocument = fetchedLogs.first;
          currentPage -= 1; // 回到上一頁
        }
      });
    } catch (e) {
      print("Error fetching logs: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ログ一覧'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final msg = log['MSG'] ?? 'No message';
                return ListTile(
                  title: Text(msg),
                  subtitle: Text(log.id), // 文件 ID（通常是時間戳）
                );
              },
            ),
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: currentPage > 1
                    ? () => _fetchLogs(isNextPage: false)
                    : null,
                child: const Text('前のページ'),
              ),
              Text('ページ: $currentPage'),
              TextButton(
                onPressed:
                    hasMoreLogs ? () => _fetchLogs(isNextPage: true) : null,
                child: const Text('次のページ'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
