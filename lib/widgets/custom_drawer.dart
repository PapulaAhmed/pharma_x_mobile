import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharma_x/view/order_screen.dart';
import 'package:provider/provider.dart';
import 'package:pharma_x/viewmodel/auth_viewmodel.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  Future<Map<String, String>> _getUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {'email': 'Guest', 'name': 'Guest User'};

    final email = user.email ?? 'No Email';
    final uid = user.uid;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      final name =
          "${data?['firstName'] ?? 'Guest'} ${data?['lastName'] ?? ''}".trim();
      return {'email': email, 'name': name};
    }

    return {'email': email, 'name': 'Guest User'};
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            return FutureBuilder<Map<String, String>>(
              future: _getUserDetails(),
              builder: (context, snapshot) {
                final userDetails = snapshot.data ??
                    {'email': 'Loading...', 'name': 'Loading...'};

                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                AssetImage('assets/images/11475206.jpg'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userDetails['name']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            userDetails['email']!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.home_outlined),
                      title: const Text('Home'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('My Account'),
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to My Account screen
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.shopping_bag_outlined),
                      title: const Text('Orders'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const OrdersScreen()),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () async {
                        await authViewModel.logOut();
                        Future.microtask(() {
                          Navigator.pushReplacementNamed(context, '/login');
                        });
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
