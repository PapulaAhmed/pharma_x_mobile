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

  void addItem(String id, String name, double price, int quantity) {
    if (_items.containsKey(id)) {
      _items.update(
        id,
        (existingItem) => CartItem(
          id: existingItem.id,
          name: existingItem.name,
          price: existingItem.price,
          quantity: existingItem.quantity + quantity,
        ),
      );
    } else {
      _items[id] = CartItem(
        id: id,
        name: name,
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
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      throw Exception('User not logged in'); // Handle null user case
    }

    if (_items.isEmpty) return;

    final newOrder = OrderModel(
      id: DateTime.now().toIso8601String(),
      userId: userId, // Assign the order to the logged-in user
      date: DateTime.now(),
      status: 'Pending',
      address: address,
      paymentMethod: paymentMethod,
      items: _items.values.toList(),
    );

    try {
      await _firestore.collection('orders').add(newOrder.toFirestore());
      _orders.add(newOrder);
      clearCart();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }
}
