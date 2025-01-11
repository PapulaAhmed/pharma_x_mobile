import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pharma_x/viewmodel/notification_viewmodel.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationViewModel>(context, listen: false)
          .refreshNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<NotificationViewModel>(context, listen: false)
                  .markAllAsRead();
            },
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, notificationVM, child) {
          if (notificationVM.notifications.isEmpty) {
            return const Center(
              child: Text('No notifications'),
            );
          }

          return ListView.builder(
            itemCount: notificationVM.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationVM.notifications[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.notifications_outlined),
                ),
                title: Text(notification['title'] ?? ''),
                subtitle: Text(notification['body'] ?? ''),
                trailing: Text(
                  DateFormat('MMM d, h:mm a').format(
                    (notification['timestamp'] as Timestamp).toDate(),
                  ),
                ),
                tileColor: !notification['read'] ? Colors.grey[100] : null,
                onTap: () {
                  notificationVM.markAsRead(notification['id']);
                  // Handle navigation based on notification type
                  if (notification['type'] == 'order') {
                    Navigator.pushNamed(
                      context,
                      '/order-details',
                      arguments: notification['orderId'],
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
