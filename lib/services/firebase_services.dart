import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pharma_x/model/message_model.dart';

class FirebaseService {
  final _firestore = FirebaseFirestore.instance;

  // Create a new chat
  Future<String> createChat(String customerId) async {
    try {
      final docRef = await _firestore.collection('chats').add({
        'customerId': customerId,
        'pharmacistId': null,
        'status': 'unassigned',
      });
      print("Chat successfully created with ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      print("Error creating chat: $e");
      throw e; // Propagate the error for debugging
    }
  }

  // Add a message to an existing chat
  Future<void> sendMessage(String chatId, Message message) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());
  }

  // Get messages for a chat
  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList());
  }
}
