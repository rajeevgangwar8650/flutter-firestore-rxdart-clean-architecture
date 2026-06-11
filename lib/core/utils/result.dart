import 'package:equatable/equatable.dart';

import '../errors/failures.dart';

sealed class Result<T> extends Equatable {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final result = this;
    return switch (result) {
      Success<T>(:final data) => success(data),
      FailureResult<T>(:final error) => failure(error),
    };
  }
}

final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  List<Object?> get props => [data];
}

final class FailureResult<T> extends Result<T> {
  final Failure error;

  const FailureResult(this.error);

  @override
  List<Object?> get props => [error];
}
