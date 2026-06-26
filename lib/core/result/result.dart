import 'package:novaplay/core/error/failure.dart';

/// A lightweight `Either`-style result used across domain/data boundaries.
/// Either a [Success] holding a value, or a [ResultFailure] holding a [Failure].
sealed class Result<T> {
  const Result();

  /// True when this is a [Success].
  bool get isSuccess => this is Success<T>;

  /// Returns the value if [Success], otherwise null.
  T? get valueOrNull => switch (this) {
    Success<T>(:final value) => value,
    ResultFailure<T>() => null,
  };

  /// Folds both branches into a single value of type [R].
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T value) onSuccess,
  ) {
    return switch (this) {
      Success<T>(:final value) => onSuccess(value),
      ResultFailure<T>(:final failure) => onFailure(failure),
    };
  }
}

/// The success branch of a [Result].
class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

/// The failure branch of a [Result].
class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);
  final Failure failure;
}
