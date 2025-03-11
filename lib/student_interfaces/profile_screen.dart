import 'package:flutter/material.dart';

import 'bottom_nav_bar.dart';
import 'browse_gigs_screen.dart';
import 'chat_screen.dart';
import 'history_screen.dart';
import 'home_page_gigs.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 4;
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
  Widget build(BuildContext context) {
    // Build the current page based on _currentIndex. Note that for the home page,
    // we rebuild _buildHomeContent() so that changes to selectedCategory are reflected.
    Widget currentPage;
    if (_currentIndex == 0) {
      currentPage = MainScreen();
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
