import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;

  Message({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
  });

  factory Message.fromFirestore(Map<String, dynamic> data, String id) {
    return Message(
      messageId: id,
      senderId: data['senderId'] as String,
      senderName: data['senderName'] as String,
      message: data['message'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
