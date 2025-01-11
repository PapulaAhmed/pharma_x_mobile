import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String id;
  final String name;
  final String scientificName;
  final String imageUrl;
  final double price;
  final String description;
  final int quantity;
  final String category;

  Medicine({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.imageUrl,
    required this.price,
    this.description = '',
    this.quantity = 0,
    this.category = '',
  });

  factory Medicine.fromMap(String id, Map<String, dynamic> data) {
    return Medicine(
      id: id,
      name: data['name'] ?? 'Unknown',
      scientificName: data['scientificName'] ?? 'N/A',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      quantity: data['quantity'] ?? 0,
      category: data['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'scientificName': scientificName,
      'imageUrl': imageUrl,
      'price': price,
      'description': description,
      'quantity': quantity,
      'category': category,
    };
  }
}

class MedicineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Medicine>> fetchMedicines() {
    return _firestore.collection('medicine').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Medicine.fromMap(doc.id, doc.data());
      }).toList();
    });
  }
}
