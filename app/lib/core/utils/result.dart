/// Sealed Result type for operation outcomes.
sealed class Result<T, E> {
  const Result();
}

/// Success result containing a value.
class Success<T, E> extends Result<T, E> {
  const Success(this.value);
  final T value;
}

/// Failure result containing an error.
class Failure<T, E> extends Result<T, E> {
  const Failure(this.error);
  final E error;
}

/// Extension methods for Result
extension ResultExtension<T, E> on Result<T, E> {
  /// Map over success value
  Result<U, E> map<U>(U Function(T) transform) {
    return switch (this) {
      Success(value: final v) => Success(transform(v)),
      Failure(error: final e) => Failure(e),
    };
  }

  /// Get value or default
  T getOrElse(T Function() fallback) {
    return switch (this) {
      Success(value: final v) => v,
      Failure() => fallback(),
    };
  }

  /// Whether this is a success
  bool get isSuccess => this is Success<T, E>;

  /// Whether this is a failure
  bool get isFailure => this is Failure<T, E>;
}
