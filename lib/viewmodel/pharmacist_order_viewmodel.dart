import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/order_model.dart';

class PharmacistOrderViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PharmacistOrderViewModel() {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('orders')
          .orderBy('timestamp', descending: true)
          .get();

      _orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _error = 'Failed to fetch orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
      });

      // Update local state
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        final updatedOrder = OrderModel.fromFirestore(
          {..._orders[orderIndex].toFirestore(), 'status': newStatus},
          orderId,
        );
        _orders[orderIndex] = updatedOrder;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update order status: $e';
      notifyListeners();
    }
  }

  Stream<QuerySnapshot> getOrdersStream() {
    return FirebaseFirestore.instance
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .orderBy('date', descending: true)
        .snapshots();
  }
}
