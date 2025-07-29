import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fitness_app/screens/chat%20screen/userlist_screen.dart';
import 'package:fitness_app/screens/main%20screens/training_screen.dart';
import 'package:fitness_app/screens/report%20screens/report_screen.dart';
import 'package:fitness_app/screens/setting%20screens/setting_screen.dart';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Navbar extends StatefulWidget {
  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  void initState() {
    super.initState();
    _setupFCM();
  }

  void _setupFCM() async {
    // ✅ Step 1: Ask for permission (Android 13+ and iOS)
    NotificationSettings settings = await _messaging.requestPermission();
    print("Permission: ${settings.authorizationStatus}");

    // ✅ Step 2: Get FCM token
    String? token = await _messaging.getToken();
    print("FCM Token: $token");

    // ✅ Step 3: Save token in Firestore
    if (token != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': token});
        print("Token saved to Firestore ✅");
      }
    }

    // ✅ Step 4: Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Foreground Message received: ${message.notification?.title}');
      // You can show a dialog/snackbar here
    });
  }

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    TrainingScreen(),
    UsersListScreen(),
    ReportScreen(),
    SettingScreen(),
  ];

  final Color primary = Color(0xFFB31919);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: primary,
        style: TabStyle.react,
        curveSize: 75,
        items: const [
          TabItem(icon: Icons.school, title: 'Training'),
          TabItem(icon: Icons.chat, title: 'Chat'),
          TabItem(icon: Icons.assessment, title: 'Reports'),
          TabItem(icon: Icons.settings, title: 'Setting'),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
