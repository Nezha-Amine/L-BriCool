import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationOverlay {
  OverlayEntry? _overlayEntry;
  bool _isShowing = false;

  void showNotifications(
      BuildContext context, {
        required String currentUserId,
        Alignment alignment = Alignment.topRight,
        double width = 300,
      }) {
    if (_isShowing) {
      hideNotifications();
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: hideNotifications,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
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
                    SizedBox(
                      height: 250,
                      child: StreamBuilder<List<NotificationItem>>(
                        stream: getNotifications(currentUserId),
                        builder: (context, snapshot) {
                          print("dak snapchot data katbda hna:");
                          print(snapshot.data);
                          print("dak snapchot data katssali hna.");
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text("No notifications"));
                          }
                          final notifications = snapshot.data!;
                          return SingleChildScrollView(
                            child: Column(
                              children: notifications
                                  .map((notification) =>
                                  buildNotificationItem(notification))
                                  .toList(),
                            ),
                          );
                        },
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

    Overlay.of(context).insert(_overlayEntry!);
    _isShowing = true;
  }

  void hideNotifications() {
    if (_isShowing && _overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isShowing = false;
    }
  }

  bool get isShowing => _isShowing;

  Stream<List<NotificationItem>> getNotifications(String userId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final Timestamp timestamp = data['time'];
        final DateTime dateTime = timestamp.toDate();
        final String formattedTime =
        DateFormat('hh:mm a').format(dateTime); // e.g., 02:45 PM
        final String formattedDate =
        DateFormat('dd MMM yyyy').format(dateTime); // e.g., 24 Mar 2025

        return NotificationItem(
          title: data['title'] ?? '',
          message: data['message'] ?? '',
          time: formattedTime,
          date: formattedDate,
          icon: Icons.notifications,
          color: Colors.blue,
        );
      }).toList();
    });
  }

  Widget buildNotificationItem(NotificationItem notification) {
    return InkWell(
      onTap: () {
        // Optional: Handle notification tap
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        notification.date,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final String date;
  final IconData icon;
  final Color color;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.date,
    required this.icon,
    required this.color,
  });
}
