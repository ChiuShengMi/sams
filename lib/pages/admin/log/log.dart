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
  String searchText = '';
  final TextEditingController _searchController = TextEditingController();

  List<QueryDocumentSnapshot> logs = [];
  List<DocumentSnapshot> pageMarkers = [];
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchLogs(isNextPage: true, isInitial: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        searchText = '';
        currentPage = 0;
        pageMarkers.clear();
        lastDocument = null;
        firstDocument = null;
        hasMoreLogs = true;
      });
      _fetchLogs(isNextPage: true, isInitial: true);
    }
  }

  void _performSearch() {
    setState(() {
      currentPage = 0;
      pageMarkers.clear();
      lastDocument = null;
      firstDocument = null;
      hasMoreLogs = true;
      searchText = _searchController.text;
    });
    _fetchLogs(isNextPage: true, isInitial: true);
  }

  Future<void> _fetchLogs({
    required bool isNextPage,
    bool isInitial = false,
  }) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      if (!isNextPage) {
        hasMoreLogs = true;
      }
    });

    try {
      Query query = FirebaseFirestore.instance.collection('Log');

      // 如果有搜索文字，則添加搜索條件
      if (searchText.isNotEmpty) {
        query = query
            .orderBy('MSG')
            .startAt([searchText]).endAt([searchText + '\uf8ff']);
      } else {
        query = query.orderBy(FieldPath.documentId, descending: true);
      }

      query = query.limit(logsPerPage);

      if (!isInitial) {
        if (isNextPage && lastDocument != null) {
          query = query.startAfterDocument(lastDocument!);
        } else if (!isNextPage && currentPage > 1) {
          DocumentSnapshot startDoc = pageMarkers[currentPage - 2];
          query = query.startAfterDocument(startDoc);
        }
      }

      final querySnapshot = await query.get();
      final fetchedLogs = querySnapshot.docs;

      if (fetchedLogs.isEmpty) {
        setState(() {
          hasMoreLogs = false;
          logs = [];
        });
        return;
      }

      // 檢查是否還有下一頁
      if (fetchedLogs.length < logsPerPage) {
        hasMoreLogs = false;
      }

      setState(() {
        logs = fetchedLogs;
        lastDocument = fetchedLogs.last;
        firstDocument = fetchedLogs.first;

        if (isNextPage) {
          if (pageMarkers.length <= currentPage) {
            pageMarkers.add(firstDocument!);
          }
          currentPage += 1;
        } else {
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ログを検索...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _performSearch,
                  child: const Text('検索'),
                ),
              ],
            ),
          ),
          Expanded(
            child: logs.isEmpty && !isLoading
                ? Center(
                    child: Text(
                      searchText.isEmpty ? 'ログがありません' : '検索結果が見つかりません',
                    ),
                  )
                : ListView.builder(
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
