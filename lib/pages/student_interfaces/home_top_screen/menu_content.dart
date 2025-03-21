import 'package:flutter/material.dart';

/// MenuContent is a widget that displays a popup menu with several menu items.
/// It is designed to be used in an app bar or any part of the UI where a menu is needed.
///
/// The menu includes the following options:
/// - Profile
/// - My Gigs
/// - Add a Gig
/// - Log Out
///
/// The [onSelected] callback is triggered when a menu item is selected.
class MenuContent extends StatelessWidget {
  /// Callback when a menu item is selected.
  /// The selected item's value is passed to this callback.
  final void Function(String) onSelected;

  const MenuContent({Key? key, required this.onSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert,
        color: Colors.white,
        size: 28,
      ),
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem<String>(
            value: 'Profile',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person,
                  size: 24,
                  color: Colors.black,
                ),
                SizedBox(width: 8),
                Text('Profile'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'My Gigs',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.work,
                  size: 24,
                  color: Colors.black,
                ),
                SizedBox(width: 8),
                Text('My Gigs'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'Add a Gig',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_box,
                  size: 24,
                  color: Colors.black,
                ),
                SizedBox(width: 8),
                Text('Add a Gig'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'Log Out',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.logout,
                  size: 24,
                  color: Colors.black,
                ),
                SizedBox(width: 8),
                Text('Log Out'),
              ],
            ),
          ),
        ];
      },
    );
  }
}
