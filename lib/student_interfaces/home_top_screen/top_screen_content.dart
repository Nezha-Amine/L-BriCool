import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:lbrikol/student_interfaces/profile_screen.dart';
import 'package:lbrikol/auth/register.dart';

import '../body_items/general_body_home.dart';
import '../body_items/gigs_body_home.dart';
import 'menu_content.dart';
import 'notification_overlay.dart';

class HomeTopScreenContent extends StatefulWidget {
  final Animation<double> fadeAnimation;
  final NotificationOverlay notificationOverlay;

  const HomeTopScreenContent({
    Key? key,
    required this.fadeAnimation,
    required this.notificationOverlay,
  }) : super(key: key);

  @override
  _HomeTopScreenContentState createState() => _HomeTopScreenContentState();
}

class _HomeTopScreenContentState extends State<HomeTopScreenContent> {
  String selectedCategory = "Gigs";

  // Method to handle category change
  void _onCategoryChange(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('images/client_icon.png'),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Hello,\nBahae Assaoui',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      widget.notificationOverlay.showNotifications(context);
                    },
                  ),
                  MenuContent(
                    onSelected: (value) {
                      switch (value) {
                        case 'Profile':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProfileScreen()),
                          );
                          break;
                        case 'Log Out':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterPage()),
                          );
                          break;
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Revenue",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "200 MAD",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                FontAwesomeIcons.sackDollar,
                color: Color(0xFF40189D),
                size: 30,
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildCategoryButton("Gigs"),
              const SizedBox(width: 10),
              _buildCategoryButton("General"),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (selectedCategory == "Gigs")
          GigsSection(fadeAnimation: widget.fadeAnimation),
        if (selectedCategory == "General") GeneralSection(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCategoryButton(String label) {
    bool isSelected = (selectedCategory == label);
    return GestureDetector(
      onTap: () {
        if (selectedCategory != label) {
          _onCategoryChange(label);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF40189D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
