import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sams/pages/loginPages/login.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    // Calculate dynamic appBar height for mobile devices
    final double appBarHeight = MediaQuery.of(context).size.height * 0.15;

    return AppBar(
      title: const Text(''),
      backgroundColor: const Color(0xFF7B1FA2),
      elevation: MediaQuery.of(context).size.height * 0.02,
      toolbarHeight: appBarHeight,
      leadingWidth: appBarHeight,
      leading: Center(
        child: Container(
          height: appBarHeight * 0.9,
          width: appBarHeight * 0.9,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(appBarHeight * 0.25),
              onTap: () {}, // Add your action here
              child: Padding(
                padding: EdgeInsets.all(appBarHeight * 0.1),
                child: Image.asset(
                  'assets/icon/HelloECC_icon_big.png',
                  height: appBarHeight,
                  width: appBarHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.logout, size: appBarHeight * 0.4),
          tooltip: 'Logout',
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
