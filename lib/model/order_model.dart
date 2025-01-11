import 'cart_item.dart';

class OrderModel {
  final String id;
  final String userId;
  final String fullName;
  final String phoneNumber;
  final String email;
  final DateTime date;
  final String status;
  final String address;
  final String paymentMethod;
  final List<CartItem> items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
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
      fullName: data['fullName'] ?? 'No Name',
      phoneNumber: data['phoneNumber'] ?? 'No Phone',
      email: data['email'] ?? 'No Email',
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
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'date': date.toIso8601String(),
      'status': status,
      'address': address,
      'paymentMethod': paymentMethod,
      'items': items.map((item) => item.toFirestore()).toList(),
    };
  }
}
