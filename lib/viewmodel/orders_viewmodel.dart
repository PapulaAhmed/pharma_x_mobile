import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharma_x/model/order_model.dart';

class OrdersViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  OrdersViewModel() {
    fetchOrders();
  }

  void fetchOrders() {
    _isLoading = true;

    try {
      final userId = _auth.currentUser?.uid;

      if (userId == null) {
        _errorMessage = 'User not logged in';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .listen(
        (snapshot) {
          _orders = snapshot.docs.map((doc) {
            return OrderModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (error) {
          _isLoading = false;
          _errorMessage = 'Failed to fetch orders: $error';
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred: $e';
      notifyListeners();
    }
  }

  Future<void> createOrder(OrderModel order) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('Creating order...'); // Debug log

      // Create the order
      final orderRef =
          await _firestore.collection('orders').add(order.toFirestore());

      print('Order created with ID: ${orderRef.id}'); // Debug log

      // Send notification to pharmacists
      await _sendNotificationToPharmacists(
        orderId: orderRef.id,
        customerName: order.fullName,
      ).catchError((error) {
        print('Error in _sendNotificationToPharmacists: $error'); // Debug log
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error in createOrder: $e'); // Debug log
      _isLoading = false;
      _errorMessage = 'Failed to create order: $e';
      notifyListeners();
    }
  }

  Future<void> _sendNotificationToPharmacists({
    required String orderId,
    required String customerName,
  }) async {
    print('Starting notification creation...'); // Debug log

    try {
      // Create notification data first
      final notification = {
        'title': 'New Order Received',
        'body': 'New order #$orderId from $customerName',
        'type': 'order',
        'orderId': orderId,
        'targetRole': 'pharmacist',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'data': {
          'orderId': orderId,
          'customerName': customerName,
          'status': 'pending'
        }
      };

      print('Notification data prepared: $notification'); // Debug log

      // Create the document
      final DocumentReference notificationRef =
          await _firestore.collection('notifications').add(notification);

      print('Notification created with ID: ${notificationRef.id}'); // Debug log
    } catch (e) {
      print('Error creating notification: $e'); // Debug log
      _errorMessage = 'Failed to send notification: $e';
      notifyListeners();
      rethrow;
    }
  }
}
