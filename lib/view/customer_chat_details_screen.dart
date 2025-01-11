import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pharma_x/viewmodel/customer_chat_detail_viewmodel.dart';
import 'package:provider/provider.dart';

class CustomerChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String customerId;

  const CustomerChatDetailScreen({
    Key? key,
    required this.chatId,
    required this.customerId,
  }) : super(key: key);

  @override
  State<CustomerChatDetailScreen> createState() =>
      _CustomerChatDetailScreenState();
}

class _CustomerChatDetailScreenState extends State<CustomerChatDetailScreen> {
  late final CustomerChatDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CustomerChatDetailViewModel(chatId: widget.chatId);
    _viewModel.resetUnreadCount();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pharmacist'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _viewModel.getMessagesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages yet'));
        }

        return ListView.builder(
          reverse: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final message = snapshot.data!.docs[index];
            final messageData = message.data() as Map<String, dynamic>;
            final isCustomerMessage =
                _viewModel.isCustomerMessage(messageData['senderId']);

            return _buildMessageBubble(context, messageData, isCustomerMessage);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context,
      Map<String, dynamic> messageData, bool isCustomerMessage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Align(
        alignment:
            isCustomerMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isCustomerMessage
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            messageData['text'] ?? '',
            style: TextStyle(
              color: isCustomerMessage ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Consumer<CustomerChatDetailViewModel>(
      builder: (context, viewModel, _) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: viewModel.messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: viewModel.sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
