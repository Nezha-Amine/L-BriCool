import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../controllers/application_controller.dart';
import '../../controllers/gig_controller.dart';
import '../../models/application_model.dart';
import '../../models/gig_model.dart';
import '../client_interfaces/gig_detail_page.dart';
import 'home_top_screen/notification_overlay.dart';
import 'home_top_screen/top_screen_content.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late NotificationOverlay _notificationOverlay;

  final ApplicationController _applicationController = ApplicationController();
  final GigController _gigController = GigController();

  String _selectedTab = 'Applications';
  String _selectedStatus = 'All';

  bool _isLoading = false;
  List<ApplicationModel> _applications = [];
  List<GigModel> _gigs = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _notificationOverlay = NotificationOverlay();
    _animationController.forward();

    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    if (_selectedTab == 'Applications') {
      await _loadApplications();
    } else {
      await _loadGigs();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadApplications() async {
    List<ApplicationModel> applications = await _applicationController.getMyApplications();

    // Filter by status if needed, but only include application-specific statuses
    if (_selectedStatus != 'All') {
      applications = applications.where((app) =>
      ['pending', 'accepted', 'rejected', 'cancelled'].contains(app.status.toLowerCase()) &&
          app.status.toLowerCase() == _selectedStatus.toLowerCase()
      ).toList();
    } else {
      // When 'All' is selected, only show application-specific statuses
      applications = applications.where((app) =>
          ['pending', 'accepted', 'rejected', 'cancelled'].contains(app.status.toLowerCase())
      ).toList();
    }

    setState(() {
      _applications = applications;
    });
  }

  Future<void> _loadGigs() async {
    List<GigModel> gigs = await _gigController.getStudentGigs();

    if (_selectedStatus != 'All') {
      gigs = gigs.where((gig) =>
      ['active', 'completed', 'cancelled'].contains(gig.status.toLowerCase()) &&
          gig.status.toLowerCase() == _selectedStatus.toLowerCase()
      ).toList();
    } else {
      gigs = gigs.where((gig) =>
          ['active', 'completed', 'cancelled'].contains(gig.status.toLowerCase())
      ).toList();
    }

    setState(() {
      _gigs = gigs;
    });
  }

  Future<void> _cancelApplication(String applicationId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Application'),
        content: const Text('Are you sure you want to cancel this application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF40189D),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      bool success = await _applicationController.updateApplicationStatus(applicationId, 'cancelled');
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application cancelled successfully')),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to cancel application')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          HomeTopScreenContent(
            fadeAnimation: _fadeAnimation,
            notificationOverlay: _notificationOverlay,
            greeting: "",
            name: "History",
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(),

          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildTabButton('Applications'),
                const SizedBox(width: 10),
                _buildTabButton('Gigs'),
              ],
            ),
          ),

          // Status filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusChip('All'),
                  if (_selectedTab == 'Applications') ...[
                    _buildStatusChip('Pending'),
                    _buildStatusChip('Accepted'),
                    _buildStatusChip('Rejected'),
                    _buildStatusChip('Cancelled'),
                  ] else ...[
                    _buildStatusChip('Active'),
                    _buildStatusChip('Completed'),
                    _buildStatusChip('Cancelled'),
                  ],
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF40189D)))
                : _selectedTab == 'Applications'
                ? _buildApplicationsList()
                : _buildGigsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label) {
    bool isSelected = (_selectedTab == label);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedTab != label) {
            setState(() {
              _selectedTab = label;
              _selectedStatus = 'All';
            });
            _loadData();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF40189D) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    bool isSelected = (_selectedStatus == status);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(status),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = status;
          });
          _loadData();
        },
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF8B5CF6),
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildApplicationsList() {
    if (_applications.isEmpty) {
      return const Center(
        child: Text('No applications found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _applications.length,
      itemBuilder: (context, index) {
        final application = _applications[index];
        return FutureBuilder<GigModel?>(
          future: _gigController.getGigById(application.gigId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Card(
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF40189D))),
                ),
              );
            }

            final gig = snapshot.data;
            if (gig == null) {
              return const SizedBox.shrink();
            }

            Color statusColor;
            switch (application.status) {
              case 'pending':
                statusColor = Colors.orange;
                break;
              case 'accepted':
                statusColor = Colors.green;
                break;
              case 'rejected':
                statusColor = Colors.red;
                break;
              case 'cancelled':
                statusColor = Colors.grey;
                break;
              default:
                statusColor = Colors.black;
            }

            // Using similar card design to BrowseGigsScreen
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GigDetailPage(gigId: gig.id!),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.purple[200],
                        child: const Icon(Icons.person, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 12),

                      // Gig details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category title and status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    gig.category,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    application.status.toUpperCase(),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
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
                                  _formatTimeFromMap(gig.startTime) + ' - ' + _formatTimeFromMap(gig.endTime),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Application date
                            Row(
                              children: [
                                Icon(Icons.date_range, size: 14, color: Colors.purple[700]),
                                const SizedBox(width: 4),
                                Text(
                                  'Applied: ${_formatTimestamp(application.appliedAt)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Price and cancel button for pending applications
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
                                if (application.status == 'pending')
                                  ElevatedButton(
                                    onPressed: () => _cancelApplication(application.id!),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[400],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                    child: const Text(
                                      'CANCEL',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                else
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => GigDetailPage(gigId: gig.id!),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple[700],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                    child: const Text(
                                      'SEE DETAILS',
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
          },
        );
      },
    );
  }

  Widget _buildGigsList() {
    if (_gigs.isEmpty) {
      return const Center(
        child: Text('No gigs found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _gigs.length,
      itemBuilder: (context, index) {
        final gig = _gigs[index];

        Color statusColor;
        switch (gig.status) {
          case 'active':
            statusColor = Colors.green;
            break;
          case 'completed':
            statusColor = Colors.blue;
            break;
          case 'cancelled':
            statusColor = Colors.grey;
            break;
          default:
            statusColor = Colors.black;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
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
                      // Category title and status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              gig.category,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              gig.status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
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
                            _formatTimeFromMap(gig.startTime) + ' - ' + _formatTimeFromMap(gig.endTime),
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
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GigDetailPage(gigId: gig.id!),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: const Text(
                              'SEE DETAILS',
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
        );
      },
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  String _formatTimeFromMap(Map<String, int> timeMap) {
    final hour = timeMap['hour'] ?? 0;
    final minute = timeMap['minute'] ?? 0;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
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
}