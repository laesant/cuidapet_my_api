class DatabaseException implements Exception {
  final String? message;
  final Exception? exception;

  DatabaseException({required this.message, required this.exception});

  @override
  String toString() =>
      'DatabaseException(message: $message, exception: $exception)';
}
