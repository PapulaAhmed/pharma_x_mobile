import 'package:flutter/material.dart';
import 'package:pharma_x/view/chat_details_screen.dart';
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
    // Fetch chats initially
    final chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    chatViewModel.fetchChats(widget.customerId);
  }

  void _refreshChats() {
    final chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    chatViewModel.fetchChats(widget.customerId);
  }

  @override
  Widget build(BuildContext context) {
    final chatViewModel = Provider.of<ChatViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
      ),
      body: Column(
        children: [
          // List of existing chats
          Expanded(
            child: Consumer<ChatViewModel>(
              builder: (context, chatViewModel, child) {
                if (chatViewModel.chats.isEmpty) {
                  return const Center(
                      child: Text("No chats yet. Start a new conversation!"));
                }
                return ListView.builder(
                  itemCount: chatViewModel.chats.length,
                  itemBuilder: (context, index) {
                    final chat = chatViewModel.chats[index];
                    return ListTile(
                      title: Text(chat.chatId), // Display Chat ID as the title
                      subtitle: Text(chat.lastMessage.isNotEmpty
                          ? chat.lastMessage
                          : "No messages yet."), // Display last message
                      onTap: () {
                        // Navigate to the chat screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatDetailScreen(chatId: chat.chatId),
                          ),
                        ).then((_) {
                          // Refresh chats when returning from ChatDetailScreen
                          _refreshChats();
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Start New Conversation Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                final chatViewModel =
                    Provider.of<ChatViewModel>(context, listen: false);
                await chatViewModel.startNewChat(
                    widget.customerId, "Customer Name");
                _refreshChats(); // Refresh chat list
              },
              icon: const Icon(Icons.add),
              label: const Text("Start New Conversation"),
            ),
          ),
        ],
      ),
    );
  }
}
