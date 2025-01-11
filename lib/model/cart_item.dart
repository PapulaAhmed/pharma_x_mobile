class CartItem {
  final String id;
  final String name;
  final String? scientificName;
  final String? imageUrl;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    this.scientificName,
    this.imageUrl,
    required this.price,
    required this.quantity,
  });

  // Handle Firestore data
  factory CartItem.fromFirestore(Map<String, dynamic> data) {
    return CartItem(
      id: data['id'] ?? 'Unknown',
      name: data['name'] ?? 'Unnamed Item',
      scientificName: data['scientificName'],
      imageUrl: data['imageUrl'],
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: data['quantity'] ?? 1,
    );
  }

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
    };
  }

  get totalPrice => price * quantity;
}
