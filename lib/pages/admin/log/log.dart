import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/bottombar.dart';
import 'package:sams/widget/button/custom_button.dart';

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
      appBar: CustomAppBar(),
      body: Column(
        children: [
          // 検索バー
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                      "ログ一覧",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                // フィルタリングと検索バー
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 検索バー
                    Container(
                      width: 500,
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
                    // Add spacing between the search bar and buttons
                    SizedBox(width: 30),
                    CustomButton(
                      text: "検索",
                      onPressed: _performSearch,
                    ),
                    SizedBox(width: 8),
                    CustomButton(
                      text: "戻る",
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              children: [
                // ログのリスト or メッセージ表示
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator()) // ローディング
                      : logs.isEmpty
                          ? Center(
                              child: Text(
                                searchText.isEmpty
                                    ? 'ログがありません'
                                    : '検索結果が見つかりません',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: logs.length,
                              itemBuilder: (context, index) {
                                final log = logs[index];
                                final msg = log['MSG'] ?? 'No message';
                                return ListTile(
                                  title:
                                      Text(msg, style: TextStyle(fontSize: 16)),
                                  subtitle: Text(log.id,
                                      style: TextStyle(color: Colors.grey)),
                                );
                              },
                            ),
                ),

                // ページネーション
                if (!isLoading) // ローディング中は非表示
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: currentPage > 1
                              ? () => _fetchLogs(isNextPage: false)
                              : null,
                          child: const Text(
                            '前のページ',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'ページ: $currentPage',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        TextButton(
                          onPressed: hasMoreLogs
                              ? () => _fetchLogs(isNextPage: true)
                              : null,
                          child: const Text(
                            '次のページ',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
