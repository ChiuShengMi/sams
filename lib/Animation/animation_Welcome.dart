import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimatedWelcomeMessage extends StatefulWidget {
  final String username;

  AnimatedWelcomeMessage({
    required this.username,
  });

  @override
  _AnimatedWelcomeMessageState createState() => _AnimatedWelcomeMessageState();
}

class _AnimatedWelcomeMessageState extends State<AnimatedWelcomeMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late Future<List<String>> _announcementsFuture;

  @override
  void initState() {
    super.initState();
    _initializePage();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<String>> fetchAnnouncements() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Announce')
          .where('Status', isEqualTo: 1)
          .orderBy('Time', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('announce is empty');
      }

      return snapshot.docs.map((doc) => doc['Msg'] as String).toList();
    } catch (e) {
      print('Error fetching announcements: $e'); //
      throw Exception('failed');
    }
  }

  Future<void> _initializePage() async {
    try {
      _announcementsFuture = fetchAnnouncements();
    } catch (e) {
      print('Error initializing page: $e');
      setState(() {
        _announcementsFuture = Future.error('init failded: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _announcementsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
        }

        final announcements = snapshot.data ?? [];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (announcements.isNotEmpty)
              Container(
                height: 50,
                color: Colors.yellow[100],
                child: Marquee(
                  text: announcements.join('  ★  '),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  blankSpace: 50.0,
                  velocity: 50.0,
                  pauseAfterRound: Duration(seconds: 1),
                  showFadingOnlyWhenScrolling: true,
                  fadingEdgeStartFraction: 0.1,
                  fadingEdgeEndFraction: 0.1,
                ),
              ),
            SizedBox(height: 20), //
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'ようこそ！\n${widget.username}さん',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B1FA2),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
