import 'package:flutter/material.dart';

class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CustomCurvedAppBar extends StatelessWidget {
  final String greeting;
  final String name;
  final Widget notificationIcon;
  final Widget menuIcon;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomCurvedAppBar({
    Key? key,
    required this.greeting,
    required this.name,
    required this.notificationIcon,
    required this.menuIcon,
    this.showBackButton = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180, // Adjust height as needed
      color: const Color(0xFF40189D), // Deep purple color
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button or greeting
              if (showBackButton)
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                )
              else
                Expanded(
                  child: Text(
                    greeting,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

              // Notification and menu icons
              Row(
                children: [
                  notificationIcon,
                  const SizedBox(width: 8),
                  menuIcon,
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}