import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharma_x/view/cart_screen.dart';
import 'package:pharma_x/view/notification_screen.dart';
import 'package:pharma_x/viewmodel/cart_viewmodel.dart';
import 'package:pharma_x/viewmodel/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:pharma_x/viewmodel/notification_viewmodel.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({super.key});

  Future<String> getUserFirstName() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return 'Guest';

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        return doc.data()?['firstName'] ?? 'Guest';
      }
    } catch (e) {
      debugPrint('Error fetching user name: $e');
    }
    return 'Guest';
  }

  Widget _buildNotificationIcon(BuildContext context, int notificationCount) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
        ),
        if (notificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                notificationCount > 99 ? '99+' : notificationCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: Builder(
        builder: (context) {
          return Consumer<UserViewModel>(
            builder: (context, userViewModel, _) {
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: snapshot.hasData &&
                                snapshot.data!.exists &&
                                snapshot.data!.get('profilePicture') != null
                            ? NetworkImage(snapshot.data!.get('profilePicture'))
                            : null,
                        child: (!snapshot.hasData ||
                                !snapshot.data!.exists ||
                                snapshot.data!.get('profilePicture') == null)
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      title: FutureBuilder<String>(
        future: getUserFirstName(),
        builder: (context, snapshot) {
          final firstName = snapshot.data ?? 'Guest';
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $firstName',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'What are you looking for?',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            children: [
              // Notification Icon
              Consumer<NotificationViewModel>(
                builder: (context, notificationVM, child) {
                  return _buildNotificationIcon(
                      context, notificationVM.unreadCount);
                },
              ),
              const SizedBox(width: 10),
              // Cart Icon
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CartScreen()),
                          );
                        },
                        child: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Consumer<CartViewModel>(
                      builder: (context, cart, child) {
                        return cart.itemCount > 0
                            ? CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.red,
                                child: Text(
                                  '${cart.itemCount}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
