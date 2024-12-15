import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String id;
  final String name;
  final String scientificName;
  final String imageUrl;
  final double price;

  Medicine({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.imageUrl,
    required this.price,
  });

  factory Medicine.fromMap(String id, Map<String, dynamic> data) {
    return Medicine(
      id: id,
      name: data['name'] ?? 'Unknown',
      scientificName: data['scientificName'] ?? 'N/A',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
    );
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
