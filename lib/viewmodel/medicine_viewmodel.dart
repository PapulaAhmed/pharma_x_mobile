import 'package:flutter/material.dart';
import 'package:pharma_x/model/medicine_model.dart';

class MedicineViewModel extends ChangeNotifier {
  final MedicineRepository _repository = MedicineRepository();
  List<Medicine> _medicines = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<Medicine> get medicines => _medicines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  MedicineViewModel() {
    fetchMedicines();
  }

  void fetchMedicines() {
    _repository.fetchMedicines().listen(
      (medicineList) {
        _medicines = medicineList;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
