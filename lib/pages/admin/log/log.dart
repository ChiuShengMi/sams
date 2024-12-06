import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class logPage extends StatefulWidget {
  const logPage({Key? key}) : super(key: key);

  @override
  _logPageState createState() => _logPageState();
}

class _logPageState extends State<logPage> {
  final int logsPerPage = 20;
  DocumentSnapshot? lastDocument;
  DocumentSnapshot? firstDocument;
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

      if (isNextPage && lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

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
          firstDocument ??= fetchedLogs.first;

          if (currentPage == 1 && lastDocument != null) {
          } else {
            currentPage += 1;
          }
        } else {
          logs.insertAll(0, fetchedLogs);
          firstDocument = fetchedLogs.first;
          currentPage -= 1;
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
                  subtitle: Text(log.id),
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
