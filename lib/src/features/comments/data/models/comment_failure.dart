enum CommentFailureType {
  permissionDenied,
  notFound,
  networkError,
  invalidData,
  rateLimited,
  unknown,
}

class CommentFailure implements Exception {

  CommentFailure({
    required this.type,
    required this.message,
    this.code,
    this.originalError,
  });

  factory CommentFailure.permissionDenied({String? message, dynamic originalError}) {
    return CommentFailure(
      type: CommentFailureType.permissionDenied,
      message: message ?? 'You do not have permission to perform this action.',
      originalError: originalError,
    );
  }

  factory CommentFailure.notFound({String? message, dynamic originalError}) {
    return CommentFailure(
      type: CommentFailureType.notFound,
      message: message ?? 'The comment or post was not found.',
      originalError: originalError,
    );
  }

  factory CommentFailure.networkError({String? message, dynamic originalError}) {
    return CommentFailure(
      type: CommentFailureType.networkError,
      message: message ?? 'A network error occurred. Please check your connection and try again.',
      originalError: originalError,
    );
  }

  factory CommentFailure.invalidData({String? message, dynamic originalError}) {
    return CommentFailure(
      type: CommentFailureType.invalidData,
      message: message ?? 'Invalid data provided.',
      originalError: originalError,
    );
  }

  factory CommentFailure.rateLimited({String? message, dynamic originalError}) {
    return CommentFailure(
      type: CommentFailureType.rateLimited,
      message: message ?? 'You are posting too quickly. Please wait a moment and try again.',
      originalError: originalError,
    );
  }

  factory CommentFailure.unknown({String? message, dynamic originalError}) {
    return CommentFailure(
      type: CommentFailureType.unknown,
      message: message ?? 'An unexpected error occurred. Please try again.',
      originalError: originalError,
    );
  }

  factory CommentFailure.fromFirebaseException(dynamic error) {
    final String errorCode = _getErrorCode(error);
    final String errorMessage = _getErrorMessage(error);

    switch (errorCode) {
      case 'permission-denied':
      case 'unauthenticated':
        return CommentFailure.permissionDenied(
          message: 'You do not have permission to perform this action.',
          originalError: error,
        );
      case 'not-found':
        return CommentFailure.notFound(
          message: 'The comment or post was not found.',
          originalError: error,
        );
      case 'unavailable':
      case 'deadline-exceeded':
        return CommentFailure.networkError(
          message: 'Network error. Please check your connection and try again.',
          originalError: error,
        );
      case 'invalid-argument':
      case 'failed-precondition':
        return CommentFailure.invalidData(
          message: errorMessage.isNotEmpty ? errorMessage : 'Invalid data provided.',
          originalError: error,
        );
      case 'resource-exhausted':
        return CommentFailure.rateLimited(
          message: 'Too many requests. Please wait and try again.',
          originalError: error,
        );
      default:
        return CommentFailure.unknown(
          message: errorMessage.isNotEmpty ? errorMessage : 'An unexpected error occurred.',
          originalError: error,
        );
    }
  }
  final CommentFailureType type;
  final String message;
  final String? code;
  final dynamic originalError;

  static String _getErrorCode(dynamic error) {
    if (error == null) return '';
    try {
      if (error.toString().contains('code:')) {
        final match = RegExp(r'code:\s*([a-z-]+)').firstMatch(error.toString());
        if (match != null) return match.group(1) ?? '';
      }
      final errorString = error.toString().toLowerCase();
      if (errorString.contains('permission') || errorString.contains('denied')) {
        return 'permission-denied';
      }
      if (errorString.contains('not found') || errorString.contains('notfound')) {
        return 'not-found';
      }
      if (errorString.contains('network') || errorString.contains('unavailable')) {
        return 'unavailable';
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  static String _getErrorMessage(dynamic error) {
    if (error == null) return '';
    try {
      return error.toString();
    } catch (_) {
      return '';
    }
  }

  @override
  String toString() {
    return 'CommentFailure(type: $type, message: $message, code: $code)';
  }

  String get userFriendlyMessage {
    switch (type) {
      case CommentFailureType.permissionDenied:
        return 'You don\'t have permission to do this. Please check your account status.';
      case CommentFailureType.notFound:
        return 'This content is no longer available.';
      case CommentFailureType.networkError:
        return 'Connection issue. Please check your internet and try again.';
      case CommentFailureType.invalidData:
        return 'There was a problem with your input. Please check and try again.';
      case CommentFailureType.rateLimited:
        return 'You\'re posting too quickly. Please wait a moment.';
      case CommentFailureType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }
}
