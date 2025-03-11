import 'package:flutter/material.dart';
import 'package:lbrikol/animations/purple_wave_clipper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lbrikol/auth/register.dart';
import 'package:lbrikol/student_interfaces/profile_screen.dart';

import 'browse_gigs_screen.dart';
import 'chat_screen.dart';
import 'history_screen.dart';
import 'home_top_screen/notification_overlay.dart';
import 'home_top_screen/menu_content.dart'; // New MenuContent class

void main() {
  runApp(const MyApp());
}

// Root of the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(), // Now we start from MainScreen which has bottom nav
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
  // Create an instance of NotificationOverlay
  final NotificationOverlay _notificationOverlay = NotificationOverlay();

  // Index to track which bottom nav item is selected
  int _currentIndex = 0;

  // Animation controller (kept for the Home page usage)
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // Example data for recommended and recent gigs (used in the Home screen)
  final List<Map<String, dynamic>> recommendedGigs = [
    {
      'title': 'Tutor',
      'subtitle': 'Math',
      'price': '100 DH/h',
      'image': 'images/student_icon.png',
    },
    {
      'title': 'Delivery',
      'subtitle': 'Fast errands',
      'price': '80 DH/h',
      'image': 'images/student_icon.png',
    },
    {
      'title': 'Gardening',
      'subtitle': 'Flower care',
      'price': '120 DH/h',
      'image': 'images/student_icon.png',
    },
    {
      'title': 'Tutor',
      'subtitle': 'Physics',
      'price': '80 DH/h',
      'image': 'images/student_icon.png',
    },
  ];

  final List<Map<String, dynamic>> recentGigs = [
    {
      'title': 'Babysitter',
      'subtitle': '1 Toddler',
      'price': '100 DH/h',
      'rating': 4.9,
      'image': 'images/client_icon.png',
      'reviews': 32
    },
    {
      'title': 'House Cleaning',
      'subtitle': '3 hours',
      'price': '90 DH/h',
      'rating': 4.8,
      'image': 'images/client_icon.png',
      'reviews': 20
    },
    {
      'title': 'Gardening',
      'subtitle': '2 hours',
      'price': '110 DH/h',
      'rating': 4.7,
      'image': 'images/client_icon.png',
      'reviews': 15
    },
    {
      'title': 'Teacher',
      'subtitle': '3 hours',
      'price': '80 DH/h',
      'rating': 4.9,
      'image': 'images/client_icon.png',
      'reviews': 19
    },
  ];

  // For toggling between “Gigs” and “General” in the Home screen
  String selectedCategory = "Gigs";

  @override
  void initState() {
    super.initState();
    // Set up the animation controller for fade effects
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

  // Define a list of pages for the bottom navigation
  // Replace the placeholder screens with your actual screens.
  late final List<Widget> _pages = [
    _buildHomeContent(),
    const BrowseGigsScreen(),
    const HistoryScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Show one of the pages based on the current index
      body: _pages[_currentIndex],

      // Bottom navigation bar with five items
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        // Blue for selected item, black for unselected
        selectedItemColor: const Color(0xFF40189D),
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        items: const [
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
        ],
      ),
    );
  }

  // 1) HOME CONTENT: reuses your existing wave background and gigs sections
  Widget _buildHomeContent() {
    return Stack(
      children: [
        // Purple wave background
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: PurpleWaveClipper(),
            child: Container(
              color: const Color(0xFF40189D),
              child: const SizedBox(height: 220),
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16, top: 10),
            child: Column(
              children: [
                // TOP BAR
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Photo + "Hello Client Name"
                      const Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                AssetImage('images/client_icon.png'),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Hello,\nBahae Assaoui',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      // Right side: notification + menu (using MenuContent widget)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              // Show notifications overlay when button is pressed
                              _notificationOverlay.showNotifications(context);
                            },
                          ),
                          MenuContent(
                            onSelected: (value) {
                              switch (value) {
                                case 'Profile':
                                  // Navigate to profile
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ProfileScreen()),
                                  );
                                  break;
                                case 'My Gigs':
                                  // Show user's gigs
                                  break;
                                case 'Add a Gig':
                                  // Open add gig form
                                  break;
                                case 'Log Out':
                                  // Log out logic
                                  // Navigate to Register
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterPage()),
                                  );
                                  break;
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // "Today's Revenue" card
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Today's Revenue",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "200 MAD",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        FontAwesomeIcons.sackDollar,
                        color: Color(0xFF40189D),
                        size: 30,
                      )
                    ],
                  ),
                ),

                // CATEGORY BUTTONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildCategoryButton("Gigs"),
                      const SizedBox(width: 10),
                      _buildCategoryButton("General"),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                // Conditionally show Gigs or General
                if (selectedCategory == "Gigs") _buildGigsSection(),
                if (selectedCategory == "General") _buildGeneralSection(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Build category button used on the Home screen
  Widget _buildCategoryButton(String label) {
    bool isSelected = (selectedCategory == label);
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF40189D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // The Gigs Section: Recommended & Recent Gigs (Home screen)
  Widget _buildGigsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recommended Gigs header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recommended Gigs",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "More",
                style: TextStyle(
                  color: Color(0xFF40189D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Recommended Gigs horizontal list
        SizedBox(
          height: 120,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ListView.separated(
              padding: const EdgeInsets.only(left: 16, right: 16),
              scrollDirection: Axis.horizontal,
              itemCount: recommendedGigs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final gig = recommendedGigs[index];
                return Container(
                  width: 120,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      gig['image'] != null
                          ? Image.asset(
                              gig['image'],
                              width: 35,
                              height: 35,
                            )
                          : const Icon(Icons.work),
                      const SizedBox(height: 6),
                      Text(
                        gig['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gig['subtitle'] ?? '',
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        gig['price'] ?? '',
                        style: const TextStyle(
                          color: Color(0xFF40189D),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        // Recent Gigs header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Gigs",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "View More",
                style: TextStyle(
                  color: Color(0xFF40189D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Recent Gigs list
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: recentGigs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final gig = recentGigs[index];
            return ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage:
                    gig['image'] != null ? AssetImage(gig['image']) : null,
              ),
              title: Text(gig['title']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gig['subtitle'] ?? '',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        gig['price'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF40189D),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildRatingStars(gig['rating']),
                      const SizedBox(width: 5),
                      Text(
                        '${gig['rating']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.more_vert),
            );
          },
        ),
      ],
    );
  }

  // A placeholder for "General" category content on Home screen
  Widget _buildGeneralSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text(
          "This is the 'General' category content.\n"
          "You can customize it as you wish!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  // Helper method to build rating stars
  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;

    List<Widget> stars = [];
    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber, size: 16));
    }
    if (halfStar) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 16));
    }
    return Row(children: stars);
  }
}
