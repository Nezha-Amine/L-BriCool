import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import '../student_interfaces/bottom_nav_bar.dart';

import '../client_interfaces/client_home_screen.dart';
import '../client_interfaces/client_history_screen.dart';
import 'chat_screen.dart';
class ChatUsersScreen extends StatefulWidget {
  final bool isClient;

  const ChatUsersScreen({super.key, this.isClient = false});

  @override
  State<ChatUsersScreen> createState() => _ChatUsersScreenState();
}

class _ChatUsersScreenState extends State<ChatUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ChatController _chatController = ChatController();
  final AuthController _authController = AuthController();
  String searchQuery = '';
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {

    final List<BottomNavigationBarItem> bottomNavItems = widget.isClient
        ? [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.book), label: 'History'),
      const BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ]
        : [];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const BackButton(color: Colors.deepPurple),
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.deepPurple, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search message..',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_alt_outlined, color: Colors.deepPurple),
                  onPressed: () {}, // Filter functionality
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatController.getRecentChatUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No recent chats',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final filteredUsers = snapshot.data!.where((user) {
                  if (searchQuery.isEmpty) return true;
                  return user['userId']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false;
                }).toList();

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user['userId'])
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                        final userName = userData?['fullName'] ?? 'Unknown User';
                        final profilePicUrl = userData?['profilePicture'];

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: profilePicUrl != null
                                ? NetworkImage(profilePicUrl)
                                : null,
                            child: profilePicUrl == null
                                ? Icon(Icons.person, color: Colors.grey[600])
                                : null,
                          ),
                          title: Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            user['lastMessage'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatTimestamp(user['timestamp']),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  currentUser: _authController.getCurrentUserId()!,
                                  recipientUser: user['userId'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.isClient
          ? CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        items: bottomNavItems,
        onItemTapped: _handleClientNavigation,
      )
          : null,
    );
  }

  void _handleClientNavigation(int index) {
    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ClientHomeScreen()),
        );
        break;
      case 1: // History
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ClientHistoryScreen()),
        );
        break;
      case 2: // Chat (current screen)
        break;
      case 3: // Profile
      // Uncomment when you have a client profile screen
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (_) => const ClientProfileScreen()),
      // );
        break;
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final dateTime = timestamp.toDate();
    final now = DateTime.now();

    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      // If it's today, return time
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // Otherwise, return date
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}