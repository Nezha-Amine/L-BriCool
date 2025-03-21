import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lbricool/pages/student_interfaces/home_top_screen/revenue_container.dart';

import 'package:lbricool/pages/student_interfaces/profile_screen.dart';
import 'package:lbricool/pages/auth/register.dart';


import '../../../controllers/auth_controller.dart';
import '../../../models/user_model.dart';
import 'menu_content.dart';
import 'notification_overlay.dart';
import 'custom_curved_app_bar.dart';

class HomeTopScreenContent extends StatefulWidget {
  final Animation<double> fadeAnimation;
  final NotificationOverlay notificationOverlay;
  // New parameters for customization
  final String? greeting;
  final String? name;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showRevenueContainer;

  const HomeTopScreenContent({
    Key? key,
    required this.fadeAnimation,
    required this.notificationOverlay,
    this.greeting,
    this.name,
    this.showBackButton = false,
    this.onBackPressed,
    this.showRevenueContainer = false,
  }) : super(key: key);

  @override
  _HomeTopScreenContentState createState() => _HomeTopScreenContentState();
}

class _HomeTopScreenContentState extends State<HomeTopScreenContent> {
  final AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Custom Curved App Bar with notification and menu icons
          ClipPath(
            clipper: CurvedBottomClipper(),
            child: Container(
              color: const Color(0xFF40189D),
              height: 160,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 45),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: FadeTransition(
                  opacity: widget.fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // In _HomeTopScreenContentState class's build method, modify the Row inside the ClipPath:

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Row containing profile image and greeting or back button
                          Expanded(
                            child: Row(
                              children: [
                                // Show back button if specified
                                if (widget.showBackButton)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
                                  )
                                else
                                // Profile image - only show if not using back button
                                  StreamBuilder<UserModel?>(
                                      stream: _authController.getCurrentUserStream(),
                                      builder: (context, snapshot) {
                                        return CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.amber,
                                          backgroundImage: snapshot.hasData &&
                                              snapshot.data?.profilePicture != null
                                              ? NetworkImage(snapshot.data!.profilePicture!)
                                              : const AssetImage(
                                              'assets/images/profile_placeholder.png') as ImageProvider,
                                        );
                                      }),

                                const SizedBox(width: 10),

                                // Greeting and name in column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Greeting text
                                      Text(
                                        widget.greeting ?? "Good Morning",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),

                                      // Only show user name if not using back button, otherwise just show the name prop
                                      widget.showBackButton
                                          ? Text(
                                        widget.name ?? "",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      )
                                          : StreamBuilder<UserModel?>(
                                          stream: _authController.getCurrentUserStream(),
                                          builder: (context, snapshot) {
                                            final displayName = snapshot.hasData &&
                                                snapshot.data?.fullName != null &&
                                                snapshot.data!.fullName.isNotEmpty
                                                ? snapshot.data!.fullName
                                                : widget.name ?? "User";

                                            return Text(
                                              displayName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            );
                                          }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Notification and menu icons - rest of the code stays the same
                          Row(
                            children: [
                              // Notification icon
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                onPressed: () {
                                  widget.notificationOverlay.showNotifications(context);
                                },
                              ),

                              // Menu icon
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
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (widget.showRevenueContainer)
            const RevenueContainer(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}