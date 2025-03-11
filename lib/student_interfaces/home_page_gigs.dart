import 'package:flutter/material.dart';
import 'package:lbrikol/animations/purple_wave_clipper.dart';
import 'package:lbrikol/student_interfaces/profile_screen.dart';

import 'bottom_nav_bar.dart';
import 'browse_gigs_screen.dart';
import 'chat_screen.dart';
import 'history_screen.dart';
import 'home_top_screen/notification_overlay.dart';
import 'home_top_screen/top_screen_content.dart';

void main() {
  runApp(const MyApp());
}

// Root of the app
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

// MainScreen: holds the bottom navigation bar and switches between pages
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final NotificationOverlay _notificationOverlay = NotificationOverlay();

  int _currentIndex = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String selectedCategory = "Gigs";

  // List of BottomNavigationBarItems
  final List<BottomNavigationBarItem> _bottomNavItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Browse gigs',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.history),
      label: 'History',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat),
      label: 'Chat',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Build the home content fresh so that setState updates are reflected.
  Widget _buildHomeContent() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: PurpleWaveClipper(),
            child: Container(
              color: const Color(0xFF40189D),
              height: 220,
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16, top: 10),
            child: HomeTopScreenContent(
              fadeAnimation: _fadeAnimation,
              notificationOverlay: _notificationOverlay,
            ),
          ),
        ),
      ],
    );
  }

  // This method will be used in different files (profile_screen.dart / chat_screen.dart ....)
  @override
  Widget build(BuildContext context) {
    // Build the current page based on _currentIndex. Note that for the home page,
    // we rebuild _buildHomeContent() so that changes to selectedCategory are reflected.
    Widget currentPage;
    if (_currentIndex == 0) {
      currentPage = _buildHomeContent();
    } else if (_currentIndex == 1) {
      currentPage = const BrowseGigsScreen();
    } else if (_currentIndex == 2) {
      currentPage = const HistoryScreen();
    } else if (_currentIndex == 3) {
      currentPage = const ChatScreen();
    } else {
      currentPage = const ProfileScreen();
    }

    return Scaffold(
      body: currentPage,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        items: _bottomNavItems,
        onItemTapped: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
      ),
    );
  }
}
