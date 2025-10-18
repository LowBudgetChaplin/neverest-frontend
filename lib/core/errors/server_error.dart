///Base error model for the app, used to propagate failures from data layer to UI
abstract class Failure {
  final int? code;
  final String message;

  const Failure(this.code, this.message);
  const Failure.withMessage(this.message) : code = -1;
}

// Represents failures originating from server/HTTP responses
class ServerError extends Failure {
  const ServerError(int? code, String message) : super(code, message);
  const ServerError.withMessage(String message) : super.withMessage(message);
}

// Represents local cache/storage failures (read/write/deserialize)
class CacheError extends Failure {
  const CacheError(int? code, String message) : super(code, message);
  const CacheError.withMessage(String message) : super.withMessage(message);
}