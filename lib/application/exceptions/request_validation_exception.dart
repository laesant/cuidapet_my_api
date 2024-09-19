class RequestValidationException implements Exception {
  final Map<String, String> errors;

  const RequestValidationException(this.errors);
}
