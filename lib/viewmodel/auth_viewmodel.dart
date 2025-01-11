import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pharma_x/main.dart';
import 'package:pharma_x/viewmodel/chat_viewmodel.dart';
import 'package:pharma_x/viewmodel/customer_conversation_viewmodel.dart';
import 'package:pharma_x/viewmodel/notification_viewmodel.dart';
import 'package:pharma_x/viewmodel/user_viewmodel.dart';
import 'package:provider/provider.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  String? _errorMessage;
  bool _isLoading = false;
  String? _userRole;

  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  String? get userRole => _userRole;

  AuthViewModel() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _fetchUserRole(user.uid);
      } else {
        _userRole = null;
      }
      notifyListeners();
    });
  }

  Future<void> logIn(String email, String password) async {
    _setLoadingState(true);
    try {
      _clearErrorMessage();
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;
      await _fetchUserRole(_user!.uid);

      // Initialize notifications after login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigatorKey.currentContext != null) {
          Provider.of<NotificationViewModel>(
            navigatorKey.currentContext!,
            listen: false,
          ).refreshNotifications();
        }
      });
    } catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> _fetchUserRole(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      _userRole = userDoc.data()?['role'];
    } catch (_) {
      _userRole = null;
    }
    notifyListeners();
  }

  Future<void> logOut() async {
    _setLoadingState(true);
    try {
      // Sign out from providers
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.disconnect();
        await _googleSignIn.signOut();
      }

      // Clear Firestore cache and disable network
      await _firestore.terminate();
      await _firestore.clearPersistence();

      // Clear all providers' state
      Provider.of<ChatViewModel>(navigatorKey.currentContext!, listen: false)
          .clearState();
      Provider.of<UserViewModel>(navigatorKey.currentContext!, listen: false)
          .clearState();
      Provider.of<CustomerConversationViewModel>(navigatorKey.currentContext!,
              listen: false)
          .clearConversations();
      // Add other viewmodels that need clearing if necessary

      // Sign out from Firebase
      await _auth.signOut();

      // Clear local state
      _user = null;
      _userRole = null;
      _clearErrorMessage();

      // Re-enable Firestore
      await _firestore.enableNetwork();
    } catch (e) {
      _setErrorMessage('Logout failed: $e');
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
