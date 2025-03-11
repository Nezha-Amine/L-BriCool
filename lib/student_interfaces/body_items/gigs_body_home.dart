import 'package:flutter/material.dart';
import 'recommended_gigs_list.dart';
import 'recent_gigs_list.dart';

class GigsSection extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const GigsSection({super.key, required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recommended Gigs header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            "Recommended Gigs",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Recommended Gigs horizontal list
        RecommendedGigsList(fadeAnimation: fadeAnimation),
        // Recent Gigs header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Gigs",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Add 'view more' button logic
                },
                child: const Text(
                  "View More",
                  style: TextStyle(
                    color: Color(0xFF40189D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ],
          ),
        ),
        RecentGigsList(),
      ],
    );
  }
}
