// gig_applications_screen.dart
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
          // Gig details header
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.monetization_on,
                            size: 16,
                            color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '\$${gig.hourlyRate.toStringAsFixed(2)}/hr',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${gig.startDate.day}/${gig.startDate.month}/${gig.startDate.year}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // Applications list
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
                    itemCount: applications.length,
                    itemBuilder: (context, index) {
                      final application = applications[index];
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
    );
  }

  void _viewStudentProfile(String studentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfileView(studentId: studentId),
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
}