/// A failed API call, carrying the user-safe message and field errors from the
/// standard `{ success, message, errors }` envelope.
class ApiException implements Exception {
  const ApiException({
    required this.kind,
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
    this.retryAfterSeconds,
  });

  final ApiErrorKind kind;

  /// Message from the server (already user-friendly), or null for network errors
  /// where the UI should show its own localized text.
  final String? message;
  final int? statusCode;

  /// camelCase JSON path (e.g. `permanentAddress.pinCode`) → message.
  final Map<String, String> fieldErrors;
  final int? retryAfterSeconds;

  bool get isNetwork => kind == ApiErrorKind.network;
  bool get isUnauthorized => kind == ApiErrorKind.unauthorized;

  @override
  String toString() => 'ApiException($kind, $statusCode, $message, $fieldErrors)';
}

enum ApiErrorKind {
  network,
  validation,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  tooManyRequests,
  unavailable,
  server,
}
