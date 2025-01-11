import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/user_viewmodel.dart';

class AddAddressViewModel extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  String? selectedState;
  String? error;

  void dispose() {
    titleController.dispose();
    streetController.dispose();
    cityController.dispose();
    zipController.dispose();
    super.dispose();
  }

  void setSelectedState(String? state) {
    selectedState = state;
    notifyListeners();
  }

  Future<bool> saveAddress(BuildContext context) async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    final success = await userViewModel.saveAddress(
      context,
      title: titleController.text.trim(),
      street: streetController.text.trim(),
      city: cityController.text.trim(),
      state: selectedState!,
      zip: zipController.text.trim(),
    );

    error = userViewModel.error;
    return success;
  }
}
