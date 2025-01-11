import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pharma_x/view/customer_chat_details_screen.dart';
import 'package:provider/provider.dart';
import '../viewmodel/customer_conversation_viewmodel.dart';
import '../viewmodel/customer_chat_detail_viewmodel.dart';

class CustomerConversationScreen extends StatelessWidget {
  final _viewModel = CustomerConversationViewModel();

  CustomerConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _viewModel.getConversationsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildConversationsList(context, snapshot.data!.docs);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startNewChat(context, _viewModel.currentUserId!),
        child: const Icon(Icons.chat),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No conversations yet'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _startNewChat(context, _viewModel.currentUserId!),
            child: const Text('Start New Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(
      BuildContext context, List<QueryDocumentSnapshot> chats) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        final data = chat.data() as Map<String, dynamic>;

        return Dismissible(
          key: Key(chat.id),
          direction: DismissDirection.endToStart,
          background: _buildDismissibleBackground(),
          confirmDismiss: (direction) => _confirmDismiss(context),
          onDismissed: (direction) => _viewModel.deleteConversation(chat.id),
          child: _buildChatCard(context, chat.id, data),
        );
      },
    );
  }

  Widget _buildDismissibleBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 16),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Future<bool?> _confirmDismiss(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content:
            const Text('Are you sure you want to delete this conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard(
      BuildContext context, String chatId, Map<String, dynamic> data) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.medical_services, color: Colors.white),
        ),
        title: const Text('Pharmacy Support'),
        subtitle: Text(
          data['lastMessage'] ?? 'No messages yet',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: _buildChatMetadata(context, data),
        onTap: () => _navigateToChatDetail(context, chatId),
      ),
    );
  }

  Widget _buildChatMetadata(BuildContext context, Map<String, dynamic> data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _viewModel
              .formatTime(data['lastMessageTime']?.toDate() ?? DateTime.now()),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        if ((data['customerUnreadCount'] ?? 0) > 0)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${data['customerUnreadCount']}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
      ],
    );
  }

  void _navigateToChatDetail(BuildContext context, String chatId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerChatDetailScreen(
          chatId: chatId,
          customerId: _viewModel.currentUserId!,
        ),
      ),
    );
  }

  Future<void> _startNewChat(BuildContext context, String customerId) async {
    try {
      final chatId = await _viewModel.startNewChat(context);
      if (context.mounted) {
        _navigateToChatDetail(context, chatId);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating chat: $e')),
        );
      }
    }
  }
}
