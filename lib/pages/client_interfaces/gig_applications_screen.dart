import 'package:flutter/material.dart';
import 'package:lbricool/pages/client_interfaces/student_profile_view.dart';
import '../../controllers/application_controller.dart';
import '../../controllers/gig_controller.dart';
import '../../models/application_model.dart';
import '../../models/gig_model.dart';
import 'application_card.dart';

class GigApplicationsScreen extends StatefulWidget {
  final String gigId;

  const GigApplicationsScreen({
    Key? key,
    required this.gigId,
  }) : super(key: key);

  @override
  State<GigApplicationsScreen> createState() => _GigApplicationsScreenState();
}

class _GigApplicationsScreenState extends State<GigApplicationsScreen> {
  final ApplicationController _applicationController = ApplicationController();
  final GigController _gigController = GigController();

  late Future<List<ApplicationModel>> _applicationsFuture;
  late Future<GigModel?> _gigFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _applicationsFuture = _applicationController.getApplicationsForGig(widget.gigId);
    _gigFuture = _gigController.getGigById(widget.gigId);
  }

  Future<Widget?> _buildCompleteButton() async {
    final gig = await _gigFuture;

    final applications = await _applicationsFuture;

    final hasAcceptedApplication = applications.any((app) => app.status == 'accepted');

    bool canComplete = gig?.status == 'active' && hasAcceptedApplication;

    if (!canComplete) {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () => _updateGigStatus('completed'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF40189D),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'MARK AS COMPLETE',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF40189D),
        title: const Text(
          'Applications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          FutureBuilder<GigModel?>(
            future: _gigFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF40189D))),
                );
              }

              final gig = snapshot.data;
              if (gig == null) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: Text('Gig not found')),
                );
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gig.category,
                      style: TextStyle(
                        color: const Color(0xFF40189D).withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gig.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${gig.hourlyRate.toStringAsFixed(2)}/hr',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        if (gig.status != 'completed')
                          TextButton(
                            onPressed: () => _updateGigStatus('cancelled'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          Expanded(
            child: FutureBuilder<List<ApplicationModel>>(
              future: _applicationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF40189D)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final applications = snapshot.data ?? [];

                final relevantApplications = applications
                    .where((app) => ['pending', 'accepted', 'completed'].contains(app.status))
                    .toList();
                if (applications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search,
                            size: 64,
                            color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No applications yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Students will appear here when they apply',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadData();
                    setState(() {});
                  },
                  color: const Color(0xFF40189D),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: relevantApplications.length,
                    itemBuilder: (context, index) {
                      final application = relevantApplications[index];
                      return ApplicationCard(
                        application: application,
                        onViewProfile: () => _viewStudentProfile(application.studentId),
                        onAccept: application.status == 'pending'
                            ? () => _updateApplicationStatus(application.id!, 'accepted')
                            : null,
                        onReject: application.status == 'pending'
                            ? () => _updateApplicationStatus(application.id!, 'rejected')
                            : null,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: FutureBuilder<Widget?>(
        future: _buildCompleteButton(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink(); // Show nothing while loading
          }
          return snapshot.data ?? const SizedBox.shrink();
        },
      ),
    );
  }

  void _viewStudentProfile(String studentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfileView(
          studentId: studentId,
          gigId: widget.gigId,
        ),
      ),
    );
  }

  Future<void> _updateApplicationStatus(String applicationId, String status) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(status == 'accepted' ? 'Accept Application?' : 'Reject Application?'),
        content: Text(
            status == 'accepted'
                ? 'Do you want to accept this student? All other applications will be rejected.'
                : 'Do you want to reject this application?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: status == 'accepted' ? const Color(0xFF40189D) : Colors.red,
            ),
            child: Text(status == 'accepted' ? 'Accept' : 'Reject'),
          ),
        ],
      ),
    ) ?? false;

    if (result) {
      final success = await _applicationController.updateApplicationStatus(applicationId, status);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                status == 'accepted'
                    ? 'Application accepted successfully'
                    : 'Application rejected successfully'
            ),
            backgroundColor: status == 'accepted' ? Colors.green : Colors.grey[700],
          ),
        );
        _loadData();
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update application status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateGigStatus(String status) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(status == 'completed' ? 'Complete Gig?' : 'Cancel Gig?'),
        content: Text(
            status == 'completed'
                ? 'Are you sure you want to mark this gig as completed?'
                : 'Are you sure you want to cancel this gig?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: status == 'completed' ? Colors.green : Colors.red,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    ) ?? false;

    if (result) {
      final success = await _applicationController.updateGigStatus(widget.gigId, status);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                status == 'completed'
                    ? 'Gig marked as completed'
                    : 'Gig cancelled successfully'
            ),
            backgroundColor: status == 'completed' ? Colors.green : Colors.red,
          ),
        );
        _loadData();
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update gig status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}