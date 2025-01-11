import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerChatDetailViewModel extends ChangeNotifier {
  final String chatId;
  final TextEditingController messageController = TextEditingController();

  CustomerChatDetailViewModel({required this.chatId});

  Stream<QuerySnapshot> getMessagesStream() {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot> getUserData(String customerId) {
    return FirebaseFirestore.instance.collection('users').doc(customerId).get();
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    // Add the message
    batch.set(chatRef.collection('messages').doc(), {
      'text': text,
      'senderId': FirebaseAuth.instance.currentUser?.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update the chat document
    batch.update(chatRef, {
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'pharmacistUnreadCount': FieldValue.increment(1),
    });

    await batch.commit();
    messageController.clear();
    notifyListeners();
  }

  bool isCustomerMessage(String senderId) {
    return senderId == FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> resetUnreadCount() async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .update({'customerUnreadCount': 0});
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}
