sealed class AppError {
  final String message;
  final String? details;

  const AppError(this.message, {this.details});

  @override
  String toString() => message;
}

class NetworkError extends AppError {
  const NetworkError(super.message, {super.details});
}

class ServerError extends AppError {
  final int? statusCode;
  const ServerError(super.message, {this.statusCode, super.details});
}

class AuthError extends AppError {
  const AuthError(super.message, {super.details});
}

class ValidationError extends AppError {
  const ValidationError(super.message, {super.details});
}

class CacheError extends AppError {
  const CacheError(super.message, {super.details});
}

class UnknownError extends AppError {
  const UnknownError(super.message, {super.details});
}
