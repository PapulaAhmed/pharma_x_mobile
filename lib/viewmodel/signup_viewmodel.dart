// lib/viewmodels/signup_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:pharma_x/model/user_model.dart';

class SignupViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    // Reset error and set loading
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Validate inputs
      if (firstName.isEmpty ||
          lastName.isEmpty ||
          email.isEmpty ||
          password.isEmpty) {
        _errorMessage = 'All fields are required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Attempt signup
      UserModel? user = await _userRepository.signUp(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();

      return user != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
