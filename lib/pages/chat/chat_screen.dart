import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/chat_message_model.dart';
import '../../controllers/chat_controller.dart';

class ChatScreen extends StatefulWidget {
  final String currentUser;
  final String recipientUser;
  final String? gigId;

  const ChatScreen({
    super.key,
    required this.currentUser,
    required this.recipientUser,
    this.gigId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatController _chatController = ChatController();
  final ScrollController _scrollController = ScrollController();
  String _recipientName = '';
  String? _recipientProfilePic;

  @override
  void initState() {
    super.initState();
    _fetchRecipientInfo();
  }

  void _fetchRecipientInfo() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.recipientUser)
        .get();

    if (userDoc.exists) {
      setState(() {
        _recipientName = userDoc.data()?['fullName'] ?? 'User';
        _recipientProfilePic = userDoc.data()?['profilePicture'];
      });
    }
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    await _chatController.sendMessage(
      receiverId: widget.recipientUser,
      content: message,
      gigId: widget.gigId,
    );

    _messageController.clear();

    // Scroll to bottom after sending
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const BackButton(color: Colors.deepPurple),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: _recipientProfilePic != null
                  ? NetworkImage(_recipientProfilePic!)
                  : null,
              child: _recipientProfilePic == null
                  ? Icon(Icons.person, color: Colors.grey[600])
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              _recipientName,
              style: const TextStyle(
                color: Colors.deepPurple,
                fontSize: 18,
              ),
            ),
          ],
        ),

      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessageModel>>(
              stream: _chatController.getChatMessages(
                otherUserId: widget.recipientUser,
                gigId: widget.gigId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == widget.currentUser;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.deepPurple : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          message.content,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Message input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
              color: Colors.white,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.deepPurple),
                  onPressed: () {
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.grey[200],
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}