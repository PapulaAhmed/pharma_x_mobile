import 'package:flutter/material.dart';
import 'package:pharma_x/view/chat_details_screen.dart';
import 'package:pharma_x/viewmodel/pharmacist_screen_viewmodel.dart';
import 'package:pharma_x/widgets/custom_appbar.dart';
import 'package:pharma_x/widgets/custom_drawer.dart';
import 'package:provider/provider.dart';

class PharmacistHomeScreen2 extends StatefulWidget {
  const PharmacistHomeScreen2({Key? key}) : super(key: key);

  @override
  _PharmacistHomeScreenState createState() => _PharmacistHomeScreenState();
}

class _PharmacistHomeScreenState extends State<PharmacistHomeScreen2> {
  @override
  void initState() {
    super.initState();

    // Defer data fetching until after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel =
          Provider.of<PharmacistHomeViewModel>(context, listen: false);
      viewModel.fetchRecentChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PharmacistHomeViewModel>(context);

    return Scaffold(
      drawer: CustomDrawer(),
      appBar: CustomAppbar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Recent Conversations",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Recent Chats Section
              Consumer<PharmacistHomeViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoadingChats) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (viewModel.recentChats.isEmpty) {
                    return const Text("No recent conversations.");
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: viewModel.recentChats.length,
                    itemBuilder: (context, index) {
                      final chat = viewModel.recentChats[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child:
                                const Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                              chat.customerId), // Replace with customer name
                          subtitle: Text(chat.lastMessage.isNotEmpty
                              ? chat.lastMessage
                              : "No messages yet."),
                          trailing: Text(
                            chat.lastUpdated.toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                          onTap: () {
                            // Navigate to chat details
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatDetailScreen(
                                  chatId: chat.chatId,
                                  userRole: "pharmacist",
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
