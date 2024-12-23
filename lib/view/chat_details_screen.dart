import 'package:flutter/material.dart';
import 'package:pharma_x/model/message_model.dart';
import 'package:provider/provider.dart';
import '../viewmodel/chat_viewmodel.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;

  const ChatDetailScreen({Key? key, required this.chatId}) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  List<Message> _cachedMessages = []; // Local cache for messages

  @override
  Widget build(BuildContext context) {
    final chatViewModel = Provider.of<ChatViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Details"),
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: chatViewModel.fetchMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // Update local cache with new data
                  _cachedMessages = snapshot.data!;
                }

                // Use cached messages to display messages without interruptions
                if (_cachedMessages.isEmpty) {
                  return const Center(child: Text("No messages yet."));
                }
                return ListView.builder(
                  itemCount: _cachedMessages.length,
                  itemBuilder: (context, index) {
                    final message = _cachedMessages[index];
                    final isMine = message.senderId ==
                        "customerId"; // Adjust logic based on user ID

                    return Align(
                      alignment:
                          isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isMine ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(message.message),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message Input
          _buildMessageInput(context, widget.chatId),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, String chatId) {
    final chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    final messageController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: const InputDecoration(
                hintText: "Type your message",
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              final message = messageController.text.trim();
              if (message.isNotEmpty) {
                chatViewModel.sendMessage(
                  chatId,
                  "customerId", // Replace with the logged-in user's ID
                  "Customer Name", // Replace with the logged-in user's name
                  message,
                );

                // Optimistically add the message to the UI for instant feedback
                setState(() {
                  _cachedMessages.add(
                    Message(
                      messageId: DateTime.now().toIso8601String(),
                      senderId: "customerId",
                      senderName: "Customer Name",
                      message: message,
                      timestamp: DateTime.now(),
                    ),
                  );
                });

                messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
