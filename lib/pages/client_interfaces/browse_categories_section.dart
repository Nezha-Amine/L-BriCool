// browse_categories_section.dart
import 'package:flutter/material.dart';

class CategoryItem {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  CategoryItem({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });
}

class BrowseCategoriesSection extends StatelessWidget {
  const BrowseCategoriesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample category items
    final List<CategoryItem> categories = [
      CategoryItem(
        title: '',
        icon: Icons.psychology,
        backgroundColor: Colors.blue.shade50,
        iconColor: Colors.blue,
        onTap: () {
          // Handle psychology tap
        },
      ),
      CategoryItem(
        title: '',
        icon: Icons.edit,
        backgroundColor: Colors.purple.shade50,
        iconColor: Colors.purple,
        onTap: () {
          // Handle edit tap
        },
      ),
      CategoryItem(
        title: 'general',
        icon: Icons.chat_bubble,
        backgroundColor: Colors.grey.shade200,
        iconColor: Colors.purple.shade700,
        onTap: () {
          // Handle general tap
        },
      ),
      // Add more categories as needed
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Container(
            width: 85,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                // Category icon
                InkWell(
                  onTap: categories[index].onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: categories[index].backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        categories[index].icon,
                        color: categories[index].iconColor,
                        size: 28,
                      ),
                    ),
                  ),
                ),

                // Category title
                if (categories[index].title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      categories[index].title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}