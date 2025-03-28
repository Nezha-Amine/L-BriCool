// client_history_screen.dart
import 'package:flutter/material.dart';
import '../../controllers/gig_controller.dart';
import '../../models/gig_model.dart';
import '../chat/chat_users_screen.dart';
import '../student_interfaces/home_top_screen/notification_overlay.dart';
import '../student_interfaces/bottom_nav_bar.dart'; // Add this import
import 'gig_applications_screen.dart';
import 'history_top_screen.dart';
import 'gig_history_card.dart';


class ClientHistoryScreen extends StatefulWidget {
  const ClientHistoryScreen({Key? key}) : super(key: key);

  @override
  _ClientHistoryScreenState createState() => _ClientHistoryScreenState();
}

class _ClientHistoryScreenState extends State<ClientHistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final NotificationOverlay _notificationOverlay = NotificationOverlay();
  final GigController _gigController = GigController();

  // Add current index for bottom navigation
  int _currentIndex = 1; // Set to 1 for History tab

  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All', 'Active', 'Pending', 'Completed', 'Cancelled'
  ];

  List<GigModel> _allGigs = [];
  List<GigModel> _filteredGigs = [];
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

    _loadGigs();
  }

  Future<void> _loadGigs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final gigs = await _gigController.getMyGigs();
      setState(() {
        _allGigs = gigs;
        _applyFilter(_selectedFilter);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading gigs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;

      if (filter == 'All') {
        _filteredGigs = List.from(_allGigs);
      } else {
        String statusFilter = filter.toLowerCase();
        _filteredGigs = _allGigs.where((gig) => gig.status.toLowerCase() == statusFilter).toList();
      }
    });
  }

  void _handleNavigation(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0: // Home
        Navigator.pop(context);
        break;
      case 1:
        break;
      case 2:
        Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatUsersScreen(isClient: true)),
      ).then((_) {
        setState(() {
          _currentIndex = 0;
        });
      });
        break;
      case 3: // Profile
        Navigator.pop(context);
        /*
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        */
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          HistoryTopScreen(
            fadeAnimation: _fadeAnimation,
            notificationOverlay: _notificationOverlay,
          ),

          const SizedBox(height: 20),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filterOptions.length,
                itemBuilder: (context, index) {
                  final filter = _filterOptions[index];
                  final isSelected = filter == _selectedFilter;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(filter),
                      onSelected: (_) => _applyFilter(filter),
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFF8B5CF6).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF40189D),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFF40189D) : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Gig listings
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF40189D)))
                : _filteredGigs.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No gigs found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedFilter == 'All'
                        ? 'You haven\'t posted any gigs yet'
                        : 'No $_selectedFilter gigs found',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadGigs,
              color: const Color(0xFF40189D),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _filteredGigs.length,
                itemBuilder: (context, index) {
                  final gig = _filteredGigs[index];
                  return GigHistoryCard(
                    gig: gig,
                    onTap: () => _navigateToApplications(gig),
                    onCancel: gig.status == 'pending' ? () => _cancelGig(gig.id!) : null,
                    onDelete: gig.status == 'pending' ? () => _deleteGig(gig.id!) : null,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onItemTapped: _handleNavigation,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: const Color(0xFF40189D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _navigateToApplications(GigModel gig) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GigApplicationsScreen(gigId: gig.id!),
      ),
    ).then((_) => _loadGigs());
  }

  Future<void> _cancelGig(String gigId) async {
    // Show confirmation dialog
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Gig?'),
        content: const Text('Are you sure you want to cancel this gig?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    ) ?? false;

    if (shouldCancel) {
      final success = await _gigController.updateGigStatus(gigId, 'cancelled');
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gig cancelled successfully')),
        );
        _loadGigs();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel gig'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteGig(String gigId) async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Gig?'),
        content: const Text('Are you sure you want to delete this gig? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes, Delete'),
          ),
        ],
      ),
    ) ?? false;

    if (shouldDelete) {
      final success = await _gigController.deleteGig(gigId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gig deleted successfully')),
        );
        _loadGigs();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete gig'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}