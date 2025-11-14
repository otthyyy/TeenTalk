/// Exception thrown when a post operation fails.
abstract class PostException implements Exception {

  const PostException(this.message, {this.userMessage});
  final String message;
  final String? userMessage;

  @override
  String toString() => userMessage ?? message;
}

/// Exception thrown when image upload fails due to network issues.
class ImageUploadNetworkException extends PostException {
  const ImageUploadNetworkException([String? message])
      : super(
          message ?? 'Network error during image upload',
          userMessage: 'Unable to upload image. Please check your connection and try again.',
        );
}

/// Exception thrown when image validation fails.
class ImageValidationException extends PostException {
  const ImageValidationException(super.message, {super.userMessage});
}

/// Exception thrown when post validation fails.
class PostValidationException extends PostException {
  const PostValidationException(super.message, {super.userMessage});
}

/// Exception thrown when Firestore operations fail.
class PostFirestoreException extends PostException {
  const PostFirestoreException([String? message])
      : super(
          message ?? 'Database error',
          userMessage: 'Unable to create post. Please try again later.',
        );
}

/// Exception thrown when Storage operations fail.
class PostStorageException extends PostException {
  const PostStorageException([String? message])
      : super(
          message ?? 'Storage error during upload',
          userMessage: 'Failed to upload image. Please try again.',
        );
}
