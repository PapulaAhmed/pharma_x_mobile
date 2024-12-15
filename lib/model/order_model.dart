import 'cart_item.dart';

class OrderModel {
  final String id;
  final String userId; // User ID to associate the order with the user
  final DateTime date;
  final String status;
  final String address;
  final String paymentMethod;
  final List<CartItem> items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.status,
    required this.address,
    required this.paymentMethod,
    required this.items,
  });

  // Factory method to handle data from Firestore
  factory OrderModel.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return OrderModel(
      id: documentId,
      userId: data['userId'] ?? '', // Default to empty string if null
      date: DateTime.parse(data['date'] ??
          DateTime.now().toIso8601String()), // Default to current date
      status: data['status'] ?? 'Unknown', // Default to 'Unknown' if null
      address: data['address'] ??
          'No Address Provided', // Default to 'No Address Provided' if null
      paymentMethod:
          data['paymentMethod'] ?? 'Cash', // Default to 'Cash' if null
      items: (data['items'] as List<dynamic>? ?? []).map((item) {
        return CartItem.fromFirestore(item as Map<String, dynamic>);
      }).toList(),
    );
  }

  // Convert OrderModel to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'status': status,
      'address': address,
      'paymentMethod': paymentMethod,
      'items': items.map((item) => item.toFirestore()).toList(),
    };
  }
}
