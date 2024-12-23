import 'package:flutter/material.dart';

class PharmacistHomeScreen extends StatelessWidget {
  const PharmacistHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pharmacist Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Add logout functionality
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome, Pharmacist!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "What would you like to do today?",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  // Manage Chats
                  _HomeOption(
                    title: "Manage Chats",
                    icon: Icons.chat,
                    onTap: () {
                      Navigator.pushNamed(context, '/manage-chats');
                    },
                  ),

                  // View Orders
                  _HomeOption(
                    title: "View Orders",
                    icon: Icons.assignment,
                    onTap: () {
                      Navigator.pushNamed(context, '/view-orders');
                    },
                  ),

                  // Inventory Management
                  _HomeOption(
                    title: "Manage Inventory",
                    icon: Icons.inventory,
                    onTap: () {
                      Navigator.pushNamed(context, '/inventory');
                    },
                  ),

                  // Profile Settings
                  _HomeOption(
                    title: "Profile Settings",
                    icon: Icons.settings,
                    onTap: () {
                      Navigator.pushNamed(context, '/profile-settings');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeOption({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.blue),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
