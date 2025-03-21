import 'package:flutter/material.dart';

/// NotificationOverlay is a class to show notification examples as an overlay
/// on top of the current screen.
///
/// When the notification icon is pressed, it displays multiple notification examples.
/// Clicking anywhere on the screen (outside the notifications) dismisses them.
class NotificationOverlay {
  /// Overlay entry to track and remove the overlay when needed
  OverlayEntry? _overlayEntry;

  /// Boolean to track if notifications are currently being shown
  bool _isShowing = false;

  /// Shows notification examples as an overlay on the current screen
  ///
  /// [context] The BuildContext to find the overlay
  /// [alignment] The alignment of the notification panel (defaults to top-right)
  /// [width] The width of each notification card
  /// [notificationData] Optional custom notification data
  void showNotifications(
    BuildContext context, {
    Alignment alignment = Alignment.topRight,
    double width = 300,
    List<NotificationItem>? notificationData,
  }) {
    // If already showing, remove the current overlay first
    if (_isShowing) {
      hideNotifications();
    }

    // Default notification examples if none provided
    final notifications = notificationData ??
        [
          NotificationItem(
            title: "New Message",
            message: "John sent you a message",
            time: "2 min ago",
            icon: Icons.message,
            color: Colors.blue,
          ),
          NotificationItem(
            title: "Payment Successful",
            message: "Your payment of \$25 was successful",
            time: "15 min ago",
            icon: Icons.payment,
            color: Colors.green,
          ),
          NotificationItem(
            title: "Appointment Reminder",
            message: "Your appointment is tomorrow at 10 AM",
            time: "1 hour ago",
            icon: Icons.calendar_today,
            color: Colors.orange,
          ),
          NotificationItem(
            title: "Update Available",
            message: "A new app update is available",
            time: "2 hours ago",
            icon: Icons.system_update,
            color: Colors.purple,
          ),
        ];

    // Create the overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible layer to detect taps outside notification panel
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: hideNotifications,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Notification panel with scrolling
          Positioned(
            top: MediaQuery.of(context).padding.top +
                60, // Position below app bar
            right: 10,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Notifications",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    // Scrollable list of notifications
                    SizedBox(
                      height: 250, // Adjust height as needed
                      child: SingleChildScrollView(
                        child: Column(
                          children: notifications
                              .map((notification) =>
                                  buildNotificationItem(notification))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Add the overlay to the screen
    Overlay.of(context).insert(_overlayEntry!);
    _isShowing = true;
  }

  /// Builds a single notification item widget
  ///
  /// [notification] The notification data to display
  Widget buildNotificationItem(NotificationItem notification) {
    return InkWell(
      onTap: () {
        // Handle notification tap if needed
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: notification.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                notification.icon,
                color: notification.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        notification.time,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hides the notification overlay if it's currently showing
  void hideNotifications() {
    if (_isShowing && _overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isShowing = false;
    }
  }

  /// Checks if notifications are currently being shown
  bool get isShowing => _isShowing;
}

/// Data class to hold information about a single notification
class NotificationItem {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
  });
}
