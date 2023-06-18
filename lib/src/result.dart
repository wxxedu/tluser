import 'failure.dart';
import 'option.dart';
import 'unit.dart';

/// Represents a result that's wrapped inside a [Future].
typedef FResult<T, F extends Failure> = Future<Result<T, F>>;

/// Represents a result that is either a [Failure] or an [Unit].
typedef UResult<F extends Failure> = Result<Unit, Failure>;

/// Represents a result that you may get.
sealed class Result<T, F extends Failure> {
  const Result();

  /// Gets the result from the execution of the [func].
  static Result<T, Failure> from<T, E extends Exception>(
    T Function() func,
  ) {
    try {
      final res = func();
      return Ok(res);
    } on E catch (e) {
      return Err(Failure(cause: e));
    }
  }

  /// Creates a result that is ok.
  const factory Result.ok(T value) = Ok;

  /// Creates a result that is an error.
  const factory Result.err(F err) = Err;

  /// Gets if the result is success or not.
  bool get isOk;

  /// Gets if the result if error or not.
  bool get isErr => !isOk;

  /// Unwraps the result and panics if failed to unwrap. If [message]
  /// is specified, then on failure, the message will be shown in the
  /// exception.
  T unwrap({String? message});

  /// Unwraps the result and returns default if the result is an error.
  T unwrapOr(T Function(F err) mapErr);

  /// Maps the success value of the result.
  Result<T2, F> map<T2>(T2 Function(T value) mapper);

  /// Maps the error value of the result.
  Result<T, F2> mapErr<F2 extends Failure>(F2 Function(F value) mapper);

  /// Converts this [Result] to an [Option].
  Option<T> toOption();

  S fold<S>({
    required S Function(T value) ok,
    required S Function(F value) err,
  });
}

/// Represents a result that is a success.
final class Ok<T, F extends Failure> extends Result<T, F> {
  final T value;

  const Ok(this.value);

  @override
  bool get isOk => true;

  @override
  T unwrap({String? message}) => value;

  @override
  T unwrapOr(T Function(F err) mapErr) => value;

  @override
  Result<T2, F> map<T2>(T2 Function(T value) mapper) => Ok(mapper(value));

  @override
  Result<T, F2> mapErr<F2 extends Failure>(F2 Function(F value) mapper) =>
      Ok(value);

  @override
  Option<T> toOption() => Some(value);

  @override
  S fold<S>({
    required S Function(T value) ok,
    required S Function(F value) err,
  }) =>
      ok(value);
}

/// Represents a result that is an error.
final class Err<T, F extends Failure> extends Result<T, F> {
  final F err;

  const Err(this.err);

  @override
  bool get isOk => false;

  @override
  T unwrap({String? message}) {
    if (message == null) {
      throw err;
    }
    throw Failure(message: message, cause: err);
  }

  @override
  T unwrapOr(T Function(F err) mapErr) => mapErr(err);

  @override
  Result<T2, F> map<T2>(T2 Function(T value) mapper) => Err(err);

  @override
  Result<T, F2> mapErr<F2 extends Failure>(F2 Function(F value) mapper) =>
      Err(mapper(err));

  @override
  Option<T> toOption() => const None();

  @override
  S fold<S>({
    required S Function(T value) ok,
    required S Function(F value) err,
  }) =>
      err(this.err);
}

extension ListResultX<T, F extends Failure> on List<Result<T, F>> {
  Result<List<T>, AggregationFailure<F>> collect() {
    final errs = whereType<Err<dynamic, F>>().map((val) => val.err).toList();
    if (errs.isNotEmpty) {
      return Err(AggregationFailure(errs));
    }
    final res = whereType<Ok<T, dynamic>>().map((val) => val.value).toList();
    return Ok(res);
  }

  List<T> collectOk() {
    return whereType<Ok<T, dynamic>>().map((val) => val.value).toList();
  }
}
