import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ErrorHandler {
  static String getAuthErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password provided.';
        case 'email-already-in-use':
          return 'An account already exists for this email.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'too-many-requests':
          return 'Too many requests. Try again later.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        default:
          return 'Authentication error: ${error.message}';
      }
    }
    return 'An unknown authentication error occurred.';
  }

  static Exception handleFirestoreError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return Exception('Permission denied. You may not have access to this data.');
        case 'not-found':
          return Exception('The requested document was not found.');
        case 'already-exists':
          return Exception('The document already exists.');
        case 'resource-exhausted':
          return Exception('Resource exhausted. Please try again later.');
        case 'failed-precondition':
          return Exception('Operation failed due to a precondition not being met.');
        case 'aborted':
          return Exception('The operation was aborted.');
        case 'out-of-range':
          return Exception('The operation was attempted past the valid range.');
        case 'unimplemented':
          return Exception('This operation is not implemented or supported.');
        case 'internal':
          return Exception('Internal server error. Please try again later.');
        case 'unavailable':
          return Exception('Service unavailable. Please try again later.');
        case 'data-loss':
          return Exception('Data loss occurred.');
        case 'unauthenticated':
          return Exception('You are not authenticated. Please sign in.');
        case 'cancelled':
          return Exception('The operation was cancelled.');
        case 'unknown':
          return Exception('An unknown error occurred.');
        default:
          return Exception('Firestore error: ${error.message}');
      }
    }
    return Exception('An unknown Firestore error occurred.');
  }

  static Exception handleStorageError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'object-not-found':
          return Exception('The requested file was not found.');
        case 'bucket-not-found':
          return Exception('The storage bucket was not found.');
        case 'project-not-found':
          return Exception('The project was not found.');
        case 'quota-exceeded':
          return Exception('Storage quota exceeded.');
        case 'unauthenticated':
          return Exception('You are not authenticated. Please sign in.');
        case 'unauthorized':
          return Exception('You are not authorized to access this file.');
        case 'retry-limit-exceeded':
          return Exception('Retry limit exceeded. Please try again later.');
        case 'invalid-checksum':
          return Exception('Invalid file checksum.');
        case 'download-size-exceeded':
          return Exception('Download size exceeded.');
        case 'canceled':
          return Exception('The operation was cancelled.');
        default:
          return Exception('Storage error: ${error.message}');
      }
    }
    return Exception('An unknown storage error occurred.');
  }

  static Exception handleFunctionsError(dynamic error) {
    if (error is FirebaseFunctionsException) {
      switch (error.code) {
        case 'cancelled':
          return Exception('The function was cancelled.');
        case 'unknown':
          return Exception('An unknown error occurred.');
        case 'invalid-argument':
          return Exception('Invalid argument provided to the function.');
        case 'deadline-exceeded':
          return Exception('Function execution deadline exceeded.');
        case 'not-found':
          return Exception('The function was not found.');
        case 'already-exists':
          return Exception('The resource already exists.');
        case 'permission-denied':
          return Exception('Permission denied to call this function.');
        case 'resource-exhausted':
          return Exception('Function quota exceeded.');
        case 'failed-precondition':
          return Exception('Precondition not met for function execution.');
        case 'aborted':
          return Exception('The function was aborted.');
        case 'out-of-range':
          return Exception('Function argument out of range.');
        case 'unimplemented':
          return Exception('The function is not implemented.');
        case 'internal':
          return Exception('Internal function error.');
        case 'unavailable':
          return Exception('Function service unavailable.');
        case 'data-loss':
          return Exception('Data loss occurred in function.');
        case 'unauthenticated':
          return Exception('You are not authenticated to call this function.');
        default:
          return Exception('Functions error: ${error.message}');
      }
    }
    return Exception('An unknown functions error occurred.');
  }
}