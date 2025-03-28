import 'package:flutter/material.dart';
import 'package:lbricool/pages/client_interfaces/search_bar.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../auth/login.dart';
import '../student_interfaces/home_top_screen/custom_curved_app_bar.dart';
import '../student_interfaces/home_top_screen/menu_content.dart';
import '../student_interfaces/home_top_screen/notification_overlay.dart';
import '../student_interfaces/profile_screen.dart';

class HomeTopScreenContent extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final NotificationOverlay notificationOverlay;
  final String greeting;
  final String name;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showSearchBar;
  final Function(String)? onSearch;

  const HomeTopScreenContent({
    Key? key,
    required this.fadeAnimation,
    required this.notificationOverlay,
    required this.greeting,
    required this.name,
    this.showBackButton = false,
    this.onBackPressed,
    this.showSearchBar = true,
    this.onSearch,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final AuthController _authController = AuthController();

    return Stack(
      children: [
        ClipPath(
          clipper: CurvedBottomClipper(),
          child: Container(
            color: const Color(0xFF40189D),
            height: 160,
            // Fixed height to prevent overflow
            width: double.infinity,
            padding: const EdgeInsets.only(top: 45),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: FadeTransition(
                opacity: fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Row containing profile image and greeting
                        Expanded(
                          child: Row(
                            children: [
                              // Profile image
                              StreamBuilder<UserModel?>(
                                  stream: AuthController()
                                      .getCurrentUserStream(),
                                  builder: (context, snapshot) {
                                    return CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.amber,
                                      backgroundImage: snapshot.hasData &&
                                          snapshot.data?.profilePicture != null
                                          ? NetworkImage(
                                          snapshot.data!.profilePicture!)
                                          : const AssetImage(
                                          'assets/images/profile_placeholder.png') as ImageProvider,
                                    );
                                  }
                              ),

                              const SizedBox(width: 10),

                              // Greeting and name in column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Greeting text
                                    Text(
                                      greeting,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),

                                    // User name
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20, // Slightly smaller to fit
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

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
                                notificationOverlay.showNotifications(context, currentUserId: '');
                              },
                            ),

                            // Menu icon
                            MenuContent(
                              onSelected: (value) async {
                                switch (value) {
                                  case 'Profile':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const ProfileScreen()),
                                    );
                                    break;
                                  case 'Log Out':
                                    await _authController.logout(); // Call the logout function
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) =>  LogInPage()), // Navigate to register screen
                                          (route) => false, // Remove all previous routes
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

        if (showSearchBar)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Transform.translate(
                offset: const Offset(0, 25),
                // Move down to overlay the curved edge
                child: SearchBarW(
                  hintText: 'Search your need...',
                  onSearch: onSearch,
                ),
              ),
            ),
          ),
      ],
    );
  }

}