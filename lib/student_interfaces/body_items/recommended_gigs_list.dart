import 'package:flutter/material.dart';

// This is the class of Recommended Gigs
class RecommendedGigsList extends StatelessWidget {
  // Example data for recommended and recent gigs (used in the Home screen)
  // This List (recommendedGigs) will be filled with data from Database
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
  final Animation<double> fadeAnimation;

  RecommendedGigsList({
    super.key,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }
}
