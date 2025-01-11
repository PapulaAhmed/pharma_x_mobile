import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomerConversationViewModel extends ChangeNotifier {
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  Stream<QuerySnapshot>? _conversationsStream;

  CustomerConversationViewModel() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        updateCurrentUser(user.uid);
      } else {
        updateCurrentUser(null);
      }
    });
  }

  // Get Conversations Stream
  Stream<QuerySnapshot>? getConversationsStream() {
    if (currentUserId == null) {
      return null; // Return null or an empty stream if no user is logged in
    }
    _conversationsStream = FirebaseFirestore.instance
        .collection('chats')
        .where('customerId', isEqualTo: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
    return _conversationsStream;
  }

  // Delete Conversation
  Future<void> deleteConversation(String chatId) async {
    await FirebaseFirestore.instance.collection('chats').doc(chatId).delete();
  }

  // Start a New Chat
  Future<String> startNewChat(BuildContext context) async {
    try {
      if (currentUserId == null) {
        throw Exception('No user is logged in.');
      }
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>;

      final chatRef = await FirebaseFirestore.instance.collection('chats').add({
        'customerId': currentUserId,
        'customerName': '${userData['firstName']} ${userData['lastName']}',
        'pharmacistId': null,
        'lastMessage': 'New conversation',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'customerUnreadCount': 0,
        'pharmacistUnreadCount': 1,
      });

      return chatRef.id;
    } catch (e) {
      throw Exception('Error creating chat: $e');
    }
  }

  // Format Time for Display
  String formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Clear Conversations and Reset State
  void clearConversations() {
    currentUserId = null;
    _conversationsStream = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Update Current User ID (e.g., when switching accounts)
  void updateCurrentUser(String? userId) {
    currentUserId = userId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
