/// Custom exception class for database operations
class DatabaseException implements Exception {
  final String message;
  final String? operation;
  final dynamic originalError;

  const DatabaseException(this.message, {this.operation, this.originalError});

  @override
  String toString() {
    final buffer = StringBuffer('DatabaseException: $message');

    if (operation != null) {
      buffer.write(' (Operation: $operation)');
    }

    if (originalError != null) {
      buffer.write(' - Original error: $originalError');
    }

    return buffer.toString();
  }
}

/// Result wrapper for database operations
class DatabaseResult<T> {
  final T? data;
  final DatabaseException? error;
  final bool isSuccess;

  const DatabaseResult._({this.data, this.error, required this.isSuccess});

  /// Create a successful result
  factory DatabaseResult.success(T data) {
    return DatabaseResult._(data: data, isSuccess: true);
  }

  /// Create an error result
  factory DatabaseResult.error(DatabaseException error) {
    return DatabaseResult._(error: error, isSuccess: false);
  }

  /// Get the data or throw the error
  T get dataOrThrow {
    if (isSuccess && data != null) {
      return data!;
    }
    throw error ?? DatabaseException('Unknown database error');
  }
}
