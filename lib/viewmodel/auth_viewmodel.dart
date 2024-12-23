import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  String? _errorMessage;
  bool _isLoading = false;
  String? _userRole; // Stores the role (customer/pharmacist)

  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  String? get userRole => _userRole;

  AuthViewModel() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (_user != null) {
        // Fetch user role from Firestore
        await _fetchUserRole(_user!.uid);
      }
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password, String role) async {
    _setLoadingState(true);
    try {
      _clearErrorMessage();
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user role in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'role': role,
        'name': userCredential.user!.email, // Default to email
        'email': email,
      });

      await _fetchUserRole(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      _setErrorMessage(e.message);
    } catch (_) {
      _setErrorMessage('An unexpected error occurred');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> logIn(String email, String password) async {
    _setLoadingState(true);
    try {
      _clearErrorMessage();
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user role from Firestore
      await _fetchUserRole(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      _setErrorMessage(e.message);
    } catch (_) {
      _setErrorMessage('An unexpected error occurred');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> _fetchUserRole(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        _userRole = userDoc.data()?['role'];
      } else {
        _userRole = null;
      }
    } catch (_) {
      _userRole = null;
    }
    notifyListeners();
  }

  Future<void> logOut() async {
    _setLoadingState(true);
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      _userRole = null;
      _clearErrorMessage();
    } catch (_) {
      _setErrorMessage('An unexpected error occurred during logout');
    } finally {
      _setLoadingState(false);
    }
  }

  void _setLoadingState(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}
