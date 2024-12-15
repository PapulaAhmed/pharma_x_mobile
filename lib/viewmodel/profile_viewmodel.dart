import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUserProfile() async {
    // Set the loading state without triggering a widget rebuild
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _errorMessage = 'User not logged in';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _userData = doc.data();
      } else {
        _errorMessage = 'User profile not found';
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch user profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress(String title, String details) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      return;
    }

    final newAddress = {
      "id": Random().nextInt(1000000).toString(), // Generate unique ID
      "title": title,
      "details": details,
    };

    try {
      await _firestore.collection('users').doc(userId).update({
        "addresses": FieldValue.arrayUnion([newAddress]),
      });

      _userData?['addresses'] = [...?_userData?['addresses'], newAddress];
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add address: $e';
      notifyListeners();
    }
  }

  Future<void> removeAddress(String addressId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      return;
    }

    final currentAddresses = _userData?['addresses'] as List<dynamic>? ?? [];
    final addressToRemove =
        currentAddresses.firstWhere((addr) => addr['id'] == addressId);

    try {
      await _firestore.collection('users').doc(userId).update({
        "addresses": FieldValue.arrayRemove([addressToRemove]),
      });

      _userData?['addresses'] =
          currentAddresses.where((addr) => addr['id'] != addressId).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to remove address: $e';
      notifyListeners();
    }
  }

  // update user profile
  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    String? email,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      return;
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        "firstName": firstName,
        "lastName": lastName,
        if (email != null) "email": email,
      });

      _userData?['firstName'] = firstName;
      _userData?['lastName'] = lastName;
      if (email != null) {
        _userData?['email'] = email;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update user profile: $e';
      notifyListeners();
    }
  }
}
