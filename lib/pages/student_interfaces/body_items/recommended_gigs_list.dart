import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lbricool/pages/student_interfaces/browse_gigs_screen.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/gig_controller.dart';
import '../../../models/gig_model.dart';
import '../../../models/user_model.dart';
import '../../client_interfaces/gig_detail_page.dart';


class RecommendedGigsList extends StatefulWidget {
  final Animation<double>? fadeAnimation;

  const RecommendedGigsList({
    super.key,
    this.fadeAnimation,
  });

  @override
  State<RecommendedGigsList> createState() => _RecommendedGigsListState();
}

class _RecommendedGigsListState extends State<RecommendedGigsList> {
  final GigController _gigController = GigController();
  final AuthController _authController = AuthController();
  List<GigModel> _recommendedGigs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendedGigs();
  }

  Future<void> _loadRecommendedGigs() async {
    try {
      // Get current user to check their service category
      UserModel? currentUser = await _gigController.getCurrentUser();

      if (currentUser != null) {
        // Get recommended gigs based on user's service category
        // For students, we'll show gigs that match their skills or services
        if (currentUser.role == 'student') {
          List<String> userServices = currentUser.services ?? [];
          String? primaryService = userServices.isNotEmpty ? userServices[0] : null;

          // If user has a service category, fetch gigs in that category
          List<GigModel> gigs = await _gigController.getBrowseableGigs(
            category: primaryService,
          );

          // Limit to 5 gigs for the recommended section
          if (gigs.length > 5) {
            gigs = gigs.sublist(0, 5);
          }

          setState(() {
            _recommendedGigs = gigs;
            _isLoading = false;
          });
        } else {
          // For clients, show generic recommended gigs
          List<GigModel> gigs = await _gigController.getBrowseableGigs();

          if (gigs.length > 5) {
            gigs = gigs.sublist(0, 5);
          }

          setState(() {
            _recommendedGigs = gigs;
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading recommended gigs: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_recommendedGigs.isEmpty) {
      content = const Center(
        child: Text('No recommended gigs available'),
      );
    } else {
      content = ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _recommendedGigs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final gig = _recommendedGigs[index];
          return GestureDetector(
            onTap: () {
              // Navigate to gig details page only if the ID is not null
              if (gig.id != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GigDetailPage(gigId: gig.id!),
                  ),
                );
              } else {
                // Show an error message if the ID is null
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error: Gig ID not found')),
                );
              }
            },
            child: Container(
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
                  // Display category-based icon
                  _buildCategoryIcon(gig.category),
                  const SizedBox(height: 6),
                  Text(
                    gig.category,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gig.description ?? '',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${gig.hourlyRate ?? 0} DH/h',
                    style: const TextStyle(
                      color: Color(0xFF40189D),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // Apply fade animation if provided
    if (widget.fadeAnimation != null) {
      return Column(
        children: [
          _buildSectionHeader(context),
          SizedBox(
            height: 120,
            child: FadeTransition(
              opacity: widget.fadeAnimation!,
              child: content,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildSectionHeader(context),
        SizedBox(
          height: 120,
          child: content,
        ),
      ],
    );
  }

  Widget _buildCategoryIcon(String? category) {
    // Map category to specific icon or asset image
    Map<String, dynamic> categoryIcons = {
      'Tutor': {'asset': 'images/student_icon.png', 'icon': Icons.school},
      'Delivery': {'asset': 'images/delivery_icon.png', 'icon': Icons.delivery_dining},
      'Gardening': {'asset': 'images/gardening_icon.png', 'icon': Icons.nature},
      'Babysitter': {'asset': 'images/babysitter_icon.png', 'icon': Icons.child_care},
      // Add more category mappings as needed
    };

    // Default icon if category not found
    IconData defaultIcon = Icons.work;

    // Try to use asset image first
    if (category != null && categoryIcons.containsKey(category)) {
      String? assetPath = categoryIcons[category]['asset'];
      if (assetPath != null) {
        return Image.asset(
          assetPath,
          width: 35,
          height: 35,
        );
      } else {
        // Fallback to icon
        return Icon(categoryIcons[category]['icon'] ?? defaultIcon, size: 35);
      }
    }

    // Use default icon if no match found
    return Icon(defaultIcon, size: 35);
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Recommended Gigs',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {
              // Use push instead of pushReplacement
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BrowseGigsScreen()),
              );
            },
            child: const Text(
              'View More',
              style: TextStyle(
                color: Color(0xFF40189D),
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }
}