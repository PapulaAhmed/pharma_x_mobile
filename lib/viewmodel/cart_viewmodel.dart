import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pharma_x/model/cart_item.dart';
import 'package:pharma_x/model/order_model.dart';

class CartViewModel extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final List<OrderModel> _orders = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, CartItem> get items => {..._items};
  int get itemCount => _items.length;
  double get totalAmount =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  List<OrderModel> get orders => _orders;

  void addItem(String id, String name, double price, int quantity,
      {String? scientificName, String? imageUrl}) {
    if (_items.containsKey(id)) {
      _items.update(
        id,
        (existingItem) => CartItem(
          id: existingItem.id,
          name: existingItem.name,
          scientificName: scientificName ?? existingItem.scientificName,
          imageUrl: imageUrl ?? existingItem.imageUrl,
          price: existingItem.price,
          quantity: existingItem.quantity + quantity,
        ),
      );
    } else {
      _items[id] = CartItem(
        id: id,
        name: name,
        scientificName: scientificName,
        imageUrl: imageUrl,
        price: price,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<void> createOrderFromCart({
    required String address,
    required String paymentMethod,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    if (_items.isEmpty) return;

    // Fetch user data from Firestore
    final userData = await _firestore.collection('users').doc(user.uid).get();
    if (!userData.exists) {
      throw Exception('User profile not found');
    }

    final fullName = '${userData['firstName']} ${userData['lastName']}'.trim();
    final phoneNumber = userData['phoneNumber'] ?? 'No Phone';
    final email = user.email ?? 'No Email';

    try {
      // Create order
      final orderRef = await _firestore.collection('orders').add({
        'userId': user.uid,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'email': email,
        'date': DateTime.now().toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Pending',
        'address': address,
        'paymentMethod': paymentMethod,
        'items': _items.values.map((item) => item.toFirestore()).toList(),
      });

      // Create notification for pharmacists
      await _firestore.collection('notifications').add({
        'title': 'New Order Received',
        'body': 'New order from $fullName',
        'type': 'order',
        'orderId': orderRef.id,
        'targetRole': 'pharmacist',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'data': {
          'orderId': orderRef.id,
          'customerName': fullName,
          'status': 'pending'
        }
      });

      // Clear cart after successful order
      clearCart();
      notifyListeners();
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }
}
