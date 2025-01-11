// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? phoneNumber;
  final String? profilePicture;
  final List<Map<String, dynamic>> addresses;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.profilePicture,
    this.addresses = const [],
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      firstName: data['firstName'] ?? 'Guest',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? 'No Email',
      role: data['role'] ?? 'customer',
      phoneNumber: data['phoneNumber'],
      profilePicture: data['profilePicture'],
      addresses: List<Map<String, dynamic>>.from(data['addresses'] ?? []),
    );
  }

  factory UserModel.guest() {
    return UserModel(
      id: '',
      firstName: 'Guest',
      lastName: '',
      email: 'Guest',
      role: 'guest',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'addresses': addresses,
    };
  }
}

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      // Create user with Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create user model
      UserModel userModel = UserModel(
        id: userCredential.user!.uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: 'customer',
      );

      // Store user in Firestore using UID as document ID
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toJson());

      return userModel;
    } catch (e) {
      print('Signup error: $e');
      return null;
    }
  }
}
