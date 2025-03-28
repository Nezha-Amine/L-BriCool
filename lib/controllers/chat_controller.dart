import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../pages/chat/chat_screen.dart';
import 'auth_controller.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = AuthController();

  // Send a message
  Future<bool> sendMessage({
    required String receiverId,
    required String content,
    String? gigId,
  }) async {
    try {
      final senderId = _authController.getCurrentUserId();
      if (senderId == null) return false;

      final message = ChatMessageModel(
        id: '',
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        timestamp: Timestamp.now(),
        gigId: gigId,
      );

      await _firestore.collection('chat_messages').add(message.toMap());
      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  Stream<List<ChatMessageModel>> getChatMessages({
    required String otherUserId,
    String? gigId,
  }) {
    try {
      final currentUserId = _authController.getCurrentUserId();
      if (currentUserId == null) {
        return Stream.value([]);
      }

      return _firestore
          .collection('chat_messages')
          .where('senderId', whereIn: [currentUserId, otherUserId])
          .where('receiverId', whereIn: [currentUserId, otherUserId])
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => ChatMessageModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ))
          .toList());
    } catch (e) {
      print('Error getting chat messages: $e');
      return Stream.value([]);
    }
  }

  // Check if chat is allowed between two users (based on a completed gig)
  Future<bool> canInitiateChat(String studentId, String clientId, String gigId) async {
    try {
      print('Checking chat permission for:');
      print('Student ID: $studentId');
      print('Client ID: $clientId');
      print('Gig ID: $gigId');

      QuerySnapshot applicationQuery = await _firestore
          .collection('applications')
          .where('gigId', isEqualTo: gigId)
          .where('studentId', isEqualTo: studentId)
          .where('status', isEqualTo: 'accepted')
          .limit(1)
          .get();

      print('Applications found: ${applicationQuery.docs.length}');
      return applicationQuery.docs.isNotEmpty;
    } catch (e) {
      print('Error checking chat permissions: $e');
      return false;
    }
  }

  Stream<List<Map<String, dynamic>>> getRecentChatUsers() {
    try {
      final currentUserId = _authController.getCurrentUserId();
      if (currentUserId == null) {
        return Stream.value([]);
      }

      return _firestore
          .collection('chat_messages')
          .where('senderId', isEqualTo: currentUserId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .asyncMap((sendSnapshot) async {
        Map<String, Map<String, dynamic>> uniqueUsers = {};

        for (var doc in sendSnapshot.docs) {
          final data = doc.data();
          final receiverId = data['receiverId'];

          if (!uniqueUsers.containsKey(receiverId)) {
            uniqueUsers[receiverId] = {
              'userId': receiverId,
              'lastMessage': data['content'],
              'timestamp': data['timestamp'],
            };
          }
        }

        final receiveSnapshot = await _firestore
            .collection('chat_messages')
            .where('receiverId', isEqualTo: currentUserId)
            .orderBy('timestamp', descending: true)
            .get();

        for (var doc in receiveSnapshot.docs) {
          final data = doc.data();
          final senderId = data['senderId'];

          if (!uniqueUsers.containsKey(senderId)) {
            uniqueUsers[senderId] = {
              'userId': senderId,
              'lastMessage': data['content'],
              'timestamp': data['timestamp'],
            };
          }
        }

        return uniqueUsers.values.toList();
      });
    } catch (e) {
      print('Error getting recent chat users: $e');
      return Stream.value([]);
    }
  }
  Future<void> navigateToChat({
    required BuildContext context,
    required String recipientId,
    String? gigId,
  }) async {
    try {
      bool canChat = await canInitiateChat(
          _authController.getCurrentUserId()!,
          recipientId,
          gigId!
      );

      if (canChat) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              currentUser: _authController.getCurrentUserId()!,
              recipientUser: recipientId,
              gigId: gigId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can only chat after your application is accepted.'),
          ),
        );
      }
    } catch (e) {
      print('Navigation to chat error: $e');
    }
  }


}