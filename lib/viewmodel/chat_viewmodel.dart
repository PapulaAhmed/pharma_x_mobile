import 'package:flutter/material.dart';
import 'package:pharma_x/model/message_model.dart';
import 'package:pharma_x/services/firebase_services.dart';

class ChatViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  String? _chatId;
  List<Message> _messages = [];

  List<Message> get messages => _messages;

  Future<void> startChat(String customerId) async {
    try {
      if (_chatId == null) {
        _chatId = await _firebaseService.createChat(customerId);
        print("Chat started with ID: $_chatId");
        listenToMessages();
      }
    } catch (e) {
      print("Error starting chat: $e");
    }
  }

  void listenToMessages() {
    if (_chatId != null) {
      _firebaseService.getMessages(_chatId!).listen((messages) {
        _messages = messages;
        notifyListeners();
      });
    }
  }

  Future<void> sendMessage(String customerId, String message) async {
    if (_chatId != null) {
      try {
        final newMessage = Message(
          senderId: customerId,
          message: message,
          timestamp: DateTime.now(),
        );
        await _firebaseService.sendMessage(_chatId!, newMessage);
        print("Message sent: $message");
      } catch (e) {
        print("Error sending message: $e");
      }
    } else {
      print("Chat ID is null, cannot send message.");
    }
  }
}
