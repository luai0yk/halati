import 'package:flutter/foundation.dart';
import 'package:status_saver/core/errors/failures.dart';

@immutable
sealed class Result<S, F extends Failure> {
  const Result();

  bool get isSuccess => this is Success<S, F>;
  bool get isFailure => this is FailureResult<S, F>;

  S? get dataOrNull => switch (this) {
    Success(:final value) => value,
    FailureResult() => null,
  };

  F? get failureOrNull => switch (this) {
    Success() => null,
    FailureResult(:final failure) => failure,
  };

  R when<R>({
    required R Function(S data) success,
    required R Function(F failure) failure,
  }) {
    return switch (this) {
      Success(:final value) => success(value),
      FailureResult(failure: final f) => failure(f),
    };
  }
}

class Success<S, F extends Failure> extends Result<S, F> {
  final S value;
  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<S, F> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class FailureResult<S, F extends Failure> extends Result<S, F> {
  final F failure;
  const FailureResult(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FailureResult<S, F> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}
