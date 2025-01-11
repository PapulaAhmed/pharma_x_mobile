import 'package:flutter/material.dart';
import 'package:pharma_x/model/medicine_model.dart';

class MedicineViewModel extends ChangeNotifier {
  final MedicineRepository _repository = MedicineRepository();
  List<Medicine> _medicines = [];
  List<Medicine> _filteredMedicines = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  List<Medicine> get medicines =>
      _searchQuery.isEmpty ? _medicines : _filteredMedicines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  MedicineViewModel() {
    fetchMedicines();
  }

  void searchMedicines(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredMedicines = [];
    } else {
      _filteredMedicines = _medicines.where((medicine) {
        final nameLower = medicine.name.toLowerCase();
        final descriptionLower = medicine.description.toLowerCase();
        final searchLower = query.toLowerCase();

        return nameLower.contains(searchLower) ||
            descriptionLower.contains(searchLower);
      }).toList();
    }
    notifyListeners();
  }

  void fetchMedicines() {
    _isLoading = true;
    notifyListeners();

    _repository.fetchMedicines().listen(
      (medicineList) {
        _medicines = medicineList.cast<Medicine>();
        if (_searchQuery.isNotEmpty) {
          searchMedicines(_searchQuery);
        }
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
