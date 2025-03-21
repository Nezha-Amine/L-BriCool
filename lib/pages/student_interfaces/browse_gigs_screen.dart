import 'package:flutter/material.dart';

import '../../controllers/gig_controller.dart';
import '../../models/gig_model.dart';
import '../client_interfaces/gig_detail_page.dart';
import 'home_top_screen/notification_overlay.dart';
import 'home_top_screen/top_screen_content.dart';

class BrowseGigsScreen extends StatefulWidget {
  const BrowseGigsScreen({super.key});

  @override
  State<BrowseGigsScreen> createState() => _BrowseGigsScreenState();
}

class _BrowseGigsScreenState extends State<BrowseGigsScreen> with SingleTickerProviderStateMixin {
  final GigController _gigController = GigController();
  final NotificationOverlay _notificationOverlay = NotificationOverlay();
  String selectedCategory = 'All';
  String sortBy = 'All';
  List<GigModel> gigs = [];
  bool isLoading = true;

  // Animation controller for the top bar fade effect
  late AnimationController _controller;
  late Animation<double> _fadeAnimation = const AlwaysStoppedAnimation<double>(1.0);

  @override
  void initState() {
    super.initState();
    _loadGigs();

    // Initialize animation controller
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

  Future<void> _loadGigs() async {
    setState(() {
      isLoading = true;
    });

    // Here we would call the appropriate method in GigController
    // For now, let's use a placeholder method
    try {
      final fetchedGigs = await _gigController.getBrowseableGigs(category: selectedCategory);
      setState(() {
        gigs = fetchedGigs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
    _loadGigs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      // Remove the appBar since we're using the custom curved one
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          HomeTopScreenContent(
            fadeAnimation: _fadeAnimation,
            notificationOverlay: _notificationOverlay,
            greeting: "Browse", // Keep this as is for the title
            name: "Gigs",       // Keep this as is for the subtitle
            showBackButton: true, // Enable the back button
            onBackPressed: () => Navigator.pop(context), // Handle back navigation
            showRevenueContainer: false, // Keep this as is
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
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
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search gigs here...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // Categories section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // Category pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _CategoryPill(
                  icon: Icons.child_care,
                  label: 'Babysitting',
                  isSelected: selectedCategory == 'Babysitting',
                  onTap: () => _onCategorySelected('Babysitting'),
                ),
                _CategoryPill(
                  icon: Icons.edit,
                  label: 'Tutoring',
                  isSelected: selectedCategory == 'Tutoring',
                  onTap: () => _onCategorySelected('Tutoring'),
                ),
                _CategoryPill(
                  icon: Icons.more_horiz,
                  label: 'Others',
                  isSelected: selectedCategory == 'Others',
                  onTap: () => _onCategorySelected('Others'),
                ),
              ],
            ),
          ),

          // Filter and Sort options
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // All Filter button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: const [
                      Icon(Icons.filter_list, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text('All Filter', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),

                // Sort by dropdown
                Row(
                  children: [
                    const Text('Sort by', style: TextStyle(color: Colors.black87)),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: sortBy,
                      icon: const Icon(Icons.arrow_drop_down),
                      underline: Container(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            sortBy = newValue;
                          });
                          // Implement sorting logic
                        }
                      },
                      items: <String>['All', 'Price', 'Date']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Gig listings
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6A0DAD)))
                : gigs.isEmpty
                ? const Center(child: Text('No gigs found'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: gigs.length,
              itemBuilder: (context, index) {
                return GigListItem(
                  gig: gigs[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GigDetailPage(gigId: gigs[index].id!),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Category pill widget
class _CategoryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE6E0F3) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF6A0DAD) : Colors.grey,
              size: 20,
            ),
            if (label != 'Others') const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6A0DAD) : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Gig list item widget
class GigListItem extends StatelessWidget {
  final GigModel gig;
  final VoidCallback onTap;

  const GigListItem({
    super.key,
    required this.gig,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.amber[200],
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 12),

              // Gig details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category title
                    Text(
                      gig.category,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Show children details if babysitting
                    if (gig.category == 'Babysitting' && gig.childrenDetails.isNotEmpty)
                      Text(
                        _formatChildrenDetails(gig.childrenDetails),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Date
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.purple[700]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(gig.startDate),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Time
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.purple[700]),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(gig.startTime, gig.endTime),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Price and details button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.attach_money, size: 20, color: Colors.purple[700]),
                            Text(
                              '${gig.hourlyRate.toInt()} DH/h',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple[700],
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text('SEE DETAILS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatChildrenDetails(List<Map<String, String>> childrenDetails) {
    int toddlerCount = 0;
    int babyCount = 0;

    for (var child in childrenDetails) {
      if (child['type']?.toLowerCase() == 'toddler') {
        toddlerCount++;
      } else if (child['type']?.toLowerCase() == 'baby') {
        babyCount++;
      }
    }

    List<String> parts = [];
    if (toddlerCount > 0) {
      parts.add('$toddlerCount Toddler');
    }
    if (babyCount > 0) {
      parts.add('$babyCount Baby');
    }

    return parts.join(', ');
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  String _formatTime(Map<String, int> startTime, Map<String, int> endTime) {
    String formatTimeOfDay(Map<String, int> time) {
      int hour = time['hour'] ?? 0;
      int minute = time['minute'] ?? 0;
      String period = hour >= 12 ? 'PM' : 'AM';
      hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$hour:${minute.toString().padLeft(2, '0')} $period';
    }

    return '${formatTimeOfDay(startTime)} - ${formatTimeOfDay(endTime)}';
  }
}