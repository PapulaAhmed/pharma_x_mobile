import 'package:flutter/material.dart';
import 'package:pharma_x/view/pharmacist_chat_screen.dart';
import 'package:pharma_x/view/pharmacist_order_screen.dart';
import 'package:pharma_x/widgets/pharmacist_appbar.dart';
import 'package:pharma_x/widgets/custom_drawer.dart';

class PharmacistHomeScreen extends StatefulWidget {
  const PharmacistHomeScreen({Key? key}) : super(key: key);

  @override
  _PharmacistHomeScreenState createState() => _PharmacistHomeScreenState();
}

class _PharmacistHomeScreenState extends State<PharmacistHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PharmacistOrderScreen(),
    const PharmacistChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PharmacistAppbar(),
      drawer: const CustomDrawer(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
        ],
      ),
    );
  }
}
