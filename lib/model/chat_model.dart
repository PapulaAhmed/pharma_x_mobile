class Chat {
  final String chatId;
  final String customerId;
  final String? pharmacistId; // Null if unassigned
  final String status; // 'unassigned' or 'assigned'

  Chat({
    required this.chatId,
    required this.customerId,
    this.pharmacistId,
    required this.status,
  });

  factory Chat.fromMap(String id, Map<String, dynamic> data) {
    return Chat(
      chatId: id,
      customerId: data['customerId'],
      pharmacistId: data['pharmacistId'],
      status: data['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'pharmacistId': pharmacistId,
      'status': status,
    };
  }
}
