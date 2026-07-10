/// Base exception class for the application.
abstract class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown for network-related errors.
class NetworkException extends AppException {
  NetworkException(super.message);
}

/// Exception thrown for validation errors.
class ValidationException extends AppException {
  ValidationException(super.message);
}

/// Exception thrown for storage-related errors.
class StorageException extends AppException {
  StorageException(super.message);
}

/// Exception thrown for sync-related errors.
class SyncException extends AppException {
  SyncException(super.message);
}
