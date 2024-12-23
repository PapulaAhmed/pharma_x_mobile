import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/chat_viewmodel.dart';

class CustomerChatScreen extends StatefulWidget {
  final String customerId;

  const CustomerChatScreen({Key? key, required this.customerId})
      : super(key: key);

  @override
  _CustomerChatScreenState createState() => _CustomerChatScreenState();
}

class _CustomerChatScreenState extends State<CustomerChatScreen> {
  @override
  void initState() {
    super.initState();
    final chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    chatViewModel.startChat(widget.customerId);
  }

  @override
  Widget build(BuildContext context) {
    final chatViewModel = Provider.of<ChatViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with Pharmacist"),
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              itemCount: chatViewModel.messages.length,
              itemBuilder: (context, index) {
                final message = chatViewModel.messages[index];
                final isMine = message.senderId == widget.customerId;

                return Align(
                  alignment:
                      isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMine ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message.message),
                  ),
                );
              },
            ),
          ),

          // Input Field
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    final chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    final _messageController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: "Type your message",
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              final message = _messageController.text.trim();
              if (message.isNotEmpty) {
                chatViewModel.sendMessage(widget.customerId, message);
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
