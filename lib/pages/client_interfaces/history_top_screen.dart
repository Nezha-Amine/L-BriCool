// history_top_screen.dart
import 'package:flutter/material.dart';
import '../student_interfaces/home_top_screen/custom_curved_app_bar.dart';
import '../student_interfaces/home_top_screen/notification_overlay.dart';

class HistoryTopScreen extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final NotificationOverlay notificationOverlay;

  const HistoryTopScreen({
    Key? key,
    required this.fadeAnimation,
    required this.notificationOverlay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Curved app bar
        ClipPath(
          clipper: CurvedBottomClipper(),
          child: Container(
            color: const Color(0xFF40189D),
            height: 140, // Slightly reduced height since we don't have search bar
            width: double.infinity,
            padding: const EdgeInsets.only(top: 45),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: FadeTransition(
                opacity: fadeAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // History title
                    const Text(
                      'History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Notification icon
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        notificationOverlay.showNotifications(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}