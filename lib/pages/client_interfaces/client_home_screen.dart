import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lbricool/pages/client_interfaces/popular_services_section.dart';
import 'package:lbricool/pages/client_interfaces/top_rated_section.dart';
import 'package:lbricool/pages/client_interfaces/client_history_screen.dart';

import '../../controllers/auth_controller.dart';
import '../offers_form/babysitting_form.dart';
import '../student_interfaces/bottom_nav_bar.dart';
import '../student_interfaces/home_top_screen/notification_overlay.dart';
import 'package:lbricool/pages/client_interfaces/home_top_screen.dart';
import 'browse_categories_section.dart';
import 'create_general_button.dart';
import 'featured_section.dart';
import 'search_bar.dart';
// Import your history screen
// Import other screens you'll navigate to

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({Key? key}) : super(key: key);

  @override
  _ClientHomeScreenState createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen>
    with SingleTickerProviderStateMixin {

  String _userName = "User";
  int _currentIndex = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final NotificationOverlay _notificationOverlay = NotificationOverlay();
  final AuthController _authController = AuthController();
  bool _isLoading = true;

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

    // Fetch user name from backend
    _fetchUserData();
  }

  // Fetch user data from Firestore using the improved getCurrentUser method
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authController.getCurrentUser();
      if (user != null) {
        setState(() {
          _userName = user.fullName.isNotEmpty ? user.fullName : "User";
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToCreateServiceForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BabysittingJobForm()),
    );
  }

  // Handle navigation based on bottom nav bar selection
  void _handleNavigation(int index) {
    // If selecting the current index, do nothing
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    // Navigate to the appropriate screen based on index
    switch (index) {
      case 0: // Home - already on home screen
        break;
      case 1: // History
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ClientHistoryScreen()),
        ).then((_) {
          // When returning from History screen, reset the index to Home
          setState(() {
            _currentIndex = 0;
          });
        });
        break;
      /*case 2: // Chat
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        ).then((_) {
          // When returning from Chat screen, reset the index to Home
          setState(() {
            _currentIndex = 0;
          });
        });
        break;
      case 3: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        ).then((_) {
          // When returning from Profile screen, reset the index to Home
          setState(() {
            _currentIndex = 0;
          });
        });*/
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF40189D)))
          : Column(
        children: [
          // Top screen with curved app bar and search bar overlay
          HomeTopScreenContent(
            fadeAnimation: _fadeAnimation,
            notificationOverlay: _notificationOverlay,
            greeting: "Good Morning",
            name: _userName,
            showBackButton: false,
            showSearchBar: true, // Show search bar as overlay
            onSearch: (query) {
              print('Searching for: $query');
            },
          ),

          // Add spacing to accommodate the overlaid search bar
          const SizedBox(height: 30),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Popular services section with view all
                    _buildSectionWithHeader(
                      title: "Popular Services",
                      child: const PopularServicesSection(),
                    ),

                    const SizedBox(height: 20),

                    // Browse all categories section with view all
                    _buildSectionWithHeader(
                      title: "Browse all categories",
                      child: const BrowseCategoriesSection(),
                    ),

                    const SizedBox(height: 20),

                    // Top rated section with view all
                    _buildSectionWithHeader(
                      title: "Top rated",
                      child: const TopRatedSection(),
                    ),

                    const SizedBox(height: 20),

                    // Featured section (Dog walkers)
                    const FeaturedSection(),

                    const SizedBox(height: 30),

                    // Create general button with text
                    Column(
                      children: [
                        Text(
                          "Don't see what you are looking for?",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const CreateGeneralButton(),
                      ],
                    ),

                    const SizedBox(height: 80), // Space for FAB and bottom nav
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateServiceForm,
        backgroundColor: const Color(0xFF40189D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onItemTapped: _handleNavigation, // Use the new navigation handler
      ),
    );
  }

  // Helper method to build section with header and "View all" button
  Widget _buildSectionWithHeader({required String title, required Widget child}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to view all screen
              },
              child: Row(
                children: [
                  Text(
                    'View all',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Colors.grey[700],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}