/// A discriminated union representing either a successful value [T]
/// or a [HomeStockFailure].
///
/// This is used throughout the repository layer to avoid throwing exceptions
/// across architectural boundaries.
///
/// Example:
/// ```dart
/// final result = await roomRepository.getRooms(homeId);
/// result.when(
///   success: (rooms) => ...,
///   failure: (failure) => ...,
/// );
/// ```
import '../errors/failures.dart';

sealed class Result<T> {
  const Result();

  /// Creates a successful result.
  factory Result.success(T value) => Success(value);

  /// Creates a failure result.
  factory Result.failure(HomeStockFailure failure) => Failure(failure);

  /// Returns true if this is a [Success].
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a [Failure].
  bool get isFailure => this is Failure<T>;

  /// Returns the success value, or null if this is a [Failure].
  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        Failure() => null,
      };

  /// Returns the failure, or null if this is a [Success].
  HomeStockFailure? get failureOrNull => switch (this) {
        Success() => null,
        Failure(:final failure) => failure,
      };

  /// Maps the success value using [transform].
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Success(:final value) => Result.success(transform(value)),
        Failure(:final failure) => Result.failure(failure),
      };

  /// Executes [onSuccess] or [onFailure] depending on the result.
  R when<R>({
    required R Function(T value) success,
    required R Function(HomeStockFailure failure) failure,
  }) =>
      switch (this) {
        Success(:final value) => success(value),
        Failure(failure: final err) => failure(err),
      };
}

/// Represents a successful [Result] carrying [value].
final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

/// Represents a failed [Result] carrying a [HomeStockFailure].
final class Failure<T> extends Result<T> {
  const Failure(this.failure);
  final HomeStockFailure failure;
}
