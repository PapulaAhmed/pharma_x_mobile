import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<UserModel> getCurrentUser() async {
    if (_currentUser != null) return _currentUser!;

    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) return UserModel.guest();

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return UserModel.guest();

      _currentUser = UserModel.fromFirestore(doc.data()!, doc.id);
      return _currentUser!;
    } catch (e) {
      _error = e.toString();
      return UserModel.guest();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<UserModel> userStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(UserModel.guest());

    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) =>
        doc.exists
            ? UserModel.fromFirestore(doc.data()!, doc.id)
            : UserModel.guest());
  }

  Future<bool> addAddress({
    required String title,
    required String street,
    required String city,
    required String state,
    required String zip,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _error = 'User not logged in';
        notifyListeners();
        return false;
      }

      final newAddress = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'street': street,
        'city': city,
        'state': state,
        'zip': zip,
      };

      await _firestore.collection('users').doc(user.uid).update({
        'addresses': FieldValue.arrayUnion([newAddress])
      });

      return true;
    } catch (e) {
      _error = 'Failed to add address: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveAddress(
    BuildContext context, {
    required String title,
    required String street,
    required String city,
    required String state,
    required String zip,
  }) async {
    final success = await addAddress(
      title: title,
      street: street,
      city: city,
      state: state,
      zip: zip,
    );

    if (success) {
      return true;
    }
    return false;
  }

  Future<Map<String, String>> getUserDetails() async {
    final user = _auth.currentUser;
    if (user == null) {
      return {'email': 'Guest', 'name': 'Guest User'};
    }

    final email = user.email ?? 'No Email';

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        final name =
            "${data?['firstName'] ?? 'Guest'} ${data?['lastName'] ?? ''}"
                .trim();
        return {'email': email, 'name': name};
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }

    return {'email': email, 'name': 'Guest User'};
  }

  Future<bool> removeProfilePicture() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _error = 'User not logged in';
        notifyListeners();
        return false;
      }

      // Remove image from Storage if it exists
      final storageRef =
          _storage.ref().child('profile_pictures/${user.uid}.jpg');
      try {
        await storageRef.delete();
      } catch (e) {
        // Ignore if file doesn't exist
      }

      // Update Firestore document
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

  void clearState() {
    // Clear any cached messages, conversations, or streams
    // Cancel any active listeners
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
