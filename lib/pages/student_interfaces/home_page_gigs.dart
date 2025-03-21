import 'package:flutter/material.dart';
import 'package:lbricool/pages/student_interfaces/profile_screen.dart';

import 'body_items/gigs_body_home.dart';
import 'bottom_nav_bar.dart';
import 'browse_gigs_screen.dart';
import 'chat_screen.dart';
import 'history_screen.dart';
import 'home_top_screen/notification_overlay.dart';
import 'home_top_screen/revenue_container.dart';
import 'home_top_screen/top_screen_content.dart';

// MainScreen: holds the bottom navigation bar and switches between pages
class HomePageGigs extends StatefulWidget {
  const HomePageGigs({super.key});

  @override
  _HomePageGigs createState() => _HomePageGigs();
}

class _HomePageGigs extends State<HomePageGigs>
    with SingleTickerProviderStateMixin {
  final NotificationOverlay _notificationOverlay = NotificationOverlay();

  int _currentIndex = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

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

  @override
  Widget build(BuildContext context) {
    // Build the current page based on _currentIndex
    Widget currentPage;
    if (_currentIndex == 0) {
      // For home page, use HomeTopScreenContent and the RevenueContainer
      currentPage = Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  HomeTopScreenContent(
                    fadeAnimation: _fadeAnimation,
                    notificationOverlay: _notificationOverlay,
                    showRevenueContainer: true, // Enable the revenue container for this page

                  ),

                  GigsSection(fadeAnimation: _fadeAnimation),
                ],
              ),
            ),
          ),
        ],
      );
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
      // No app bar here, it's included in HomeTopScreenContent
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