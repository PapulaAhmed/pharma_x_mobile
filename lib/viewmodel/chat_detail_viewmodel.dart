import 'package:flutter/material.dart';
import '../model/message_model.dart';
import '../viewmodel/chat_viewmodel.dart';

class ChatDetailViewModel extends ChangeNotifier {
  final ChatViewModel _chatViewModel;
  final String chatId;
  final String userRole;
  final TextEditingController messageController = TextEditingController();
  List<Message> cachedMessages = [];

  ChatDetailViewModel({
    required ChatViewModel chatViewModel,
    required this.chatId,
    required this.userRole,
  }) : _chatViewModel = chatViewModel;

  Stream<List<Message>> get messagesStream =>
      _chatViewModel.fetchMessages(chatId);

  bool get isCustomer => userRole == "customer";

  String get senderId => isCustomer ? "customerId" : "pharmacistId";
  String get senderName => isCustomer ? "Customer Name" : "Pharmacist Name";

  bool isMessageMine(Message message) {
    return (isCustomer && message.senderId == "customerId") ||
        (!isCustomer && message.senderId == "pharmacistId");
  }

  Future<void> sendMessage() async {
    final message = messageController.text.trim();
    if (message.isEmpty) return;

    // Send message through ChatViewModel
    await _chatViewModel.sendMessage(
      chatId,
      senderId,
      senderName,
      message,
    );

    // Add message to local cache
    cachedMessages.add(
      Message(
        messageId: DateTime.now().toIso8601String(),
        senderId: senderId,
        senderName: senderName,
        message: message,
        timestamp: DateTime.now(),
      ),
    );

    messageController.clear();
    notifyListeners();
  }

  void updateCachedMessages(List<Message> messages) {
    cachedMessages = messages;
    notifyListeners();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}
