class DatabaseException implements Exception {
  final String? message;
  final Exception? exception;

  DatabaseException({required this.message, this.exception});

  @override
  String toString() =>
      'DatabaseException(message: $message, exception: $exception)';
}
