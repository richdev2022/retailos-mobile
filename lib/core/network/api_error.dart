/// Normalized API error type for the RetailOS mobile client.
///
/// Every [DioException] thrown by [ApiClient] is mapped to an [ApiError] so
/// the UI never has to inspect raw HTTP details. See PRD §4.3 for the
/// canonical error shape.
class ApiError implements Exception {
  const ApiError({
    required this.message,
    this.code,
    this.statusCode,
    this.field,
    this.details,
    this.type = ApiErrorType.server,
    this.originalError,
  });

  /// Human-readable message safe to show end users.
  final String message;

  /// Stable machine-readable code from the backend (e.g. `INVALID_CREDENTIALS`,
  /// `BUSINESS_REQUIRED`, `RATE_LIMITED`). Null if the backend didn't supply one.
  final String? code;

  /// HTTP status code (null for network/connection errors).
  final int? statusCode;

  /// Field-level validation error target, if applicable.
  final String? field;

  /// Additional structured details returned by the backend (validation map, etc.).
  final Map<String, dynamic>? details;

  /// Broad classification useful for UX branching.
  final ApiErrorType type;

  /// The underlying error (usually a [DioException]), retained for debugging.
  final Object? originalError;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidation => type == ApiErrorType.validation;
  bool get isNetwork => type == ApiErrorType.network;
  bool get isCancelled => type == ApiErrorType.cancelled;

  /// First field-level message from [details], if present.
  String? get firstFieldError {
    final d = details;
    if (d == null) return null;
    for (final value in d.values) {
      if (value is List && value.isNotEmpty) return value.first.toString();
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  @override
  String toString() =>
      'ApiError($statusCode${code != null ? ' $code' : ''}): $message';
}

enum ApiErrorType {
  network, // no connectivity / timeout / DNS
  server, // 5xx or unmapped
  client, // 4xx (non-validation)
  validation, // 400 / 422 with field errors
  unauthorized, // 401 handled separately by interceptor, but kept here for clarity
  cancelled,
  unknown,
}
