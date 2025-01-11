import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pharma_x/model/message_model.dart';
import '../model/chat_model.dart';
import 'package:flutter/material.dart';

class ChatViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Chat> _chats = [];
  List<Chat> get chats => _chats;

  // Fetch all chats for a specific customer
  Future<void> fetchChats(String customerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('chats')
          .where('customerId', isEqualTo: customerId)
          .orderBy('lastUpdated', descending: true)
          .get();

      _chats = querySnapshot.docs.map((doc) {
        return Chat.fromFirestore(doc.data(), doc.id);
      }).toList();

      notifyListeners();
    } catch (e) {
      print("Error fetching chats: $e");
    }
  }

  Stream<List<Message>> fetchMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Message.fromFirestore(doc.data(), doc.id);
            }).toList());
  }

  // Start a new chat
  Future<void> startNewChat(String customerId, String customerName) async {
    final chatRef = _firestore.collection('chats').doc();
    await chatRef.set({
      'customerId': customerId,
      'customerName': customerName,
      'lastMessage': '',
      'lastUpdated': FieldValue.serverTimestamp(),
    });
    notifyListeners();
  }

  Future<void> sendMessage(
      String chatId, String senderId, String senderName, String message) async {
    final messageRef =
        _firestore.collection('chats').doc(chatId).collection('messages').doc();

    // Add the message to the messages subcollection
    await messageRef.set({
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update the lastMessage and lastUpdated fields in the chat document
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message,
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    notifyListeners();
  }

  void clearState() {
    // Clear any cached messages, conversations, or streams
    // Cancel any active listeners
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
