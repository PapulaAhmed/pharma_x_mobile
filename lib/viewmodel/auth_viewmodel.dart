import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  AuthViewModel() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password) async {
    _setLoadingState(true);
    try {
      _clearErrorMessage();
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
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
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _setErrorMessage(e.message);
    } catch (_) {
      _setErrorMessage('An unexpected error occurred');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoadingState(true);
    try {
      _clearErrorMessage();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setLoadingState(false);
        return; // User canceled sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      _setErrorMessage(e.message);
    } catch (_) {
      _setErrorMessage('An unexpected error occurred');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> logOut() async {
    _setLoadingState(true);
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
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
