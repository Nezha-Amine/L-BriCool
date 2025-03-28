import 'package:flutter/material.dart';
import '../student_interfaces/home_top_screen/notification_overlay.dart';
import '../student_interfaces/home_top_screen/top_screen_content.dart';

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
    return HomeTopScreenContent(
      fadeAnimation: fadeAnimation,
      notificationOverlay: notificationOverlay,
      greeting: "",
      name: "History",
      showBackButton: true,
      onBackPressed: () => Navigator.of(context).pop(),
    );
  }
}