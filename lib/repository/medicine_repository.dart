import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pharma_x/model/medicine_model.dart';

class MedicineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Medicine>> fetchMedicines() {
    return _firestore.collection('medicine').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Medicine.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<List<Medicine>> searchMedicines(String query) {
    return _firestore
        .collection('medicine')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .get()
        .then((snapshot) {
      return snapshot.docs.map((doc) {
        return Medicine.fromMap(doc.id, doc.data());
      }).toList();
    });
  }
}
