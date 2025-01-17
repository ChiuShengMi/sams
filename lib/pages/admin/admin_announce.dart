import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnnouncePage extends StatefulWidget {
  @override
  _AdminAnnouncePageState createState() => _AdminAnnouncePageState();
}

class _AdminAnnouncePageState extends State<AdminAnnouncePage> {
  final TextEditingController _announcementController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _activeAnnouncements = [];
  List<Map<String, dynamic>> _pastAnnouncements = [];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    final snapshot = await _firestore
        .collection('Announce')
        .orderBy('Time', descending: true)
        .get();

    List<Map<String, dynamic>> active = [];
    List<Map<String, dynamic>> past = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final msg = data['Msg'] ?? '不明な内容';
      final status = data['Status'] ?? -1;

      if (status == 1) {
        active.add({'id': doc.id, 'Msg': msg, 'Status': status});
      } else if (status == 0) {
        past.add({'id': doc.id, 'Msg': msg, 'Status': status});
      }
    }

    setState(() {
      _activeAnnouncements = active;
      _pastAnnouncements = past;
    });
  }

  Future<void> _publishAnnouncement() async {
    final message = _announcementController.text.trim();
    if (message.isEmpty) return;

    final time = DateTime.now().toIso8601String().replaceAll(':', '-');

    await _firestore.collection('Announce').doc(time).set({
      'Msg': message,
      'Status': 1,
      'Time': DateTime.now(),
    });

    _announcementController.clear();
    _loadAnnouncements();
  }

  Future<void> _updateAnnouncementStatus(
      String id, int newStatus, String confirmMessage) async {
    final confirmed = await _showConfirmationDialog(confirmMessage);
    if (confirmed == true) {
      await _firestore
          .collection('Announce')
          .doc(id)
          .update({'Status': newStatus});
      _loadAnnouncements();
    }
  }

  Future<bool?> _showConfirmationDialog(String message) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('確認'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('確認'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('アナウンス設定'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'アナウンスの内容を入力してください：',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _announcementController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'ここに内容を入力',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _publishAnnouncement,
              child: Text('アナウンスを発表する'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  Text(
                    '現在のアナウンス：',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  if (_activeAnnouncements.isEmpty)
                    Text('現在有効なアナウンスはありません。', style: TextStyle(fontSize: 16)),
                  for (var announce in _activeAnnouncements)
                    ListTile(
                      title: Text(
                        announce['Msg'],
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.grey),
                        onPressed: () => _updateAnnouncementStatus(
                          announce['id'],
                          0,
                          'このアナウンスを非公開するか？',
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  Text(
                    '過去のアナウンス：',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  if (_pastAnnouncements.isEmpty)
                    Text('過去のアナウンスはありません。', style: TextStyle(fontSize: 16)),
                  for (var announce in _pastAnnouncements)
                    ListTile(
                      title: Text(
                        announce['Msg'],
                        style:
                            TextStyle(fontSize: 16, color: Colors.blueAccent),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.refresh, color: Colors.green),
                        onPressed: () => _updateAnnouncementStatus(
                          announce['id'],
                          1,
                          'このアナウンスを再度公開するか？',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _announcementController.dispose();
    super.dispose();
  }
}
