import 'package:flutter/material.dart';

import '../../controllers/application_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/gig_controller.dart';
import '../../models/application_model.dart';
import '../../models/gig_model.dart';

import '../chat/chat_screen.dart';
import '../chat/chat_users_screen.dart';
import '../student_form/success_dialogue.dart';
import '../student_interfaces/bottom_nav_bar.dart';
import '../student_interfaces/browse_gigs_screen.dart';
import '../student_interfaces/history_screen.dart';
import '../student_interfaces/home_page_gigs.dart';
import '../student_interfaces/home_top_screen/notification_overlay.dart';
import '../student_interfaces/home_top_screen/top_screen_content.dart';
import '../student_interfaces/profile_screen.dart';

class GigDetailPage extends StatefulWidget {
  final String gigId;

  const GigDetailPage({Key? key, required this.gigId}) : super(key: key);

  @override
  State<GigDetailPage> createState() => _GigDetailPageState();
}

class _GigDetailPageState extends State<GigDetailPage> {
  final GigController _gigController = GigController();
  final ApplicationController _applicationController = ApplicationController();
  bool isLoading = true;
  GigModel? gig;
  ApplicationModel? myApplication;
  int _currentIndex = 1;
  final Animation<double> _fadeAnimation = AlwaysStoppedAnimation(1.0);
  final NotificationOverlay _notificationOverlay = NotificationOverlay();


  @override
  void initState() {
    super.initState();
    _loadGigDetails();
  }


  Future<void> _loadGigDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final gigDetails = await _gigController.getGigById(widget.gigId);

      bool hasApplied = await _applicationController.hasAppliedToGig(widget.gigId);

      ApplicationModel? applicationDetails;
      if (hasApplied) {
        applicationDetails = await _getMyApplicationForGig(widget.gigId);
      }

