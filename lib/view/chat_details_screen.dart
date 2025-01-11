import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/message_model.dart';
import '../viewmodel/chat_viewmodel.dart';
import '../viewmodel/chat_detail_viewmodel.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String userRole;

  const ChatDetailScreen({
    Key? key,
    required this.chatId,
    required this.userRole,
  }) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late ChatDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    _viewModel = ChatDetailViewModel(
      chatViewModel: chatViewModel,
      chatId: widget.chatId,
      userRole: widget.userRole,
    );
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
          title: const Text("Chat Details"),
        ),
        body: Column(
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<List<Message>>(
      stream: _viewModel.messagesStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _viewModel.updateCachedMessages(snapshot.data!);
        }

        if (_viewModel.cachedMessages.isEmpty) {
          return const Center(child: Text("No messages yet."));
        }

        return Consumer<ChatDetailViewModel>(
          builder: (context, viewModel, _) => ListView.builder(
            itemCount: viewModel.cachedMessages.length,
            itemBuilder: (context, index) {
              final message = viewModel.cachedMessages[index];
              final isMine = viewModel.isMessageMine(message);

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
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Consumer<ChatDetailViewModel>(
      builder: (context, viewModel, _) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: viewModel.messageController,
                decoration: const InputDecoration(
                  hintText: "Type your message",
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
