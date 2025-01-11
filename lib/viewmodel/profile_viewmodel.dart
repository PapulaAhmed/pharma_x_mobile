import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ProfileViewModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  String get fullName =>
      '${_userData?['firstName'] ?? ''} ${_userData?['lastName'] ?? ''}'.trim();
  String get email => _auth.currentUser?.email ?? '';
  String? get phoneNumber => _userData?['phoneNumber'];
  List<Map<String, dynamic>> get addresses =>
      List<Map<String, dynamic>>.from(_userData?['addresses'] ?? []);

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProfileViewModel() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc =
        await _firestore.collection('users').doc(_auth.currentUser?.uid).get();
    _userData = doc.data();
    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    // Set the loading state without triggering a widget rebuild
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _error = 'User not logged in';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _userData = doc.data();
      } else {
        _error = 'User profile not found';
      }
    } catch (e) {
      _error = 'Failed to fetch user profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress(String title, String details) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _error = 'User not logged in';
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
      _error = 'Failed to add address: $e';
      notifyListeners();
    }
  }

  Future<void> removeAddress(String addressId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _error = 'User not logged in';
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
      _error = 'Failed to remove address: $e';
      notifyListeners();
    }
  }

  // update user profile
  Future<bool> updateUserProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _error = 'User not logged in';
        notifyListeners();
        return false;
      }

      await _firestore.collection('users').doc(userId).update({
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
      });

      _userData?['firstName'] = firstName;
      _userData?['lastName'] = lastName;
      _userData?['phoneNumber'] = phoneNumber;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> changePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      _error = 'Failed to change password: $e';
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _userData = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to logout: $e';
      notifyListeners();
    }
  }

  Future<void> updateProfilePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _error = 'User not logged in';
        notifyListeners();
        return;
      }

      // Show loading state
      _isLoading = true;
      notifyListeners();

      // Upload image to Firebase Storage
      final storageRef = _storage.ref().child('profile_pictures/$userId.jpg');
      await storageRef.putFile(File(image.path));

      // Get the download URL
      final imageUrl = await storageRef.getDownloadURL();

      // Update user profile in Firestore
      await _firestore.collection('users').doc(userId).update({
        'profilePicture': imageUrl,
      });

      // Update local data
      if (_userData != null) {
        _userData!['profilePicture'] = imageUrl;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update profile picture: $e';
      notifyListeners();
    }
  }

  Future<bool> removeProfilePicture() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _error = 'User not logged in';
        notifyListeners();
        return false;
      }

      final storageRef =
          _storage.ref().child('profile_pictures/${user.uid}.jpg');
      try {
        await storageRef.delete();
      } catch (e) {
        // Ignore if file doesn't exist
      }

      await _firestore.collection('users').doc(user.uid).update({
        'profilePicture': null,
      });

      return true;
    } catch (e) {
      _error = 'Failed to remove profile picture: $e';
      notifyListeners();
      return false;
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