      setState(() {
        gig = gigDetails;
        myApplication = applicationDetails;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading gig details: $e')),
      );
    }
  }

  Future<ApplicationModel?> _getMyApplicationForGig(String gigId) async {
    try {
      List<ApplicationModel> myApplications = await _applicationController.getMyApplications();

      for (var application in myApplications) {
        if (application.gigId == gigId) {
          return application;
        }
      }

      return null;
    } catch (e) {
      print('Error getting application for gig: $e');
      return null;
    }
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

  void _navigateToPage(int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const HomePageGigs();
        break;
      case 1:
        page = const BrowseGigsScreen();
        break;
      case 2:
        page = const HistoryScreen();
        break;
      case 3:
        page = const ChatUsersScreen();
        break;
      case 4:
        page = const ProfileScreen();
        break;
      default:
        page = const HomePageGigs();
    }

    setState(() {
      _currentIndex = index;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _applyForGig(BuildContext context, String gigId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF6A0DAD)),
        );
      },
    );

    bool success = await _applicationController.applyForGig(gigId);

    Navigator.pop(context);

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SuccessDialog(
            message: 'Your application has been sent successfully! You will be notified once the client reviews your application.',

            onOkPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to apply for this gig. You may have already applied or an error occurred.')),
      );
    }
  }

  void _cancelApplication(BuildContext context, String applicationId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Application'),
          content: const Text('Are you sure you want to cancel your application for this gig?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                );

                bool success = await _applicationController.updateApplicationStatus(applicationId, 'cancelled');

                Navigator.pop(context);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Your application has been cancelled.')),
                  );

                  _loadGigDetails();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to cancel application. Please try again.')),
                  );
                }
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _markGigComplete(BuildContext context, String applicationId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Complete Gig'),
          content: const Text('Are you sure you want to mark this gig as complete?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF6A0DAD)),
                    );
                  },
                );

                bool success = await _applicationController.updateApplicationStatus(applicationId, 'completed');

                Navigator.pop(context);

                if (success) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return SuccessDialog(
                        message: 'Great job! You\'ve marked this gig as complete.',
                        onOkPressed: () {
                          // Close dialog and navigate to history
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HistoryScreen()),
                          );
                        },
                      );
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to complete gig. Please try again.')),
                  );
                }
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToChat(BuildContext context) async {
    final chatController = ChatController();

    try {
      await chatController.navigateToChat(
          context: context,
          recipientId: gig!.clientId,
          gigId: gig!.id
      );
    } catch (e) {
      print('Error navigating to chat: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF40189D); // Purple

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          HomeTopScreenContent(
            fadeAnimation: _fadeAnimation,
            notificationOverlay: _notificationOverlay,
            greeting: "",
            name: "Gig Details",
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryColor))
                : gig == null
                ? const Center(child: Text('Gig not found'))
                : SingleChildScrollView(
              child: _buildGigDetails(context, primaryColor),
            ),
          ),

          CustomBottomNavigationBar(
            currentIndex: _currentIndex,
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
            onItemTapped: (index) {
              _navigateToPage(index);
            },
          ),
        ],
      ),
    );
  }
  Widget _buildGigDetails(BuildContext context, Color primaryColor) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wave at top


          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + Name + Role
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.amber[200],
                      child: const Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 12),
                    // Name & Role
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gig!.clientName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          gig!.category,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      gig!.address,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Date & Time
                Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(gig!.startDate),
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(gig!.startTime, gig!.endTime),
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Show application status if applicable
                if (myApplication != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(myApplication!.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Application status: ${_formatStatus(myApplication!.status)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Description
                Text(
                  gig!.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // Details section
                Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const Divider(thickness: 1, height: 20),

                // Kids info if babysitting
                if (gig!.category == 'Babysitting' && gig!.childrenDetails.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Kid(s) age',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...gig!.childrenDetails.map((child) => _buildChildInfoBox(child)),
                  const SizedBox(height: 8),
                ],

                if (gig!.languages.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Required language(s)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: gig!.languages.map((language) => _InfoChip(label: language)).toList(),
                  ),
                ],

                // Tasks
                if (gig!.tasks.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Additional Tasks',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: gig!.tasks.map((task) => _InfoChip(label: task)).toList(),
                  ),
                ],

                const SizedBox(height: 24),

                // Hourly Rate
                Row(
                  children: [
                    const Text(
                      'Starting at :',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.money, color: primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      '${gig!.hourlyRate.toInt()} DH/h',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Dynamic button based on application status
                SizedBox(
                  width: double.infinity,
                  child: _buildActionButton(context, primaryColor),
                ),
                const SizedBox(height: 80), // Extra space for bottom nav
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }

  String _formatStatus(String status) {
    return status.substring(0, 1).toUpperCase() + status.substring(1);
  }

  Widget _buildActionButton(BuildContext context, Color primaryColor) {
    if (myApplication == null) {
      return ElevatedButton(
        onPressed: () => _applyForGig(context, gig!.id!),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text(
          'APPLY',
          style: TextStyle(fontWeight: FontWeight.bold , color: Colors.white),
        ),
      );
    }

    if (myApplication != null && myApplication!.status.toLowerCase() == 'accepted') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _markGigComplete(context, myApplication!.id!),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'MARK AS COMPLETE',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => _navigateToChat(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            child: const Icon(Icons.chat, color: Colors.white),
          ),
        ],
      );
    }

    switch (myApplication!.status.toLowerCase()) {
      case 'pending':
        return ElevatedButton(
          onPressed: () => _cancelApplication(context, myApplication!.id!),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'CANCEL APPLICATION',
            style: TextStyle(fontWeight: FontWeight.bold , color: Colors.white),
          ),
        );

      case 'accepted':
        DateTime now = DateTime.now();
        bool canComplete = now.isAfter(gig!.startDate);

        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: canComplete
                    ? () => _markGigComplete(context, myApplication!.id!)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  disabledBackgroundColor: Colors.green.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  canComplete ? 'MARK AS COMPLETE' : 'ACCEPTED - WAITING FOR GIG DATE',
                  style: const TextStyle(fontWeight: FontWeight.bold , color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _navigateToChat(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              child: const Icon(Icons.chat, color: Colors.white),
            ),
          ],
        );

      case 'rejected':
        return ElevatedButton(
          onPressed: null, // Disabled
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'APPLICATION REJECTED',
            style: TextStyle(fontWeight: FontWeight.bold , color: Colors.white),
          ),
        );

      case 'cancelled':
        return ElevatedButton(
          onPressed: () => _applyForGig(context, gig!.id!),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'APPLY AGAIN',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );

      case 'completed':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: null, // Disabled
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'GIG COMPLETED',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _navigateToChat(context), // Always allow chat for completed gigs
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              child: const Icon(Icons.chat, color: Colors.white),
            ),
          ],
        );


      default:
        return ElevatedButton(
          onPressed: () => _applyForGig(context, gig!.id!),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'APPLY',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
    }
  }
  Widget _buildChildInfoBox(Map<String, String> child) {
    String type = child['type'] ?? 'Child';
    String age = child['age'] ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$type, $age'),
    );
  }
}

// Wave clipper
class _PurpleWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // We'll draw a wave from left to right at the bottom.
    final path = Path()
      ..lineTo(0, size.height - 40)
      ..quadraticBezierTo(
        size.width * 0.5, // control point X
        size.height,      // control point Y
        size.width,       // end point X
        size.height - 40, // end point Y
      )
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}