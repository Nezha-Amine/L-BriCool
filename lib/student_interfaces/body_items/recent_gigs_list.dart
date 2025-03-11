import 'package:flutter/material.dart';

// This is the class of Recent Gigs
class RecentGigsList extends StatelessWidget {
  // Example data for recommended and recent gigs (used in the Home screen)
  // This List (recommendedGigs) will be filled with data from Database
  final List<Map<String, dynamic>> recentGigs = [
    {
      'title': 'Babysitter',
      'subtitle': '1 Toddler',
      'price': '100 DH/h',
      'rating': 4.5,
      'image': 'images/client_icon.png',
      'reviews': 32
    },
    {
      'title': 'House Cleaning',
      'subtitle': '3 hours',
      'price': '90 DH/h',
      'rating': 4.0,
      'image': 'images/client_icon.png',
      'reviews': 20
    },
    {
      'title': 'Gardening',
      'subtitle': '2 hours',
      'price': '110 DH/h',
      'rating': 5.0,
      'image': 'images/client_icon.png',
      'reviews': 15
    },
    {
      'title': 'Teacher',
      'subtitle': '3 hours',
      'price': '80 DH/h',
      'rating': 3.5,
      'image': 'images/client_icon.png',
      'reviews': 19
    },
  ];

  RecentGigsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: recentGigs.length,
      separatorBuilder: (_, __) => Divider(
        color: Colors.grey[400], // Customize the color of the separator
        thickness: 0.8, // Adjust thickness if needed
        height: 16, // Space between items
      ),
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
          trailing: IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () {
              // TODO: Make logic when clicking on a Gig
              // It should show the info of the clicked gig
            },
          ),
        );
      },
    );
  }

  // Helper method to build rating stars
  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = rating - fullStars >= 0.5;

    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, size: 14, color: Colors.amber);
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(Icons.star_half, size: 14, color: Colors.amber);
        }
        return const Icon(Icons.star_border, size: 14, color: Colors.amber);
      }),
    );
  }
}
