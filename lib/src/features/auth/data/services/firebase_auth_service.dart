import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:teen_talk_app/firebase_options.dart';
import 'package:teen_talk_app/utils/error_handler.dart';

import '../models/auth_user.dart';

class FirebaseAuthService {
  FirebaseAuthService() {
    _initialization ??= _initializeFirebase();
  }

  static Future<void>? _initialization;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger _logger = Logger();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static Future<void> _initializeFirebase() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  Future<void> _ensureFirebaseInitialized() async {
    try {
      await (_initialization ??= _initializeFirebase());
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize Firebase', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Stream<User?> get authStateChanges {
    return Stream.fromFuture(_ensureFirebaseInitialized()).asyncExpand((_) {
      return _auth.authStateChanges();
    });
  }

  User? get currentUser {
    if (Firebase.apps.isEmpty) {
      _logger.w('Firebase accessed before initialization. Returning null currentUser.');
      return null;
    }
    return _auth.currentUser;
  }

  Future<AuthUser?> getCurrentAuthUser() async {
    await _ensureFirebaseInitialized();
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return AuthUser(
          uid: user.uid,
          email: user.email,
          phoneNumber: user.phoneNumber,
          displayName: user.displayName,
          photoURL: user.photoURL,
          emailVerified: user.emailVerified,
          isAnonymous: user.isAnonymous,
          createdAt: user.metadata.creationTime ?? DateTime.now(),
          authMethods: user.providerData.map((p) => p.providerId).toList(),
          isMinor: userDoc.get('isMinor') ?? false,
          parentalConsentProvided: userDoc.get('parentalConsentProvided') ?? false,
          gdprConsentProvided: userDoc.get('gdprConsentProvided') ?? false,
          termsAccepted: userDoc.get('termsAccepted') ?? false,
        );
      }
      return null;
    } catch (e) {
      _logger.e('Error getting auth user: $e');
      return null;
    }
  }

  // Email/Password Authentication
  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await _ensureFirebaseInitialized();
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('User creation failed');
      }

      if (displayName != null) {
        await userCredential.user!.updateDisplayName(displayName);
      }

      final authUser = AuthUser(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email,
        displayName: displayName,
        emailVerified: false,
        isAnonymous: false,
        createdAt: DateTime.now(),
        authMethods: ['password'],
      );

      await _saveAuthUserToFirestore(authUser);
      _logger.i('User signed up successfully: ${userCredential.user!.uid}');

      return authUser;
    } on FirebaseAuthException catch (e) {
      _logger.e('Sign up failed: ${e.code}');
      throw Exception(ErrorHandler.getAuthErrorMessage(e));
    }
  }

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _ensureFirebaseInitialized();
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Sign in failed');
      }

      final authUser = await getCurrentAuthUser();
      if (authUser == null) {
        throw Exception('Could not retrieve user data');
      }

      _logger.i('User signed in successfully: ${userCredential.user!.uid}');
      return authUser;
    } on FirebaseAuthException catch (e) {
      _logger.e('Sign in failed: ${e.code}');
      throw Exception(ErrorHandler.getAuthErrorMessage(e));
    }
  }

  // Google Sign-In
  Future<AuthUser> signInWithGoogle() async {
    await _ensureFirebaseInitialized();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Google sign in failed');
      }

      final authUser = AuthUser(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email,
        displayName: userCredential.user!.displayName,
        photoURL: userCredential.user!.photoURL,
        emailVerified: userCredential.user!.emailVerified,
        isAnonymous: false,
        createdAt: userCredential.user!.metadata.creationTime ?? DateTime.now(),
        authMethods: ['google.com'],
      );

      await _saveAuthUserToFirestore(authUser);
      _logger.i('User signed in with Google: ${userCredential.user!.uid}');

      return authUser;
    } on FirebaseAuthException catch (e) {
      _logger.e('Google sign in failed: ${e.code}');
      throw Exception(ErrorHandler.getAuthErrorMessage(e));
    }
  }

  // Phone Number Authentication
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException error) onError,
    required Function(PhoneAuthCredential credential) onVerificationComplete,
  }) async {
    await _ensureFirebaseInitialized();
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: onVerificationComplete,
        verificationFailed: onError,
        codeSent: (verificationId, resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } catch (e) {
      _logger.e('Phone verification failed: $e');
      rethrow;
    }
  }

  Future<AuthUser> signInWithPhoneOTP({
    required String verificationId,
    required String otp,
  }) async {
    await _ensureFirebaseInitialized();
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Phone sign in failed');
      }

      final authUser = AuthUser(
        uid: userCredential.user!.uid,
        phoneNumber: userCredential.user!.phoneNumber,
        emailVerified: false,
        isAnonymous: false,
        createdAt: userCredential.user!.metadata.creationTime ?? DateTime.now(),
        authMethods: ['phone'],
      );

      await _saveAuthUserToFirestore(authUser);
      _logger.i('User signed in with phone: ${userCredential.user!.uid}');

      return authUser;
    } on FirebaseAuthException catch (e) {
      _logger.e('Phone sign in failed: ${e.code}');
      throw Exception(ErrorHandler.getAuthErrorMessage(e));
    }
  }

  // Linking Auth Providers
  Future<AuthUser> linkWithGoogle() async {
    await _ensureFirebaseInitialized();
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await user.linkWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Linking failed');
      }

      final authUser = AuthUser(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email,
        displayName: userCredential.user!.displayName,
        photoURL: userCredential.user!.photoURL,
        emailVerified: userCredential.user!.emailVerified,
        isAnonymous: false,
        createdAt: userCredential.user!.metadata.creationTime ?? DateTime.now(),
        authMethods: userCredential.user!.providerData
            .map((p) => p.providerId)
            .toList(),
      );

      await _updateAuthUserInFirestore(authUser);
      _logger.i('Google linked successfully: ${userCredential.user!.uid}');

      return authUser;
    } on FirebaseAuthException catch (e) {
      _logger.e('Google linking failed: ${e.code}');
      throw Exception(ErrorHandler.getAuthErrorMessage(e));
    }
  }

  Future<AuthUser> linkWithEmail({
    required String email,
    required String password,
  }) async {
    await _ensureFirebaseInitialized();
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      final userCredential = await user.linkWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Linking failed');
      }

      final authUser = AuthUser(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email,
        displayName: userCredential.user!.displayName,
        photoURL: userCredential.user!.photoURL,
        emailVerified: userCredential.user!.emailVerified,
        isAnonymous: false,
        createdAt: userCredential.user!.metadata.creationTime ?? DateTime.now(),
        authMethods: userCredential.user!.providerData
            .map((p) => p.providerId)
            .toList(),
      );

      await _updateAuthUserInFirestore(authUser);
      _logger.i('Email linked successfully: ${userCredential.user!.uid}');

      return authUser;
    } on FirebaseAuthException catch (e) {
      _logger.e('Email linking failed: ${e.code}');
      throw Exception(ErrorHandler.getAuthErrorMessage(e));
    }
  }

  // Consent Management
  Future<void> recordConsent({
    required String uid,
    required bool gdprConsent,
    required bool termsConsent,
    required bool parentalConsent,
  }) async {
    await _ensureFirebaseInitialized();
    try {
      await _firestore.collection('users').doc(uid).update({
        'gdprConsentProvided': gdprConsent,
        'termsAccepted': termsConsent,
        'parentalConsentProvided': parentalConsent,
        'consentDate': DateTime.now(),
      });

      _logger.i('Consent recorded for user: $uid');
    } catch (e) {
      _logger.e('Error recording consent: $e');
      rethrow;
    }
  }

  // Email Verification
  Future<void> sendEmailVerification() async {
    await _ensureFirebaseInitialized();
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }

    try {
      await user.sendEmailVerification();
      _logger.i('Verification email sent to ${user.email}');
    } catch (e) {
      _logger.e('Error sending verification email: $e');
      rethrow;
    }
  }

  Future<void> reloadUser() async {
    await _ensureFirebaseInitialized();
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }

    try {
      await user.reload();
      _logger.i('User reloaded');
    } catch (e) {
      _logger.e('Error reloading user: $e');
      rethrow;
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _ensureFirebaseInitialized();
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _logger.i('Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      _logger.e('Password reset failed: ${e.code}');
      throw Exception(ErrorHandler.getAuthErrorMessage(e));
    }
  }

  // Anonymous Authentication
  Future<AuthUser> signInAnonymously() async {
    await _ensureFirebaseInitialized();
    try {
      final userCredential = await _auth.signInAnonymously();

      if (userCredential.user == null) {
        throw Exception('Anonymous sign in failed');
      }

      final authUser = AuthUser(
        uid: userCredential.user!.uid,
        emailVerified: false,
        isAnonymous: true,
        createdAt: DateTime.now(),
        authMethods: ['anonymous'],
      );

      await _saveAuthUserToFirestore(authUser);
      _logger.i('Anonymous user signed in: ${userCredential.user!.uid}');

      return authUser;
    } on FirebaseAuthException catch (e) {
      _logger.e('Anonymous sign in failed: ${e.code}');
      throw Exception(ErrorHandler.getAuthErrorMessage(e));
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _ensureFirebaseInitialized();
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      _logger.i('User signed out');
    } catch (e) {
      _logger.e('Sign out failed: $e');
      rethrow;
    }
  }

  // Private helper methods
  Future<void> _saveAuthUserToFirestore(AuthUser authUser) async {
    await _ensureFirebaseInitialized();
    try {
      await _firestore.collection('users').doc(authUser.uid).set({
        'uid': authUser.uid,
        'email': authUser.email,
        'phoneNumber': authUser.phoneNumber,
        'displayName': authUser.displayName,
        'photoURL': authUser.photoURL,
        'emailVerified': authUser.emailVerified,
        'isAnonymous': authUser.isAnonymous,
        'createdAt': authUser.createdAt,
        'authMethods': authUser.authMethods,
        'isMinor': authUser.isMinor,
        'parentalConsentProvided': authUser.parentalConsentProvided,
        'gdprConsentProvided': authUser.gdprConsentProvided,
        'termsAccepted': authUser.termsAccepted,
      }, SetOptions(merge: true));
    } catch (e) {
      _logger.e('Error saving user to Firestore: $e');
      rethrow;
    }
  }

  Future<void> _updateAuthUserInFirestore(AuthUser authUser) async {
    await _ensureFirebaseInitialized();
    try {
      await _firestore.collection('users').doc(authUser.uid).update({
        'authMethods': authUser.authMethods,
        'email': authUser.email,
        'phoneNumber': authUser.phoneNumber,
        'displayName': authUser.displayName,
        'photoURL': authUser.photoURL,
      });
    } catch (e) {
      _logger.e('Error updating user in Firestore: $e');
      rethrow;
    }
  }
}
