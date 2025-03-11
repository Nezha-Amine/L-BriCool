import 'package:flutter/material.dart';
import 'package:lbrikol/animations/purple_wave_clipper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Currently, this files runs independently
// try to run it bo7do to see what's in it
// Note: it's not the last version yet, still improving it

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // Track which category is selected
  String selectedCategory = "Gigs";

  // Example data for recommended and recent gigs
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

  @override
  void initState() {
    super.initState();
    // Basic animation controller
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

  // Rating stars
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Stack(
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
                  child: const SizedBox(height: 220), // Adjust wave height here
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // TOP BAR
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Photo + "Hello Bahae Client"
                        Row(
                          children: [
                            // Profile photo
                            CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  const AssetImage('images/client_icon.png'),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Hello,\nBahae Assaoui',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        // Right side: notification + menu
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_none,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                // Handle notification action
                              },
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                                size: 28,
                              ),
                              onSelected: (value) {
                                switch (value) {
                                  case 'Profile':
                                    // Go to profile
                                    break;
                                  case 'My Gigs':
                                    // Show user's gigs
                                    break;
                                  case 'Add a Gig':
                                    // Open add gig form
                                    break;
                                  case 'Log Out':
                                    // Log out logic
                                    break;
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  const PopupMenuItem(
                                    value: 'Profile',
                                    child: Text('Profile'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'My Gigs',
                                    child: Text('My Gigs'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Add a Gig',
                                    child: Text('Add a Gig'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Log Out',
                                    child: Text('Log Out'),
                                  ),
                                ];
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Search bar
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search gigs here...',
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),

                  // "Today's Revenue" card
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
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
                        const Icon(
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

                  // Main Content Depending on Category
                  const SizedBox(height: 10),
                  if (selectedCategory == "Gigs") _buildGigsSection(),
                  if (selectedCategory == "General") _buildGeneralSection(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Category button that toggles selectedCategory
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

  // The Gigs Section: Recommended & Recent Gigs
  Widget _buildGigsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recommended Gigs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
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

        // Recent Gigs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
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

  // The General Section (placeholder content)
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
}
