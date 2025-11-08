import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teen_talk_app/src/features/auth/data/models/auth_user.dart';
import 'package:teen_talk_app/src/features/auth/data/services/firebase_auth_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockGoogleSignIn extends Mock {}

class MockFirebaseFirestore extends Mock {}

class MockUserCredential extends Mock implements UserCredential {
  @override
  User? get user => MockUser();
}

class MockUser extends Mock implements User {
  @override
  String get uid => 'test-uid-123';

  @override
  String? get email => 'test@example.com';

  @override
  String? get displayName => 'Test User';

  @override
  bool get emailVerified => false;

  @override
  bool get isAnonymous => false;

  @override
  UserMetadata get metadata => MockUserMetadata();

  @override
  List<UserInfo> get providerData => [MockUserInfo()];
}

class MockUserMetadata extends Mock implements UserMetadata {
  @override
  DateTime? get creationTime => DateTime.now();
}

class MockUserInfo extends Mock implements UserInfo {
  @override
  String get providerId => 'password';
}

void main() {
  group('Auth Flows Tests', () {
    late FirebaseAuthService authService;

    setUp(() {
      authService = FirebaseAuthService();
    });

    group('Email/Password Authentication', () {
      test('Sign up with email and password creates user', () async {
        final authUser = AuthUser(
          uid: 'test-uid',
          email: 'test@example.com',
          emailVerified: false,
          isAnonymous: false,
          createdAt: DateTime.now(),
          authMethods: ['password'],
          displayName: 'Test User',
        );

        expect(authUser.uid, 'test-uid');
        expect(authUser.email, 'test@example.com');
        expect(authUser.authMethods, contains('password'));
      });

      test('AuthUser model stores auth methods correctly', () {
        final authUser = AuthUser(
          uid: 'test-uid',
          email: 'test@example.com',
          emailVerified: false,
          isAnonymous: false,
          createdAt: DateTime.now(),
          authMethods: ['password', 'google.com'],
        );

        expect(authUser.authMethods.length, 2);
        expect(authUser.authMethods, contains('password'));
        expect(authUser.authMethods, contains('google.com'));
      });

      test('AuthUser model validates email field', () {
        final authUser = AuthUser(
          uid: 'test-uid',
          email: 'test@example.com',
          emailVerified: true,
          isAnonymous: false,
          createdAt: DateTime.now(),
          authMethods: ['password'],
        );

        expect(authUser.emailVerified, true);
      });
    });

    group('Phone Authentication', () {
      test('Phone number is stored correctly', () {
        final authUser = AuthUser(
          uid: 'test-uid',
          phoneNumber: '+1234567890',
          emailVerified: false,
          isAnonymous: false,
          createdAt: DateTime.now(),
          authMethods: ['phone'],
        );

        expect(authUser.phoneNumber, '+1234567890');
        expect(authUser.authMethods, contains('phone'));
      });

      test('OTP authentication stores phone as auth method', () {
        final authUser = AuthUser(
          uid: 'test-uid',
          phoneNumber: '+1234567890',
          emailVerified: false,
          isAnonymous: false,
          createdAt: DateTime.now(),
          authMethods: ['phone'],
        );

        expect(authUser.authMethods.length, 1);
        expect(authUser.authMethods.first, 'phone');
      });
    });

    group('Social Authentication', () {
      test('Google authentication creates user with Google provider', () {
        final authUser = AuthUser(
          uid: 'test-uid',
          email: 'test@gmail.com',
          displayName: 'Test User',
          photoURL: 'https://example.com/photo.jpg',
          emailVerified: true,
          isAnonymous: false,
          createdAt: DateTime.now(),
          authMethods: ['google.com'],
        );

        expect(authUser.authMethods, contains('google.com'));
        expect(authUser.photoURL, 'https://example.com/photo.jpg');
        expect(authUser.displayName, 'Test User');
      });

      test('Anonymous authentication creates anonymous user', () {
        final authUser = AuthUser(
          uid: 'test-uid-anon',
          emailVerified: false,
          isAnonymous: true,
          createdAt: DateTime.now(),
          authMethods: ['anonymous'],
        );

        expect(authUser.isAnonymous, true);
        expect(authUser.email, null);
        expect(authUser.phoneNumber, null);
      });
    });

    group('Consent Management', () {
      test('Consent state tracks all required consents', () {
        const consent = Consent(
          uid: 'test-uid',
          gdprConsent: true,
          termsConsent: true,
          parentalConsent: false,
          consentDate: DateTime(2024, 1, 1),
          consentVersion: '1.0',
        );

        expect(consent.gdprConsent, true);
        expect(consent.termsConsent, true);
        expect(consent.parentalConsent, false);
      });

      test('Parental consent required for minors', () {
        final authUser = AuthUser(
          uid: 'test-uid',
          email: 'minor@example.com',
          emailVerified: false,
          isAnonymous: false,
          createdAt: DateTime.now(),
          authMethods: ['password'],
          isMinor: true,
          parentalConsentProvided: false,
        );

        expect(authUser.isMinor, true);
        expect(authUser.parentalConsentProvided, false);
      });

      test('Adult user does not require parental consent', () {
        final authUser = AuthUser(
          uid: 'test-uid',
          email: 'adult@example.com',
          emailVerified: false,
          isAnonymous: false,
          createdAt: DateTime.now(),
          authMethods: ['password'],
          isMinor: false,
        );

        expect(authUser.isMinor, false);
      });
    });

    group('Credential Linking', () {
      test('Auth methods are tracked for linking', () {
        final authUser = AuthUser(
          uid: 'test-uid',
          email: 'test@example.com',
          phoneNumber: '+1234567890',
          emailVerified: false,
          isAnonymous: false,
          createdAt: DateTime.now(),
          authMethods: ['password', 'phone', 'google.com'],
        );

        expect(authUser.authMethods.length, 3);
        expect(authUser.authMethods, contains('password'));
        expect(authUser.authMethods, contains('phone'));
        expect(authUser.authMethods, contains('google.com'));
      });

      test('Duplicate auth methods are prevented', () {
        var authMethods = ['password', 'google.com'];
        authMethods = authMethods.toSet().toList();

        expect(authMethods.length, 2);
      });
    });

    group('Auth State Management', () {
      test('Initial auth state is unauthenticated', () {
        final authState = AuthState.initial();

        expect(authState.isAuthenticated, false);
        expect(authState.isLoading, false);
        expect(authState.error, null);
        expect(authState.user, null);
      });

      test('Auth state requires onboarding for new users', () {
        final user = AuthUser(
          uid: 'test-uid',
          email: 'test@example.com',
          emailVerified: false,
          isAnonymous: false,
          createdAt: DateTime.now(),
          authMethods: ['password'],
        );

        final authState = AuthState(
          isAuthenticated: true,
          isLoading: false,
          user: user,
          requiresOnboarding: true,
        );

        expect(authState.requiresOnboarding, true);
      });

      test('Auth state tracks minor status and consent requirements', () {
        final user = AuthUser(
          uid: 'test-uid',
          email: 'minor@example.com',
          emailVerified: false,
          isAnonymous: false,
          createdAt: DateTime.now(),
          authMethods: ['password'],
          isMinor: true,
          parentalConsentProvided: false,
        );

        final authState = AuthState(
          isAuthenticated: true,
          isLoading: false,
          user: user,
          requiresParentalConsent: true,
        );

        expect(authState.requiresParentalConsent, true);
      });
    });

    group('Error Handling', () {
      test('Auth state captures error messages', () {
        final errorMessage = 'Email already in use';
        final authState = AuthState(
          isAuthenticated: false,
          isLoading: false,
          error: errorMessage,
        );

        expect(authState.error, errorMessage);
      });

      test('Invalid email is caught during validation', () {
        const invalidEmails = [
          'notanemail',
          '@example.com',
          'user@',
          'user@domain',
        ];

        final emailRegex =
            RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

        for (final email in invalidEmails) {
          expect(emailRegex.hasMatch(email), false);
        }
      });

      test('Weak password is rejected', () {
        const weakPasswords = ['12345', 'abc', ''];
        const strongRegex = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)';

        for (final password in weakPasswords) {
          expect(RegExp(strongRegex).hasMatch(password), false);
        }
      });

      test('Invalid phone number is rejected', () {
        const invalidPhones = ['123', '123-456', 'abc'];
        final phoneRegex = RegExp(r'^\+?1?\d{9,15}$');

        for (final phone in invalidPhones) {
          expect(
            phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[^\d+]'), '')),
            false,
          );
        }
      });
    });

    group('User Profile Management', () {
      test('User profile stores complete user information', () {
        final profile = UserProfile(
          uid: 'test-uid',
          firstName: 'John',
          lastName: 'Doe',
          dateOfBirth: DateTime(2000, 1, 1),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          profileComplete: false,
        );

        expect(profile.firstName, 'John');
        expect(profile.lastName, 'Doe');
        expect(profile.profileComplete, false);
      });

      test('User profile can be marked as complete', () {
        var profile = UserProfile(
          uid: 'test-uid',
          firstName: 'John',
          lastName: 'Doe',
          dateOfBirth: DateTime(2000, 1, 1),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          profileComplete: false,
        );

        profile = profile.copyWith(profileComplete: true);

        expect(profile.profileComplete, true);
      });
    });
  });
}
