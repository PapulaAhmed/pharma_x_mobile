import 'package:flutter/material.dart';
import 'package:pharma_x/view/login_screen.dart';
import 'package:pharma_x/view/profile_screen.dart';
import 'package:provider/provider.dart';
import '../viewmodel/user_viewmodel.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Consumer2<UserViewModel, AuthViewModel>(
          builder: (context, userViewModel, authViewModel, _) {
            return StreamBuilder<UserModel>(
              stream: userViewModel.userStream(),
              builder: (context, snapshot) {
                final user = snapshot.data ?? UserModel.guest();

                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerHeader(user),
                    _buildDrawerItems(context, authViewModel),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(UserModel user) {
    return DrawerHeader(
      decoration: const BoxDecoration(color: Colors.blue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfilePicture(user.profilePicture),
          const SizedBox(height: 8),
          Text(
            user.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          Text(
            user.email,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(String? profilePicture) {
    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.grey[200],
      child: profilePicture != null
          ? ClipOval(
              child: Image.network(
                profilePicture,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            )
          : const Icon(
              Icons.person,
              size: 40,
              color: Colors.grey,
            ),
    );
  }

  Widget _buildDrawerItems(BuildContext context, AuthViewModel authViewModel) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.home_outlined),
          title: const Text('Home'),
          onTap: () => Navigator.pop(context),
        ),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('My Account'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.shopping_bag_outlined),
          title: const Text('Orders'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/orders');
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () async {
            // Close drawer first
            Navigator.pop(context);

            final authViewModel =
                Provider.of<AuthViewModel>(context, listen: false);
            await authViewModel.logOut();
          },
        ),
      ],
    );
  }
}
