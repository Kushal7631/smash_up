/// Thrown when the server returns 409 — slot already booked.
class ConflictException implements Exception {
  final String message;
  ConflictException([this.message = 'Slot already booked']);

  @override
  String toString() => message;
}

/// Thrown when the server returns 404.
class NotFoundException implements Exception {
  final String message;
  NotFoundException([this.message = 'Not found']);

  @override
  String toString() => message;
}

/// Thrown when the server returns 403.
class ForbiddenException implements Exception {
  final String message;
  ForbiddenException([this.message = 'Not authorized']);

  @override
  String toString() => message;
}

/// Generic API exception.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
