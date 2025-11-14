import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../utils/error_handler.dart';

class AuthService extends ChangeNotifier {

  AuthService() {
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();
  
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      _logger.i('User signed in successfully: ${_user?.uid}');
    } catch (e) {
      _error = ErrorHandler.getAuthErrorMessage(e);
      _logger.e('Sign in failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      _logger.i('User created successfully: ${_user?.uid}');
    } catch (e) {
      _error = ErrorHandler.getAuthErrorMessage(e);
      _logger.e('User creation failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInAnonymously() async {
    _setLoading(true);
    _clearError();

    try {
      final UserCredential result = await _auth.signInAnonymously();
      _user = result.user;
      _logger.i('Anonymous user signed in: ${_user?.uid}');
    } catch (e) {
      _error = ErrorHandler.getAuthErrorMessage(e);
      _logger.e('Anonymous sign in failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _logger.i('User signed out');
    } catch (e) {
      _error = ErrorHandler.getAuthErrorMessage(e);
      _logger.e('Sign out failed: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _logger.i('Password reset email sent to: $email');
    } catch (e) {
      _error = ErrorHandler.getAuthErrorMessage(e);
      _logger.e('Password reset failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    if (_user == null) return;

    try {
      await _user!.updateDisplayName(displayName);
      _logger.i('Display name updated to: $displayName');
    } catch (e) {
      _error = ErrorHandler.getAuthErrorMessage(e);
      _logger.e('Display name update failed: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}