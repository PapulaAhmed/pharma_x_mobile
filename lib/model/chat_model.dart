import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String chatId;
  final String customerId;
  final String? pharmacistId; // Can be null
  final String status; // Default to 'unassigned'
  final String lastMessage;
  final DateTime lastUpdated;

  Chat({
    required this.chatId,
    required this.customerId,
    this.pharmacistId,
    required this.status,
    required this.lastMessage,
    required this.lastUpdated,
  });

  factory Chat.fromFirestore(Map<String, dynamic> data, String id) {
    return Chat(
      chatId: id,
      customerId: data['customerId'] ?? 'Unknown', // Default value if null
      pharmacistId: data['pharmacistId'], // Can remain null
      status: data['status'] ?? 'unassigned', // Default to 'unassigned'
      lastMessage: data['lastMessage'] ?? '', // Default to empty string
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ??
          DateTime.now(), // Default to current time
    );
  }
}
